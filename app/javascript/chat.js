// 채팅 메시지 전송 처리
// 페이지가 로드되면 실행
document.addEventListener("turbo:load", function() {
  const messageForm = document.getElementById("message-form");
  const messageInput = document.getElementById("message-input");
  const emojiButton = document.getElementById("emoji-button");
  const emojiPicker = document.getElementById("emoji-picker");
  const emojiGrid = document.getElementById("emoji-grid");
  
  // 폼이 존재하는지 확인 (채팅 페이지에서만 실행)
  if (!messageForm || !messageInput) {
    return;
  }
  
  // 페이지 로드 시 스크롤을 맨 아래로
  scrollToBottom();
  
  // 메시지 입력창에 포커스
  messageInput.focus();
  
  // 이모티콘 목록 (자주 사용하는 이모티콘들)
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
    "🖕", "👇", "☝️", "👍", "👎", "✊", "👊", "🤛",
    "🤜", "👏", "🙌", "👐", "🤲", "🤝", "🙏", "✍️",
    "💪", "🦾", "🦿", "🦵", "🦶", "👂", "🦻", "👃",
    "🧠", "🦷", "🦴", "👀", "👁️", "👅", "👄", "💋",
    "❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍",
    "🤎", "💔", "❣️", "💕", "💞", "💓", "💗", "💖",
    "💘", "💝", "💟", "☮️", "✝️", "☪️", "🕉️", "☸️",
    "✡️", "🔯", "🕎", "☯️", "☦️", "🛐", "⛎", "♈",
    "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐",
    "♑", "♒", "♓", "🆔", "⚛️", "🉑", "☢️", "☣️",
    "🔴", "🟠", "🟡", "🟢", "🔵", "🟣", "⚫", "⚪",
    "🟤", "⭐", "🌟", "✨", "⚡", "☄️", "💥", "🔥",
    "🌈", "☀️", "🌤️", "⛅", "🌥️", "☁️", "🌦️", "🌧️",
    "⛈️", "🌩️", "🌨️", "❄️", "☃️", "⛄", "🌬️", "💨"
  ];
  
  // 이모티콘 그리드 생성
  if (emojiGrid) {
    emojis.forEach(emoji => {
      const emojiButton = document.createElement("button");
      emojiButton.type = "button";
      emojiButton.className = "emoji-item";
      emojiButton.textContent = emoji;
      emojiButton.addEventListener("click", function() {
        // 이모티콘을 입력창에 추가
        messageInput.value += emoji;
        messageInput.focus();
        // 이모티콘 피커 닫기
        emojiPicker.style.display = "none";
      });
      emojiGrid.appendChild(emojiButton);
    });
  }
  
  // 이모티콘 버튼 클릭
  if (emojiButton && emojiPicker) {
    emojiButton.addEventListener("click", function(e) {
      e.stopPropagation();
      // 이모티콘 피커 토글
      if (emojiPicker.style.display === "none") {
        emojiPicker.style.display = "block";
      } else {
        emojiPicker.style.display = "none";
      }
    });
    
    // 다른 곳 클릭 시 이모티콘 피커 닫기
    document.addEventListener("click", function(e) {
      if (!emojiPicker.contains(e.target) && e.target !== emojiButton) {
        emojiPicker.style.display = "none";
      }
    });
  }
  
  // 메시지 전송 함수
  async function sendMessage() {
    const content = messageInput.value.trim();
    
    // 빈 메시지는 전송하지 않음
    if (!content) {
      return;
    }
    
    // 메시지 전송 중 버튼 비활성화
    const submitButton = messageForm.querySelector("#send-button");
    submitButton.disabled = true;
    
    try {
      // CSRF 토큰 가져오기
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
      
      // 서버에 메시지 전송 (AJAX)
      const response = await fetch("/messages", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ content: content })
      });
      
      if (response.ok) {
        // 전송 성공: 입력창 비우기
        messageInput.value = "";
        messageInput.focus();
      } else {
        // 전송 실패
        console.error("메시지 전송 실패");
        alert("메시지 전송에 실패했습니다. 다시 시도해주세요.");
      }
    } catch (error) {
      console.error("메시지 전송 오류:", error);
      alert("네트워크 오류가 발생했습니다.");
    } finally {
      // 버튼 다시 활성화
      submitButton.disabled = false;
    }
  }
  
  // 폼 제출 이벤트 리스너
  messageForm.addEventListener("submit", function(e) {
    e.preventDefault();
    sendMessage();
  });
  
  // 모바일 엔터키 감지 (추가 지원)
  messageInput.addEventListener("keypress", function(e) {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  });
  
  // 전송 버튼 직접 클릭 (모바일 터치 지원)
  const sendButton = document.getElementById("send-button");
  if (sendButton) {
    sendButton.addEventListener("click", function(e) {
      e.preventDefault();
      sendMessage();
    });
    
    // 터치 이벤트도 추가 (모바일 최적화)
    sendButton.addEventListener("touchend", function(e) {
      e.preventDefault();
      sendMessage();
    });
  }
});

// 메시지 컨테이너를 맨 아래로 스크롤
function scrollToBottom() {
  const messagesContainer = document.getElementById("messages");
  if (messagesContainer) {
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }
}
