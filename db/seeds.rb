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

# 기존 유저 중 password_digest 없는 계정에 비밀번호 설정
User.where(password_digest: [nil, ""]).where.not(role: "admin").find_each do |user|
  user.update!(password: "1234", password_confirmation: "1234")
  puts "Password set for: #{user.username} (#{user.nickname}) / 1234"
end

# 대화방 없는 유저에게 대화방 생성
User.where.not(role: "admin").find_each do |user|
  next if user.conversations.exists?

  conv = Conversation.create!(user: user, last_message_at: Time.current)
  puts "Conversation created for: #{user.nickname} (id: #{conv.id})"
end

# conversation_id 없는 기존 메시지를 올바른 대화방에 연결
orphan_messages = Message.where(conversation_id: nil)
if orphan_messages.any?
  orphan_messages.find_each do |msg|
    sender = User.find_by(username: msg.username)
    next unless sender

    user = sender.admin? ? nil : sender
    user ||= User.where.not(role: "admin").find_by(username: msg.username)

    # admin이 보낸 메시지는 대화 상대를 찾아야 함
    if sender.admin?
      # 단일 대화 시스템이었으므로, admin이 아닌 유저의 대화방에 연결
      non_admin_users = User.where.not(role: "admin")
      if non_admin_users.count == 1
        target_user = non_admin_users.first
      else
        # 여러 유저가 있으면, 기존 시스템에서는 유타지와만 대화했으므로
        target_user = User.find_by(username: "user") || non_admin_users.first
      end
      conv = target_user&.conversations&.first
    else
      conv = sender.conversations.first
    end

    if conv
      msg.update_column(:conversation_id, conv.id)
      conv.update_column(:last_message_at, msg.created_at) if conv.last_message_at.nil? || msg.created_at > conv.last_message_at
    end
  end
  puts "#{orphan_messages.count} orphan messages linked to conversations"
end
