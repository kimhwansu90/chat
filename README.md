# ⭐ 별라채팅

텔레그램 스타일의 심플하고 세련된 프라이빗 채팅 앱입니다.  
2명의 사용자만 접속 가능한 가벼운 실시간 채팅 애플리케이션입니다.

## 📋 프로젝트 개요

- **앱 이름**: 별라채팅
- **사용자 수**: 2명 (관리자, 유타지)
- **기술 스택**: Ruby on Rails 8.1.2, ActionCable, SQLite3
- **디자인**: 텔레그램 스타일의 심플하고 세련된 UI

## ✨ 주요 기능

- **로그인 인증**: 사전 등록된 2개의 계정만 접속 가능
- **실시간 채팅**: ActionCable을 사용한 웹소켓 기반 실시간 메시징
- **날짜/시간 표시**: 오늘 메시지는 시간만, 이전 메시지는 날짜+시간 표시
- **이모티콘 지원**: 300개 이상의 이모티콘을 쉽게 입력할 수 있는 이모티콘 피커
- **심플한 UI**: 텔레그램 스타일의 깔끔하고 직관적인 인터페이스
- **반응형 디자인**: 모바일과 데스크톱 모두 지원

## 🔐 로그인 정보

| 아이디 | 비밀번호 |
|--------|----------|
| 관리자 | 7359     |
| 유타지 | 1234     |

## 🚀 시작하기

### 1. 의존성 설치

```bash
bundle install
```

### 2. 데이터베이스 설정

```bash
rails db:migrate
```

### 3. 서버 실행

```bash
rails server
```

### 4. 브라우저에서 접속

```
http://localhost:3000
```

로그인 페이지가 나타나면 위의 로그인 정보 중 하나로 접속하세요.

## 📁 프로젝트 구조

```
chat/
├── app/
│   ├── assets/
│   │   └── stylesheets/
│   │       └── application.css      # 메인 스타일시트 (텔레그램 스타일)
│   ├── channels/
│   │   └── chat_channel.rb          # 실시간 채팅 채널 (ActionCable)
│   ├── controllers/
│   │   ├── application_controller.rb # 기본 컨트롤러 (인증 헬퍼)
│   │   ├── sessions_controller.rb    # 로그인/로그아웃 처리
│   │   └── chat_controller.rb        # 채팅 페이지 및 메시지 생성
│   ├── javascript/
│   │   ├── channels/
│   │   │   └── chat_channel.js      # 실시간 메시지 수신 처리
│   │   └── chat.js                  # 메시지 전송 처리
│   ├── models/
│   │   └── message.rb               # 메시지 모델
│   └── views/
│       ├── layouts/
│       │   └── application.html.erb # 레이아웃 템플릿
│       ├── sessions/
│       │   └── new.html.erb         # 로그인 페이지
│       └── chat/
│           └── index.html.erb       # 채팅 메인 페이지
├── config/
│   ├── routes.rb                    # 라우팅 설정
│   └── importmap.rb                 # JavaScript 모듈 설정
└── db/
    └── migrate/
        └── xxx_create_messages.rb   # 메시지 테이블 마이그레이션
```

## 🎨 디자인 특징

- **컬러 스킴**: 보라색 그라데이션 (#667eea → #764ba2)
- **폰트**: Noto Sans KR (한글 최적화)
- **애니메이션**: 부드러운 페이드인/슬라이드 효과
- **반응형**: 모바일과 데스크톱 모두 최적화

## 🔧 기술 스택

- **백엔드**: Ruby on Rails 8.1.2
- **데이터베이스**: SQLite3
- **실시간 통신**: ActionCable (WebSocket)
- **프론트엔드**: Turbo, Stimulus, Importmap
- **스타일**: 순수 CSS (반응형 디자인)

## 📝 주요 코드 설명

### 1. 로그인 인증 (SessionsController)

```ruby
# app/controllers/sessions_controller.rb
# 하드코딩된 사용자 정보로 간단한 인증 구현
USERS = { "관리자" => "7359", "유타지" => "1234" }
```

### 2. 실시간 채팅 (ChatChannel)

```ruby
# app/channels/chat_channel.rb
# "chat_channel" 스트림으로 메시지 브로드캐스트
stream_from "chat_channel"
```

### 3. 메시지 전송 (ChatController)

```ruby
# app/controllers/chat_controller.rb
# 메시지 저장 후 ActionCable로 브로드캐스트
ActionCable.server.broadcast("chat_channel", message_data)
```

### 4. 클라이언트 수신 (JavaScript)

```javascript
// app/javascript/channels/chat_channel.js
// 서버에서 전송된 메시지를 받아 화면에 표시
received(data) {
  const messageDiv = this.createMessageElement(data);
  messagesContainer.appendChild(messageDiv);
}
```

## 🛡️ 보안 고려사항

- **CSRF 보호**: Rails의 기본 CSRF 토큰 사용
- **세션 관리**: 서버 사이드 세션 기반 인증
- **XSS 방지**: HTML 이스케이프 처리

## 📱 반응형 디자인

- **데스크톱**: 최대 1200px 너비의 카드 형태 레이아웃
- **모바일**: 전체 화면 사용, 간소화된 헤더

## 🎯 향후 개선 가능 사항

- [ ] 이미지/파일 전송 기능
- [ ] 읽음 표시 기능
- [ ] 타이핑 인디케이터
- [ ] 메시지 수정/삭제 기능
- [ ] 메시지 검색 기능
- [ ] 다크 모드 지원
- [ ] 데이터베이스를 PostgreSQL로 전환 (프로덕션용)
- [ ] 환경 변수로 사용자 정보 관리

## ✅ 최근 업데이트

### v1.1.0 (2026-02-16)
- ✨ **날짜 표시 기능 추가**: 오늘 메시지는 시간만, 이전 메시지는 날짜+시간 표시
- 😊 **이모티콘 피커 추가**: 300개 이상의 이모티콘을 쉽게 입력 가능
- 🎨 **UI 개선**: 이모티콘 버튼 및 피커 디자인 추가

## 📄 라이센스

이 프로젝트는 개인 프라이빗 용도로 제작되었습니다.

## 👨‍💻 제작

2명의 사용자를 위한 심플한 채팅 앱
