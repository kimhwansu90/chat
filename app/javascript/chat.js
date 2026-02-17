// 별라채팅 - 이미지 업로드 지원 버전
console.log("=== 채팅 스크립트 로드됨 ===");

let setupDone = false;
let selectedImageFile = null;

document.addEventListener("turbo:before-render", function() {
  console.log("=== Turbo before-render: setupDone 리셋 ===");
  setupDone = false;
});

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
  setupDone = false;
  setupChat();
});

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

  const msgs = document.getElementById("messages");
  if (msgs) msgs.scrollTop = msgs.scrollHeight;

  setupEmoji();
  setupImageUpload();
  setupDragDrop();

  // 전송 함수 - FormData 사용
  window.sendMsg = function() {
    const text = input.value.trim();
    const hasImage = selectedImageFile !== null;

    console.log("전송 호출:", text, "이미지:", hasImage);

    if (!text && !hasImage) {
      console.log("빈 메시지");
      return;
    }

    btn.disabled = true;

    const token = document.querySelector('meta[name="csrf-token"]').content;
    const formData = new FormData();

    if (text) {
      formData.append("content", text);
    }

    if (hasImage) {
      formData.append("image", selectedImageFile);
    }

    const xhr = new XMLHttpRequest();
    xhr.open("POST", "/messages", true);
    xhr.setRequestHeader("X-CSRF-Token", token);

    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        console.log("응답:", xhr.status);
        if (xhr.status === 200) {
          input.value = "";
          clearImagePreview();
          console.log("✓ 성공");
        } else {
          console.error("✗ 실패:", xhr.status);
        }
        btn.disabled = false;
      }
    };

    xhr.send(formData);
  };

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

  input.addEventListener("keydown", function(e) {
    if (e.keyCode === 13) {
      e.preventDefault();
      console.log("엔터");
      window.sendMsg();
    }
  });

  console.log("✓✓✓ 설정 완료");
}

function setupImageUpload() {
  const imageBtn = document.getElementById("image-button");
  const imageInput = document.getElementById("image-input");
  const previewBar = document.getElementById("image-preview-bar");
  const previewImg = document.getElementById("image-preview-img");
  const cancelBtn = document.getElementById("cancel-image");

  if (!imageBtn || !imageInput) return;

  imageBtn.addEventListener("click", function() {
    imageInput.click();
  });

  imageInput.addEventListener("change", function(e) {
    const file = e.target.files[0];
    if (file) {
      if (file.size > 10 * 1024 * 1024) {
        alert("이미지 크기는 10MB 이하여야 합니다.");
        imageInput.value = "";
        return;
      }
      selectedImageFile = file;
      showImagePreview(file);
    }
  });

  if (cancelBtn) {
    cancelBtn.addEventListener("click", function() {
      clearImagePreview();
    });
  }
}

function showImagePreview(file) {
  const previewBar = document.getElementById("image-preview-bar");
  const previewImg = document.getElementById("image-preview-img");

  if (previewBar && previewImg) {
    const reader = new FileReader();
    reader.onload = function(e) {
      previewImg.src = e.target.result;
      previewBar.style.display = "flex";
    };
    reader.readAsDataURL(file);
  }
}

function clearImagePreview() {
  selectedImageFile = null;
  const previewBar = document.getElementById("image-preview-bar");
  const previewImg = document.getElementById("image-preview-img");
  const imageInput = document.getElementById("image-input");

  if (previewBar) previewBar.style.display = "none";
  if (previewImg) previewImg.src = "";
  if (imageInput) imageInput.value = "";
}

function setupDragDrop() {
  const container = document.getElementById("message-input-container");
  if (!container) return;

  container.addEventListener("dragover", function(e) {
    e.preventDefault();
    e.stopPropagation();
    container.classList.add("drag-over");
  });

  container.addEventListener("dragleave", function(e) {
    e.preventDefault();
    e.stopPropagation();
    container.classList.remove("drag-over");
  });

  container.addEventListener("drop", function(e) {
    e.preventDefault();
    e.stopPropagation();
    container.classList.remove("drag-over");

    const files = e.dataTransfer.files;
    if (files.length > 0) {
      const file = files[0];
      if (!file.type.match(/^image\/(jpeg|png|gif|webp)$/)) {
        alert("JPEG, PNG, GIF, WebP 이미지만 업로드 가능합니다.");
        return;
      }
      if (file.size > 10 * 1024 * 1024) {
        alert("이미지 크기는 10MB 이하여야 합니다.");
        return;
      }
      selectedImageFile = file;
      showImagePreview(file);
    }
  });
}

// 라이트박스
window.openImageViewer = function(url) {
  const lightbox = document.getElementById("image-lightbox");
  const lightboxImg = document.getElementById("lightbox-img");
  if (lightbox && lightboxImg) {
    lightboxImg.src = url;
    lightbox.style.display = "flex";
  }
};

window.closeImageViewer = function() {
  const lightbox = document.getElementById("image-lightbox");
  if (lightbox) {
    lightbox.style.display = "none";
  }
};

// 신고
window.reportMessage = function(messageId) {
  if (!confirm("이 메시지를 신고하시겠습니까?")) return;

  const token = document.querySelector('meta[name="csrf-token"]').content;

  fetch("/messages/report", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": token
    },
    body: JSON.stringify({
      message_id: messageId,
      report_type: "inappropriate",
      reason: "사용자 신고"
    })
  }).then(function(response) {
    if (response.ok) {
      alert("신고가 접수되었습니다.");
    } else {
      alert("신고 처리에 실패했습니다.");
    }
  }).catch(function(error) {
    console.error("신고 오류:", error);
    alert("신고 처리 중 오류가 발생했습니다.");
  });
};

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
