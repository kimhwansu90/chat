admin = User.find_or_initialize_by(username: "admin")
admin.assign_attributes(
  password: "7359",
  password_confirmation: "7359",
  nickname: "관리자",
  role: "admin"
)
admin.save!

puts "Admin account ready: admin / 7359"
