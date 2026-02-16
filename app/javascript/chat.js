// 별라채팅 - Safari 완벽 호환 버전
console.log("=== 채팅 스크립트 로드됨 ===");

// 페이지 로드 후 실행
window.addEventListener("load", function() {
  console.log("=== Window Load 이벤트 ===");
  setupChat();
});

document.addEventListener("DOMContentLoaded", function() {
  console.log("=== DOMContentLoaded 이벤트 ===");
  setupChat();
});

document.addEventListener("turbo:load", function() {
  console.log("=== Turbo Load 이벤트 ===");
  setupChat();
});

let setupDone = false;

function setupChat() {
  if (setupDone) {
    console.log("이미 설정됨");
    return;
  }
  
  console.log(">>> 채팅 설정 시작");
  
  const input = document.getElementById("message-input");
  const btn = document.getElementById("send-button");
  
  if (!input || !btn) {
    console.error("요소 없음:", { input: !!input, btn: !!btn });
    return;
  }
  
  console.log("✓ 요소 찾음");
  setupDone = true;
  
  // 스크롤
  const msgs = document.getElementById("messages");
  if (msgs) msgs.scrollTop = msgs.scrollHeight;
  
  // 이모티콘 설정
  setupEmoji();
  
  // 전송 함수
  window.sendMsg = function() {
    const text = input.value.trim();
    console.log("전송 호출:", text);
    
    if (!text) {
      console.log("빈 메시지");
      return;
    }
    
    btn.disabled = true;
    
    const token = document.querySelector('meta[name="csrf-token"]').content;
    
    const xhr = new XMLHttpRequest();
    xhr.open("POST", "/messages", true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", token);
    
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        console.log("응답:", xhr.status);
        if (xhr.status === 200) {
          input.value = "";
          console.log("✓ 성공");
        } else {
          console.error("✗ 실패:", xhr.status);
        }
        btn.disabled = false;
      }
    };
    
    xhr.send(JSON.stringify({ content: text }));
  };
  
  // 버튼 이벤트 - mousedown으로 변경 (Safari에서 더 확실)
  btn.addEventListener("mousedown", function(e) {
    e.preventDefault();
    console.log("mousedown");
    window.sendMsg();
  });
  
  btn.addEventListener("touchstart", function(e) {
    e.preventDefault();
    console.log("touchstart");
    window.sendMsg();
  });
  
  // 엔터키
  input.addEventListener("keydown", function(e) {
    if (e.keyCode === 13) {
      e.preventDefault();
      console.log("엔터");
      window.sendMsg();
    }
  });
  
  console.log("✓✓✓ 설정 완료");
}

function setupEmoji() {
  const btn = document.getElementById("emoji-button");
  const picker = document.getElementById("emoji-picker");
  const grid = document.getElementById("emoji-grid");
  const input = document.getElementById("message-input");
  
  if (!btn || !picker || !grid || !input) return;
  
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
  
  grid.innerHTML = "";
  emojis.forEach(function(e) {
    const b = document.createElement("button");
    b.type = "button";
    b.className = "emoji-item";
    b.textContent = e;
    b.onclick = function() {
      input.value += e;
      picker.style.display = "none";
    };
    grid.appendChild(b);
  });
  
  btn.onclick = function(e) {
    e.stopPropagation();
    picker.style.display = picker.style.display === "none" ? "block" : "none";
  };
  
  document.addEventListener("click", function(e) {
    if (!picker.contains(e.target) && e.target !== btn) {
      picker.style.display = "none";
    }
  });
}
