# Admin 계정
admin = User.find_or_initialize_by(username: "admin")
admin.assign_attributes(
  password: "7359",
  password_confirmation: "7359",
  nickname: "관리자",
  role: "admin"
)
admin.save!
puts "Admin account ready: admin / 7359"

# Manager 계정
manager = User.find_or_initialize_by(username: "manager1")
manager.assign_attributes(
  password: "test1234",
  password_confirmation: "test1234",
  nickname: "김매니저",
  role: "manager",
  email: "manager@test.com"
)
manager.save!
puts "Manager account ready: manager1 / test1234"

# Sales Rep 계정
sales1 = User.find_or_initialize_by(username: "sales1")
sales1.assign_attributes(
  password: "test1234",
  password_confirmation: "test1234",
  nickname: "이영업",
  role: "sales_rep",
  phone: "010-1234-5678"
)
sales1.save!

sales2 = User.find_or_initialize_by(username: "sales2")
sales2.assign_attributes(
  password: "test1234",
  password_confirmation: "test1234",
  nickname: "박영업",
  role: "sales_rep",
  phone: "010-9876-5432"
)
sales2.save!
puts "Sales reps ready: sales1, sales2 / test1234"

# 문의 폼
form = Form.find_or_initialize_by(slug: "free-consultation")
form.assign_attributes(
  name: "무료 상담 신청",
  description: "전문 상담사가 연락드립니다",
  created_by: admin
)
form.save!

if form.form_fields.empty?
  form.form_fields.create!(label: "이름", field_type: "text", name: "name", required: true, position: 0)
  form.form_fields.create!(label: "연락처", field_type: "phone", name: "phone", required: true, position: 1)
  form.form_fields.create!(label: "이메일", field_type: "email", name: "email", required: false, position: 2)
  form.form_fields.create!(label: "문의 내용", field_type: "textarea", name: "message", required: false, position: 3)
end
puts "Form '#{form.name}' ready with #{form.form_fields.count} fields"
puts "Public URL: /f/#{form.slug}"

# 샘플 리드
if Lead.count == 0
  sales_reps = User.sales_reps.to_a
  5.times do |i|
    lead = Lead.create!(
      name: "테스트 고객 #{i + 1}",
      phone: "010-1111-#{1000 + i}",
      status: Lead::STATUSES.sample,
      form: form,
      assigned_to: sales_reps.sample,
      utm_source: %w[naver meta google].sample,
      utm_medium: "cpc",
      utm_campaign: "봄맞이 이벤트"
    )
    lead.activities.create!(activity_type: "note", user: admin, content: "자동 생성된 샘플 리드")
  end
  puts "#{Lead.count} sample leads created"
end
