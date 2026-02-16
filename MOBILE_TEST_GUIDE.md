# 📱 별라채팅 모바일 Safari 테스트 가이드

## 테스트 환경 설정

### Chrome DevTools로 iPhone Safari 시뮬레이션

1. **Chrome 브라우저 열기**
2. **F12** 또는 **Cmd+Option+I** (Mac)로 개발자 도구 열기
3. **Device Toolbar 활성화**: **Cmd+Shift+M** (Mac) 또는 **Ctrl+Shift+M** (Windows)
4. **디바이스 선택**: 상단 드롭다운에서 "iPhone 12 Pro" 또는 "iPhone SE" 선택
5. **User Agent 확인**: 
   - Network conditions 탭에서 User Agent가 iPhone Safari로 설정되어 있는지 확인
   - 또는 Console에서 `navigator.userAgent` 입력하여 확인

---

## 🧪 테스트 체크리스트

### 1단계: 사이트 접속 ✅

**URL**: `https://lynn-overpowering-yulanda.ngrok-free.dev`

**예상 동작**:
- ngrok 경고 페이지가 나타남
- "Visit Site" 버튼이 보임

**확인 사항**:
- [ ] 페이지가 정상적으로 로드됨
- [ ] "Visit Site" 버튼 클릭 가능
- [ ] 클릭 후 로그인 페이지로 이동

---

### 2단계: 로그인 페이지 확인 ✅

**예상 화면**:
- ⭐ 별 아이콘
- "별라채팅" 제목
- 아이디 입력창
- 비밀번호 입력창
- 로그인 버튼

**테스트 실행**:
1. 아이디 입력: `관리자`
2. 비밀번호 입력: `7359`
3. 로그인 버튼 클릭

**확인 사항**:
- [ ] 입력창이 모바일에서 잘 보임
- [ ] 키보드가 올라올 때 레이아웃이 깨지지 않음
- [ ] 로그인 버튼이 클릭 가능
- [ ] 로그인 후 채팅 화면으로 이동

---

### 3단계: 채팅 화면 UI 확인 ✅

**예상 레이아웃** (위에서 아래로):

```
┌─────────────────────────────┐
│ ⭐ 별라채팅      관리자 로그아웃 │ ← 헤더 (고정)
├─────────────────────────────┤
│                             │
│ 2026년 2월 16일 월요일        │ ← 날짜 구분선
│                             │
│ [메시지 영역]                 │
│                             │
│                             │
│                             │ ← 스크롤 가능
│                             │
│                             │
├─────────────────────────────┤
│ 😊 [입력창......] [📤]      │ ← 입력 영역 (하단 고정)
└─────────────────────────────┘
```

**확인 사항**:
- [ ] **헤더**: 상단에 "별라채팅" 제목과 로그아웃 버튼
- [ ] **날짜 구분선**: "2026년 2월 XX일 X요일" 형식으로 표시
- [ ] **메시지 영역**: 기존 메시지들이 보임
- [ ] **입력 영역**: 화면 **맨 아래 고정**되어 있음
- [ ] **이모티콘 버튼**: 좌측에 😊 버튼
- [ ] **입력창**: 중앙에 "메시지를 입력하세요..." 플레이스홀더
- [ ] **전송 버튼**: 우측에 **파란색 원형 버튼** (48px × 48px)

**전송 버튼 상세 확인**:
- 색상: 파란색-보라색 그라데이션 (`#667eea` → `#764ba2`)
- 모양: 완전한 원형 (border-radius: 50%)
- 크기: 48px × 48px
- 아이콘: 종이비행기 모양 (SVG)
- 위치: 입력창 우측, 화면 하단 고정

---

### 4단계: 콘솔 로그 확인 ✅

**Console 탭 열기**:
1. DevTools에서 **Console** 탭 클릭
2. 필터를 "All levels"로 설정

**예상 로그**:
```
💬 chat.js 로드됨
🚀 채팅 초기화 시작
✅ 모든 요소 찾음
✅ 채팅 초기화 완료
```

**확인 사항**:
- [ ] 위 4개 로그가 순서대로 출력됨
- [ ] 빨간색 에러 메시지가 없음
- [ ] "요소를 찾을 수 없습니다" 같은 경고가 없음

---

### 5단계: 메시지 전송 테스트 ✅

**테스트 실행**:
1. 입력창 클릭
2. "모바일테스트" 입력
3. 파란색 원형 전송 버튼 **터치/클릭**

**예상 콘솔 로그**:
```
👆 터치 전송    (또는 🖱️ 클릭 전송)
📤 전송 시작: 모바일테스트
✅ 전송 성공
```

**예상 화면 변화**:
1. 입력창이 비워짐
2. 메시지가 화면 우측에 나타남 (보라색 말풍선)
3. 메시지 하단에 시간 표시 (예: "23:20")
4. 시간 옆에 읽음 표시 (✓ 또는 ✓✓)

**확인 사항**:
- [ ] 전송 버튼이 클릭/터치에 반응함
- [ ] 콘솔에 "전송 시작" 로그가 출력됨
- [ ] 콘솔에 "전송 성공" 로그가 출력됨
- [ ] 메시지가 화면에 나타남
- [ ] 입력창이 자동으로 비워짐
- [ ] 시간이 표시됨 (HH:MM 형식)
- [ ] 읽음 표시가 나타남 (✓)

---

### 6단계: 추가 기능 테스트 ✅

#### 6-1. 이모티콘 버튼 테스트
1. 😊 버튼 클릭
2. 이모티콘 피커가 나타나는지 확인
3. 이모티콘 하나 선택
4. 입력창에 이모티콘이 추가되는지 확인

**확인 사항**:
- [ ] 이모티콘 피커가 입력창 위에 나타남
- [ ] 이모티콘 선택 시 입력창에 추가됨
- [ ] 피커가 자동으로 닫힘

#### 6-2. 엔터키 전송 테스트
1. 입력창에 "엔터키테스트" 입력
2. 키보드에서 **Enter** 키 누름
3. 메시지가 전송되는지 확인

**확인 사항**:
- [ ] Enter 키로 전송 가능
- [ ] 콘솔에 "↩️ 엔터 전송" 로그 출력

#### 6-3. 스크롤 테스트
1. 메시지를 여러 개 전송 (5개 이상)
2. 화면이 자동으로 맨 아래로 스크롤되는지 확인
3. 위로 스크롤해서 이전 메시지를 볼 수 있는지 확인

**확인 사항**:
- [ ] 새 메시지 전송 시 자동 스크롤
- [ ] 입력창이 항상 하단에 고정됨
- [ ] 스크롤 시 메시지가 입력창에 가려지지 않음

---

## 🐛 문제 해결 가이드

### 문제 1: 전송 버튼이 보이지 않음

**확인 사항**:
1. Console에서 실행:
   ```javascript
   document.getElementById('send-button')
   ```
   - `null`이 나오면 → HTML 요소가 없는 문제
   - 요소가 나오면 → CSS 스타일 문제

2. 요소 검사:
   ```javascript
   const btn = document.getElementById('send-button');
   console.log('Display:', window.getComputedStyle(btn).display);
   console.log('Visibility:', window.getComputedStyle(btn).visibility);
   console.log('Opacity:', window.getComputedStyle(btn).opacity);
   console.log('Z-index:', window.getComputedStyle(btn).zIndex);
   ```

**예상 결과**:
- Display: `flex`
- Visibility: `visible`
- Opacity: `1`
- Z-index: `auto` 또는 숫자

---

### 문제 2: 전송 버튼이 클릭되지 않음

**확인 사항**:
1. Console에서 실행:
   ```javascript
   const btn = document.getElementById('send-button');
   console.log('Pointer events:', window.getComputedStyle(btn).pointerEvents);
   console.log('Disabled:', btn.disabled);
   ```

2. 수동으로 클릭 테스트:
   ```javascript
   document.getElementById('send-button').click();
   ```

**예상 결과**:
- Pointer events: `auto`
- Disabled: `false`
- 수동 클릭 시 메시지 전송됨

---

### 문제 3: 메시지가 전송되지 않음

**확인 사항**:
1. Network 탭에서 `/messages` POST 요청 확인
2. 요청 상태 코드 확인 (200 = 성공)
3. Console에 에러 메시지 확인

**디버깅 명령**:
```javascript
// CSRF 토큰 확인
console.log('CSRF Token:', document.querySelector('meta[name="csrf-token"]')?.content);

// 수동 전송 테스트
fetch("/messages", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
  },
  body: JSON.stringify({ content: "테스트" })
}).then(r => console.log('Status:', r.status));
```

---

### 문제 4: 입력창이 키보드에 가려짐

**확인 사항**:
1. 입력창의 `position` 속성 확인:
   ```javascript
   const container = document.querySelector('.message-input-container');
   console.log('Position:', window.getComputedStyle(container).position);
   console.log('Bottom:', window.getComputedStyle(container).bottom);
   console.log('Z-index:', window.getComputedStyle(container).zIndex);
   ```

**예상 결과**:
- Position: `fixed`
- Bottom: `0px`
- Z-index: `1000`

---

## 📊 테스트 결과 보고 양식

### ✅ 성공 사례

```
✅ 1단계: 사이트 접속 - 성공
✅ 2단계: 로그인 - 성공
✅ 3단계: UI 확인 - 모든 요소 정상 표시
✅ 4단계: 콘솔 로그 - 에러 없음
✅ 5단계: 메시지 전송 - 정상 작동
✅ 6단계: 추가 기능 - 모두 정상

스크린샷: [첨부]
```

### ❌ 실패 사례

```
✅ 1단계: 사이트 접속 - 성공
✅ 2단계: 로그인 - 성공
✅ 3단계: UI 확인 - 전송 버튼이 보이지 않음 ❌
❌ 4단계: 콘솔 에러 - "Cannot read property 'addEventListener' of null"
❌ 5단계: 메시지 전송 - 실패 (버튼 없음)

콘솔 에러:
[에러 메시지 복사]

스크린샷: [첨부]
```

---

## 🔧 긴급 수정 방법

### 전송 버튼이 완전히 작동하지 않을 경우

Console에서 다음 코드 실행:

```javascript
// 긴급 수동 전송 함수
window.emergencySend = function() {
  const input = document.getElementById('message-input');
  const content = input.value.trim();
  
  if (!content) {
    alert('메시지를 입력하세요');
    return;
  }
  
  fetch("/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
    },
    body: JSON.stringify({ content: content })
  })
  .then(r => {
    if (r.ok) {
      input.value = '';
      alert('전송 성공!');
      location.reload();
    } else {
      alert('전송 실패: ' + r.status);
    }
  })
  .catch(e => alert('에러: ' + e.message));
};

// 사용법
emergencySend();
```

---

## 📝 테스트 완료 후

다음 정보를 공유해주세요:

1. **각 단계별 성공/실패 여부**
2. **스크린샷** (특히 채팅 화면과 전송 버튼)
3. **콘솔 로그 전체 복사**
4. **Network 탭에서 /messages 요청 상태**
5. **발생한 에러 메시지**

이 정보를 바탕으로 문제를 정확히 진단하고 수정할 수 있습니다! 🚀
