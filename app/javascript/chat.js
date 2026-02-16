// 채팅 메시지 전송 처리 - 모바일 최적화
console.log("💬 chat.js 로드됨");

// 초기화 함수
function initChat() {
  console.log("🚀 채팅 초기화 시작");
  
  const messageInput = document.getElementById("message-input");
  const sendButton = document.getElementById("send-button");
  const emojiButton = document.getElementById("emoji-button");
  const emojiPicker = document.getElementById("emoji-picker");
  const emojiGrid = document.getElementById("emoji-grid");
  
  // 필수 요소 확인
  if (!messageInput || !sendButton) {
    console.log("❌ 채팅 요소를 찾을 수 없습니다.");
    return;
  }
  
  console.log("✅ 모든 요소 찾음");
  
  // 페이지 로드 시 스크롤을 맨 아래로
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
  if (emojiGrid && emojis.length > 0) {
    emojiGrid.innerHTML = "";
    emojis.forEach(emoji => {
      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "emoji-item";
      btn.textContent = emoji;
      btn.onclick = function() {
        messageInput.value += emoji;
        messageInput.focus();
        emojiPicker.style.display = "none";
      };
      emojiGrid.appendChild(btn);
    });
  }
  
  // 이모티콘 버튼
  if (emojiButton && emojiPicker) {
    emojiButton.onclick = function(e) {
      e.stopPropagation();
      emojiPicker.style.display = emojiPicker.style.display === "none" ? "block" : "none";
    };
    
    document.addEventListener("click", function(e) {
      if (!emojiPicker.contains(e.target) && e.target !== emojiButton) {
        emojiPicker.style.display = "none";
      }
    });
  }
  
  // 메시지 전송 함수
  async function sendMessage() {
    const content = messageInput.value.trim();
    
    if (!content) {
      console.log("⚠️ 빈 메시지");
      return;
    }
    
    console.log("📤 전송 시작:", content);
    sendButton.disabled = true;
    sendButton.style.opacity = "0.5";
    
    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
      
      const response = await fetch("/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ content: content })
      });
      
      if (response.ok) {
        console.log("✅ 전송 성공");
        messageInput.value = "";
        messageInput.focus();
      } else {
        console.error("❌ 전송 실패:", response.status);
      }
    } catch (error) {
      console.error("💥 오류:", error);
    } finally {
      sendButton.disabled = false;
      sendButton.style.opacity = "1";
    }
  }
  
  // 전송 버튼 이벤트 - touchend 우선
  let touchHandled = false;
  
  sendButton.addEventListener("touchend", function(e) {
    e.preventDefault();
    e.stopPropagation();
    console.log("👆 터치 전송");
    touchHandled = true;
    sendMessage();
    setTimeout(() => { touchHandled = false; }, 500);
  }, { passive: false });
  
  sendButton.addEventListener("click", function(e) {
    if (touchHandled) {
      console.log("⏭️ 터치 후 클릭 무시");
      return;
    }
    e.preventDefault();
    e.stopPropagation();
    console.log("🖱️ 클릭 전송");
    sendMessage();
  });
  
  // 엔터키 이벤트
  messageInput.addEventListener("keydown", function(e) {
    if (e.key === "Enter" || e.keyCode === 13) {
      e.preventDefault();
      console.log("↩️ 엔터 전송");
      sendMessage();
    }
  });
  
  console.log("✅ 채팅 초기화 완료");
}

// 스크롤 함수
function scrollToBottom() {
  const messagesContainer = document.getElementById("messages");
  if (messagesContainer) {
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }
}

// Turbo 및 DOMContentLoaded 이벤트
document.addEventListener("turbo:load", initChat);
document.addEventListener("DOMContentLoaded", initChat);

// 페이지 로드 시 바로 실행 (백업)
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initChat);
} else {
  initChat();
}
