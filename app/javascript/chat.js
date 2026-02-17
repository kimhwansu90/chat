// 별라채팅 - Safari/iOS 완벽 호환 버전
console.log("=== 채팅 스크립트 로드됨 ===");

var setupDone = false;
var selectedImageFile = null;
var isSending = false;

document.addEventListener("turbo:before-render", function() {
  setupDone = false;
});

window.addEventListener("load", function() {
  setupChat();
});

document.addEventListener("DOMContentLoaded", function() {
  setupChat();
});

document.addEventListener("turbo:load", function() {
  setupDone = false;
  setupChat();
});

function getCSRFToken() {
  var meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.getAttribute("content") : "";
}

function setupChat() {
  if (setupDone) return;

  var input = document.getElementById("message-input");
  var btn = document.getElementById("send-button");

  if (!input || !btn) return;

  setupDone = true;

  var msgs = document.getElementById("messages");
  if (msgs) msgs.scrollTop = msgs.scrollHeight;

  setupEmoji();
  setupImageUpload();
  setupDragDrop();

  // 전송 함수
  window.sendMsg = function() {
    if (isSending) return;

    var text = input.value.trim();
    var hasImage = selectedImageFile !== null;

    if (!text && !hasImage) return;

    isSending = true;
    btn.disabled = true;

    var token = getCSRFToken();
    var formData = new FormData();

    if (text) {
      formData.append("content", text);
    }

    if (hasImage) {
      formData.append("image", selectedImageFile);
    }

    var xhr = new XMLHttpRequest();
    xhr.open("POST", "/messages", true);
    xhr.setRequestHeader("X-CSRF-Token", token);

    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          input.value = "";
          clearImagePreview();
        }
        btn.disabled = false;
        isSending = false;
      }
    };

    xhr.onerror = function() {
      btn.disabled = false;
      isSending = false;
    };

    xhr.send(formData);
  };

  // Safari iOS: touchend 사용 (touchstart는 스크롤과 충돌)
  var sendHandled = false;

  function handleSend(e) {
    e.preventDefault();
    if (sendHandled) return;
    sendHandled = true;
    window.sendMsg();
    setTimeout(function() { sendHandled = false; }, 300);
  }

  btn.addEventListener("touchend", handleSend, { passive: false });
  btn.addEventListener("click", handleSend);

  // 엔터키
  input.addEventListener("keydown", function(e) {
    if (e.keyCode === 13 || e.key === "Enter") {
      e.preventDefault();
      window.sendMsg();
    }
  });
}

function setupImageUpload() {
  var imageBtn = document.getElementById("image-button");
  var imageInput = document.getElementById("image-input");
  var cancelBtn = document.getElementById("cancel-image");

  if (!imageBtn || !imageInput) return;

  imageBtn.addEventListener("click", function() {
    imageInput.click();
  });

  imageInput.addEventListener("change", function(e) {
    var file = e.target.files[0];
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
  var previewBar = document.getElementById("image-preview-bar");
  var previewImg = document.getElementById("image-preview-img");

  if (previewBar && previewImg) {
    var reader = new FileReader();
    reader.onload = function(e) {
      previewImg.src = e.target.result;
      previewBar.style.display = "flex";
    };
    reader.readAsDataURL(file);
  }
}

function clearImagePreview() {
  selectedImageFile = null;
  var previewBar = document.getElementById("image-preview-bar");
  var previewImg = document.getElementById("image-preview-img");
  var imageInput = document.getElementById("image-input");

  if (previewBar) previewBar.style.display = "none";
  if (previewImg) previewImg.src = "";
  if (imageInput) imageInput.value = "";
}

function setupDragDrop() {
  var container = document.getElementById("message-input-container");
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

    var files = e.dataTransfer.files;
    if (files.length > 0) {
      var file = files[0];
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
  var lightbox = document.getElementById("image-lightbox");
  var lightboxImg = document.getElementById("lightbox-img");
  if (lightbox && lightboxImg) {
    lightboxImg.src = url;
    lightbox.style.display = "flex";
  }
};

window.closeImageViewer = function() {
  var lightbox = document.getElementById("image-lightbox");
  if (lightbox) {
    lightbox.style.display = "none";
  }
};

// 신고
window.reportMessage = function(messageId) {
  if (!confirm("이 메시지를 신고하시겠습니까?")) return;

  var token = getCSRFToken();

  var xhr = new XMLHttpRequest();
  xhr.open("POST", "/messages/report", true);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.setRequestHeader("X-CSRF-Token", token);

  xhr.onreadystatechange = function() {
    if (xhr.readyState === 4) {
      if (xhr.status === 200) {
        alert("신고가 접수되었습니다.");
      } else {
        alert("신고 처리에 실패했습니다.");
      }
    }
  };

  xhr.send(JSON.stringify({
    message_id: messageId,
    report_type: "inappropriate",
    reason: "사용자 신고"
  }));
};

function setupEmoji() {
  var btn = document.getElementById("emoji-button");
  var picker = document.getElementById("emoji-picker");
  var grid = document.getElementById("emoji-grid");
  var input = document.getElementById("message-input");

  if (!btn || !picker || !grid || !input) return;

  var emojis = [
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
    var b = document.createElement("button");
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
