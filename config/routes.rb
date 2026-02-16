Rails.application.routes.draw do
  # 별라채팅 라우트 설정
  
  # 로그인 페이지를 루트로 설정
  root "sessions#new"
  
  # 세션 (로그인/로그아웃) 관련 라우트
  get    "login",  to: "sessions#new"      # 로그인 페이지
  post   "login",  to: "sessions#create"   # 로그인 처리
  delete "logout", to: "sessions#destroy"  # 로그아웃 처리
  
  # 닉네임 설정
  get    "nickname", to: "sessions#nickname_form"  # 닉네임 입력 페이지
  post   "nickname", to: "sessions#set_nickname"   # 닉네임 저장
  
  # 채팅 페이지
  get "chat", to: "chat#index"             # 채팅 메인 페이지
  
  # 메시지 API (AJAX로 메시지 전송)
  post "messages", to: "chat#create"       # 메시지 전송
  post "messages/mark_read", to: "chat#mark_read" # 메시지 읽음 처리
  
  # 헬스 체크
  get "up" => "rails/health#show", as: :rails_health_check
end
