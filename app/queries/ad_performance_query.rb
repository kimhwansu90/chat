class AdPerformanceQuery
  def self.call(nad_account, date_from:, date_to:)
    new(nad_account, date_from: date_from, date_to: date_to).call
  end

  def initialize(nad_account, date_from:, date_to:)
    @account = nad_account
    @date_from = date_from
    @date_to = date_to
  end

  def call
    reports = base_reports
    return empty_result if reports.empty?

    totals = aggregate(reports)
    daily = daily_breakdown(reports)
    naver_leads = leads_from_naver

    totals.merge(
      daily: daily,
      naver_leads: naver_leads,
      cost_per_lead: cost_per_lead(totals[:cost], naver_leads)
    )
  end

  private

  def base_reports
    @account.nad_reports
            .campaigns
            .for_date_range(@date_from, @date_to)
  end

  def aggregate(reports)
    {
      impressions: reports.sum(:impressions),
      clicks: reports.sum(:clicks),
      conversions: reports.sum(:conversions),
      cost: reports.sum(:cost),
      ctr: calc_ctr(reports.sum(:impressions), reports.sum(:clicks)),
      cpc: calc_cpc(reports.sum(:cost), reports.sum(:clicks))
    }
  end

  def daily_breakdown(reports)
    reports.group(:report_date).sum(:cost)
           .sort.map { |date, cost| { date: date.strftime("%m/%d"), cost: cost } }
  end

  def leads_from_naver
    Lead.where(created_at: @date_from.beginning_of_day..@date_to.end_of_day)
        .where(utm_source: %w[naver naver_sa])
        .count
  end

  def cost_per_lead(cost, lead_count)
    return 0 if lead_count.zero?
    (cost.to_f / lead_count).round(0).to_i
  end

  def calc_ctr(impressions, clicks)
    return 0 if impressions.zero?
    (clicks.to_f / impressions * 100).round(2)
  end

  def calc_cpc(cost, clicks)
    return 0 if clicks.zero?
    (cost.to_f / clicks).round(0).to_i
  end

  def empty_result
    { impressions: 0, clicks: 0, conversions: 0, cost: 0, ctr: 0, cpc: 0,
      daily: [], naver_leads: 0, cost_per_lead: 0 }
  end
end
