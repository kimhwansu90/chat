class LeadAutoAssigner
  def self.call(lead)
    sales_rep = User.sales_reps.active
      .left_joins(:assigned_leads)
      .where("leads.status IN (?) OR leads.id IS NULL", %w[new contacted quoted])
      .group("users.id")
      .order(Arel.sql("COUNT(leads.id) ASC"))
      .first

    sales_rep ||= User.sales_reps.active.first

    return unless sales_rep

    lead.update!(assigned_to: sales_rep)
    lead.activities.create!(
      activity_type: "assignment",
      content: "#{sales_rep.nickname}에게 자동 배정"
    )
  end
end
