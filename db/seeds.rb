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

# 광고대행사 표준 개인정보처리방침
PRIVACY_POLICY = <<~TEXT
1. 수집하는 개인정보 항목
- 필수항목: 상호명(회사명), 연락처, 이메일
- 선택항목: 주소, 상담 가능 시간, 관심 서비스, 월 광고 예산, 마케팅 이력, 업체 정보

2. 개인정보의 수집 및 이용 목적
- 광고/마케팅 상담 및 견적 제공
- 서비스 안내 및 계약 체결
- 상담 이력 관리 및 고객 문의 응대

3. 개인정보의 보유 및 이용 기간
- 수집일로부터 1년간 보유하며, 이용 목적 달성 후 즉시 파기합니다.
- 관계 법령에 의해 보존이 필요한 경우 해당 기간 동안 보관합니다.

4. 개인정보의 제3자 제공
- 수집된 개인정보는 원칙적으로 제3자에게 제공하지 않습니다.
- 다만, 법률에 의거하여 요구되는 경우에는 예외로 합니다.

5. 동의 거부권 및 불이익
- 개인정보 수집 및 이용에 대한 동의를 거부할 수 있으며, 거부 시 상담 신청이 제한될 수 있습니다.
TEXT

# 문의 폼 (디폴트 필드 포함)
form = Form.find_or_initialize_by(slug: "free-consultation")
form.assign_attributes(
  name: "무료 상담 신청",
  description: "전문 상담사가 맞춤 상담을 제공합니다",
  privacy_policy_text: PRIVACY_POLICY.strip,
  submit_button_text: "상담 신청하기",
  thank_you_message: "상담 신청이 완료되었습니다",
  created_by: admin
)
form.save!

if form.form_fields.empty?
  fields = [
    { label: "상호명 (회사명)", field_type: "text", name: "company_name", required: true, position: 0, half_width: true },
    { label: "담당자명", field_type: "text", name: "name", required: true, position: 1, half_width: true },
    { label: "연락처", field_type: "phone", name: "phone", required: true, position: 2, half_width: true },
    { label: "이메일", field_type: "email", name: "email", required: true, position: 3, half_width: true },
    { label: "상담 가능 시간", field_type: "text", name: "available_time", required: false, position: 4, half_width: true, placeholder: "예: 오후 2시~5시" },
    { label: "주소", field_type: "text", name: "address", required: false, position: 5, half_width: true },
    { label: "관심 서비스", field_type: "button_select", name: "service_interest", required: true, position: 6, options: "플레이스 상위노출,체험단 마케팅,쇼핑 상위노출,블로그 마케팅,SNS 광고,기타" },
    { label: "월 광고 예산", field_type: "button_select", name: "monthly_budget", required: true, position: 7, options: "30~100만원,100~200만원,200~500만원,500만원 이상" },
    { label: "현재 마케팅 이력", field_type: "textarea", name: "marketing_history", required: false, position: 8, placeholder: "예: 네이버 파워링크 월 300만원, 블로그 체험단 월 100만원" },
    { label: "업체 소개 및 요청사항", field_type: "textarea", name: "company_info", required: false, position: 9, placeholder: "주력분야, 업체 특징, 타겟 고객층 등 자유롭게 작성해주세요" }
  ]
  fields.each { |attrs| form.form_fields.create!(attrs) }
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
