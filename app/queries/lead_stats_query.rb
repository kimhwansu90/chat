class LeadStatsQuery
  def initialize(scope = Lead.all)
    @scope = scope
  end

  def self.call(**opts)
    new.call(**opts)
  end

  def call(date_from: 30.days.ago.to_date, date_to: Date.today)
    {
      total: total_leads(date_from, date_to),
      by_status: by_status(date_from, date_to),
      by_channel: by_channel(date_from, date_to),
      by_day: by_day(date_from, date_to),
      by_sales_rep: by_sales_rep,
      conversion_rate: conversion_rate(date_from, date_to),
      today: today_count,
      this_week: this_week_count,
      unassigned: unassigned_count
    }
  end

  private

  def total_leads(date_from, date_to)
    @scope.where(created_at: date_from.beginning_of_day..date_to.end_of_day).count
  end

  def by_status(date_from, date_to)
    @scope.where(created_at: date_from.beginning_of_day..date_to.end_of_day)
          .group(:status).count
  end

  def by_channel(date_from, date_to)
    @scope.where(created_at: date_from.beginning_of_day..date_to.end_of_day)
          .where.not(utm_source: [nil, ""])
          .group(:utm_source).count
          .sort_by { |_, v| -v }.to_h
  end

  def by_day(date_from, date_to)
    @scope.where(created_at: date_from.beginning_of_day..date_to.end_of_day)
          .group("DATE(created_at)").count
          .transform_keys { |k| k.strftime("%Y-%m-%d") }
  end

  def by_sales_rep
    User.sales_reps.active.map do |rep|
      leads = @scope.where(assigned_to: rep)
      converted = leads.where(status: "converted").count
      total = leads.count
      {
        id: rep.id,
        name: rep.nickname,
        total: total,
        converted: converted,
        in_progress: leads.where(status: %w[contacted quoted]).count,
        conversion_rate: total > 0 ? (converted.to_f / total * 100).round(1) : 0
      }
    end.sort_by { |r| -r[:total] }
  end

  def conversion_rate(date_from, date_to)
    period_leads = @scope.where(created_at: date_from.beginning_of_day..date_to.end_of_day)
    total = period_leads.count
    return 0 if total.zero?
    converted = period_leads.where(status: "converted").count
    (converted.to_f / total * 100).round(1)
  end

  def today_count
    @scope.where(created_at: Date.today.beginning_of_day..).count
  end

  def this_week_count
    @scope.where(created_at: Date.today.beginning_of_week..).count
  end

  def unassigned_count
    @scope.where(assigned_to: nil).where(status: %w[new contacted quoted]).count
  end
end
