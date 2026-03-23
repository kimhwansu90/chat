# 키워드 입찰가 자동 최적화 서비스
# 목표 CPC 기준으로 입찰가를 자동 조정
#
# 사용 예시:
#   NaverAds::KeywordBidOptimizer.call(nad_account, target_cpc: 500)
#
module NaverAds
  class KeywordBidOptimizer
    # 입찰가 조정 한도 (±30%)
    MAX_ADJUSTMENT_RATIO = 0.30
    MIN_BID = 70      # 네이버 최소 입찰가 (원)
    MAX_BID = 100_000 # 최대 입찰가 (원)

    Result = Struct.new(:keyword_id, :keyword, :old_bid, :new_bid, :reason, keyword_init: true)

    def self.call(nad_account, target_cpc:, lookback_days: 7)
      new(nad_account, target_cpc: target_cpc, lookback_days: lookback_days).call
    end

    def initialize(nad_account, target_cpc:, lookback_days:)
      @account = nad_account
      @target_cpc = target_cpc.to_i
      @lookback_days = lookback_days
      @client = Client.new(nad_account)
      @results = []
    end

    def call
      date_from = @lookback_days.days.ago.to_date
      date_to = Date.yesterday

      keyword_stats = fetch_keyword_stats(date_from, date_to)
      apply_bid_adjustments(keyword_stats)

      Rails.logger.info "[KeywordBidOptimizer] account=#{@account.id} adjusted=#{@results.count} keywords"
      @results
    rescue Client::ApiError => e
      Rails.logger.error "[KeywordBidOptimizer] #{e.message}"
      raise
    end

    private

    def fetch_keyword_stats(date_from, date_to)
      data = @client.stats(
        stat_type: "KWD",
        date_from: date_from,
        date_to: date_to,
        fields: %w[impCnt clkCnt salesAmt ccnt convAmt]
      )

      # 키워드 ID별로 집계
      Array.wrap(data).each_with_object({}) do |row, memo|
        id = row["id"].to_s
        next if id.blank?

        memo[id] ||= { clicks: 0, cost: 0, impressions: 0 }
        memo[id][:clicks] += row["clkCnt"].to_i
        memo[id][:cost] += row["salesAmt"].to_i
        memo[id][:impressions] += row["impCnt"].to_i
      end
    end

    def apply_bid_adjustments(keyword_stats)
      @account.nad_campaigns.find_each do |campaign|
        campaign.nad_ad_groups.find_each do |ad_group|
          ad_group.nad_keywords.eligible.each do |keyword|
            stats = keyword_stats[keyword.external_id]
            next unless stats && stats[:clicks] >= 10  # 클릭 10회 미만은 데이터 부족

            actual_cpc = stats[:cost] / stats[:clicks]
            new_bid = calculate_new_bid(keyword.bid_amount, actual_cpc)
            next if new_bid == keyword.bid_amount

            apply_bid(keyword, new_bid, actual_cpc)
          end
        end
      end
    end

    def calculate_new_bid(current_bid, actual_cpc)
      return current_bid if @target_cpc.zero?

      # 실제 CPC가 목표보다 높으면 입찰가 낮춤, 낮으면 올림
      ratio = @target_cpc.to_f / actual_cpc
      adjustment = (ratio - 1.0).clamp(-MAX_ADJUSTMENT_RATIO, MAX_ADJUSTMENT_RATIO)
      new_bid = (current_bid * (1 + adjustment)).round(-1)  # 10원 단위 반올림

      new_bid.clamp(MIN_BID, MAX_BID)
    end

    def apply_bid(keyword, new_bid, actual_cpc)
      @client.update_keyword_bid(keyword.external_id, new_bid)
      keyword.update!(bid_amount: new_bid)

      @results << Result.new(
        keyword_id: keyword.external_id,
        keyword: keyword.keyword,
        old_bid: keyword.bid_amount_before_last_save,
        new_bid: new_bid,
        reason: "실제CPC #{actual_cpc}원 → 목표CPC #{@target_cpc}원"
      )
    end
  end
end
