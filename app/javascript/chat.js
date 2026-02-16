// 채팅 메시지 전송 처리 - Safari/Chrome/모든 브라우저 호환
console.log("💬 chat.js 로드 완료");

// 전역 변수로 초기화 상태 관리
window.chatInitialized = false;

// 초기화 함수
function initializeChat() {
  // 중복 초기화 방지
  if (window.chatInitialized) {
    console.log("⚠️ 이미 초기화됨");
    return;
  }
  
  console.log("🔧 채팅 초기화 중...");
  
  // DOM 요소 가져오기
  const messageInput = document.getElementById("message-input");
  const sendButton = document.getElementById("send-button");
  const emojiButton = document.getElementById("emoji-button");
  const emojiPicker = document.getElementById("emoji-picker");
  const emojiGrid = document.getElementById("emoji-grid");
  
  // 필수 요소 확인
  if (!messageInput) {
    console.error("❌ 입력창을 찾을 수 없음");
    return;
  }
  
  if (!sendButton) {
    console.error("❌ 전송 버튼을 찾을 수 없음");
    return;
  }
  
  console.log("✅ DOM 요소 확인 완료");
  window.chatInitialized = true;
  
  // 스크롤을 맨 아래로
  scrollToBottom();
  
  // 이모티콘 목록
  const emojis = [
    "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣",
    "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰",
    "😘", "😗", "😙", "😚", "😋", "😛", "😝", "😜",
    "🤪", "🤨", "🧐", "🤓", "😎", "🤩", "🥳", "😏",
    "😒", "😞", "😔", "😟", "😕", "🙁", "☹️", "😣",
    "😖", "😫", "😩", "🥺", "😢", "😭", "😤", "😠",
    "😡", "🤬", "🤯", "😳", "🥵", "🥶", "😱", "😨",
    "😰", "😥", "😓", "🤗", "🤔", "🤭", "🤫", "🤥",
    "😶", "😐", "😑", "😬", "🙄", "😯", "😦", "😧",
    "😮", "😲", "🥱", "😴", "🤤", "😪", "😵", "🤐",
    "🥴", "🤢", "🤮", "🤧", "😷", "🤒", "🤕", "🤑",
    "🤠", "😈", "👿", "👹", "👺", "🤡", "💩", "👻",
    "💀", "☠️", "👽", "👾", "🤖", "🎃", "😺", "😸",
    "😹", "😻", "😼", "😽", "🙀", "😿", "😾",
    "👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤌", "🤏",
    "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆",
    "👇", "☝️", "👍", "👎", "✊", "👊", "🤛", "🤜",
    "👏", "🙌", "👐", "🤲", "🤝", "🙏", "✍️", "💪",
    "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍",
    "💔", "❣️", "💕", "💞", "💓", "💗", "💖", "💘",
    "⭐", "🌟", "✨", "⚡", "☄️", "💥", "🔥", "🌈"
  ];
  
  // 이모티콘 그리드 생성
  if (emojiGrid) {
    emojiGrid.innerHTML = "";
    emojis.forEach(function(emoji) {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "emoji-item";
      btn.textContent = emoji;
      
      // 이모티콘 클릭/터치 이벤트
      btn.addEventListener("touchend", function(e) {
        e.preventDefault();
        messageInput.value += emoji;
        messageInput.focus();
        if (emojiPicker) emojiPicker.style.display = "none";
      });
      
      btn.addEventListener("click", function() {
        messageInput.value += emoji;
        messageInput.focus();
        if (emojiPicker) emojiPicker.style.display = "none";
      });
      
      emojiGrid.appendChild(btn);
    });
  }
  
  // 이모티콘 버튼 이벤트
  if (emojiButton && emojiPicker) {
    emojiButton.addEventListener("click", function(e) {
      e.preventDefault();
      e.stopPropagation();
      const isVisible = emojiPicker.style.display !== "none";
      emojiPicker.style.display = isVisible ? "none" : "block";
    });
    
    document.addEventListener("click", function(e) {
      if (!emojiPicker.contains(e.target) && e.target !== emojiButton) {
        emojiPicker.style.display = "none";
      }
    });
  }
  
  // 메시지 전송 함수 (Safari 호환)
  function sendMessageNow() {
    const content = messageInput.value.trim();
    
    console.log("📤 전송 함수 실행, 내용:", content);
    
    if (!content) {
      console.log("⚠️ 빈 메시지");
      return;
    }
    
    // 전송 중 표시
    sendButton.disabled = true;
    sendButton.style.opacity = "0.6";
    
    // CSRF 토큰
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute("content");
    
    console.log("🔑 CSRF:", csrfToken ? "있음" : "없음");
    
    // XMLHttpRequest 사용 (Safari에서 더 안정적)
    const xhr = new XMLHttpRequest();
    xhr.open("POST", "/messages", true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", csrfToken);
    
    xhr.onload = function() {
      console.log("📡 응답 수신:", xhr.status);
      
      if (xhr.status === 200) {
        console.log("✅ 전송 성공!");
        messageInput.value = "";
        messageInput.focus();
      } else {
        console.error("❌ 전송 실패:", xhr.status);
      }
      
      sendButton.disabled = false;
      sendButton.style.opacity = "1";
    };
    
    xhr.onerror = function() {
      console.error("💥 네트워크 오류");
      sendButton.disabled = false;
      sendButton.style.opacity = "1";
    };
    
    xhr.send(JSON.stringify({ content: content }));
    console.log("🌐 XHR 전송 완료");
  }
  
  // 전송 버튼 - touchstart/touchend 방식
  let touchStarted = false;
  
  sendButton.addEventListener("touchstart", function(e) {
    console.log("👇 터치 시작");
    touchStarted = true;
    sendButton.style.transform = "scale(0.95)";
  });
  
  sendButton.addEventListener("touchend", function(e) {
    e.preventDefault();
    e.stopPropagation();
    console.log("👆 터치 종료 → 전송!");
    
    if (touchStarted) {
      sendButton.style.transform = "scale(1)";
      sendMessageNow();
      touchStarted = false;
    }
  });
  
  sendButton.addEventListener("touchcancel", function() {
    console.log("🚫 터치 취소");
    touchStarted = false;
    sendButton.style.transform = "scale(1)";
  });
  
  // 클릭 이벤트 (데스크톱용)
  sendButton.addEventListener("click", function(e) {
    e.preventDefault();
    console.log("🖱️ 클릭 → 전송!");
    sendMessageNow();
  });
  
  // 엔터키 이벤트 (keydown이 더 안정적)
  messageInput.addEventListener("keydown", function(e) {
    if (e.keyCode === 13 || e.key === "Enter") {
      e.preventDefault();
      console.log("⏎ 엔터 → 전송!");
      sendMessageNow();
    }
  });
  
  console.log("✅✅✅ 채팅 초기화 100% 완료!");
}

// 스크롤 함수
function scrollToBottom() {
  const container = document.getElementById("messages");
  if (container) {
    container.scrollTop = container.scrollHeight;
  }
}

// 여러 방식으로 초기화 시도 (Safari 호환)
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initializeChat);
} else {
  initializeChat();
}

document.addEventListener("turbo:load", initializeChat);
document.addEventListener("turbo:render", initializeChat);

// 페이지 로드 후 1초 뒤에도 시도 (백업)
setTimeout(function() {
  if (!window.chatInitialized) {
    console.log("⏰ 타이머로 재시도");
    initializeChat();
  }
}, 1000);
