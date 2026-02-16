// 채팅 메시지 전송 처리
document.addEventListener("turbo:load", initChat);
document.addEventListener("DOMContentLoaded", initChat);

function initChat() {
  const messageInput = document.getElementById("message-input");
  const sendButton = document.getElementById("send-button");
  const emojiButton = document.getElementById("emoji-button");
  const emojiPicker = document.getElementById("emoji-picker");
  const emojiGrid = document.getElementById("emoji-grid");
  
  // 필수 요소 확인
  if (!messageInput || !sendButton) {
    return;
  }
  
  // 페이지 로드 시 스크롤을 맨 아래로
  scrollToBottom();
  
  // 메시지 입력창에 포커스
  setTimeout(() => messageInput.focus(), 100);
  
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
    
    console.log("메시지 전송 시도:", content);
    
    // 메시지 전송 중 버튼 비활성화
    sendButton.disabled = true;
    
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
      
      console.log("전송 응답:", response.status);
      
      if (response.ok) {
        // 전송 성공: 입력창 비우기
        messageInput.value = "";
        setTimeout(() => messageInput.focus(), 100);
      } else {
        // 전송 실패
        console.error("메시지 전송 실패:", response.status);
        alert("메시지 전송에 실패했습니다.");
      }
    } catch (error) {
      console.error("메시지 전송 오류:", error);
      alert("네트워크 오류가 발생했습니다.");
    } finally {
      // 버튼 다시 활성화
      sendButton.disabled = false;
    }
  }
  
  // 전송 버튼 클릭 이벤트 (한 번만 등록)
  sendButton.onclick = function() {
    console.log("전송 버튼 클릭됨");
    sendMessage();
    return false;
  };
  
  // 엔터키 이벤트
  messageInput.onkeypress = function(e) {
    if (e.key === "Enter" || e.keyCode === 13) {
      console.log("엔터키 눌림");
      e.preventDefault();
      sendMessage();
      return false;
    }
  };
}

// 메시지 컨테이너를 맨 아래로 스크롤
function scrollToBottom() {
  const messagesContainer = document.getElementById("messages");
  if (messagesContainer) {
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }
}
