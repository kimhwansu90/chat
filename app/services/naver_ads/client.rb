require "net/http"
require "openssl"
require "base64"
require "json"

module NaverAds
  class Client
    BASE_URL = "https://api.naver.com".freeze

    class ApiError < StandardError
      attr_reader :status, :body

      def initialize(message, status: nil, body: nil)
        super(message)
        @status = status
        @body = body
      end
    end

    def initialize(nad_account)
      @account = nad_account
    end

    # 캠페인 목록 조회
    def campaigns
      get("/ncc/campaigns")
    end

    # 특정 캠페인 조회
    def campaign(campaign_id)
      get("/ncc/campaigns/#{campaign_id}")
    end

    # 광고그룹 목록 조회
    def ad_groups(campaign_id: nil)
      path = campaign_id ? "/ncc/adgroups?campaignIds=#{campaign_id}" : "/ncc/adgroups"
      get(path)
    end

    # 키워드 목록 조회
    def keywords(ad_group_id:)
      get("/ncc/keywords?nccAdgroupId=#{ad_group_id}")
    end

    # 성과 통계 조회 (GET /stats)
    # stat_type: "CAMP" | "ADGRP" | "KWD"
    STAT_FIELDS = %w[impCnt clkCnt salesAmt ctr cpc ccnt convAmt avgRnk].freeze

    def stats(stat_type:, date_from:, date_to:, id: nil, fields: nil)
      query_params = {
        fields: (fields || STAT_FIELDS).join(","),
        timeUnit: "DAY",
        dateFrom: date_from.strftime("%Y%m%d"),
        dateTo: date_to.strftime("%Y%m%d"),
        statType: stat_type.upcase
      }
      query_params[:id] = id if id.present?

      get("/stats?#{URI.encode_www_form(query_params)}")
    end

    # 키워드 입찰가 수정
    def update_keyword_bid(keyword_id, bid_amount)
      put("/ncc/keywords/#{keyword_id}", { bidAmt: bid_amount.to_i })
    end

    # 캠페인 일시중지 / 재개
    def update_campaign_status(campaign_id, status)
      put("/ncc/campaigns/#{campaign_id}", { userLock: status == "PAUSED" })
    end

    private

    def get(path)
      request(:GET, path)
    end

    def post(path, body)
      request(:POST, path, body: body)
    end

    def put(path, body)
      request(:PUT, path, body: body)
    end

    def request(method, path, body: nil)
      uri = URI("#{BASE_URL}#{path}")
      timestamp = (Time.now.to_f * 1000).to_i.to_s

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 30

      req = build_request(method, uri, timestamp, body)

      response = http.request(req)
      handle_response(response)
    rescue Net::TimeoutError => e
      raise ApiError.new("Naver Ads API 타임아웃: #{e.message}")
    rescue StandardError => e
      raise ApiError.new("Naver Ads API 오류: #{e.message}")
    end

    def build_request(method, uri, timestamp, body)
      req_class = { GET: Net::HTTP::Get, POST: Net::HTTP::Post, PUT: Net::HTTP::Put }[method]
      req = req_class.new(uri)

      req["X-API-KEY"] = @account.api_key
      req["X-Customer"] = @account.customer_id
      req["X-Timestamp"] = timestamp
      req["X-Signature"] = generate_signature(timestamp, method.to_s, uri.path)
      req["Content-Type"] = "application/json; charset=UTF-8"

      req.body = body.to_json if body
      req
    end

    def generate_signature(timestamp, method, path)
      message = "#{timestamp}.#{method}.#{path}"
      digest = OpenSSL::HMAC.digest("sha256", @account.api_secret, message)
      Base64.strict_encode64(digest)
    end

    def handle_response(response)
      case response.code.to_i
      when 200, 201
        JSON.parse(response.body)
      when 401
        raise ApiError.new("인증 실패: API Key 또는 Secret을 확인하세요", status: 401, body: response.body)
      when 403
        raise ApiError.new("접근 권한이 없습니다", status: 403, body: response.body)
      when 404
        raise ApiError.new("리소스를 찾을 수 없습니다", status: 404, body: response.body)
      when 429
        raise ApiError.new("API 호출 한도 초과. 잠시 후 다시 시도하세요", status: 429, body: response.body)
      else
        raise ApiError.new("API 오류 (#{response.code}): #{response.body}", status: response.code.to_i, body: response.body)
      end
    end
  end
end
