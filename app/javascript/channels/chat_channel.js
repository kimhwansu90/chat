import consumer from "channels/consumer"

consumer.subscriptions.create("ChatChannel", {
  connected: function() {
    console.log("채팅 채널에 연결되었습니다");
    this.markUnreadMessages();
  },

  disconnected: function() {
    console.log("채팅 채널 연결이 끊어졌습니다");
  },

  received: function(data) {
    // 읽음 확인
    if (data.type === "read_receipt") {
      this.updateReadStatus(data.message_id, data.read_count);
      return;
    }

    // 강제 퇴장
    if (data.type === "user_kicked") {
      if (data.username === window.currentUser) {
        alert("관리자에 의해 퇴장되었습니다.");
        window.location.href = "/login";
      }
      return;
    }

    // 메시지 삭제
    if (data.type === "message_deleted") {
      var msgEl = document.querySelector('[data-message-id="' + data.message_id + '"]');
      if (msgEl) {
        msgEl.remove();
      }
      return;
    }

    // 새 메시지 수신
    var messagesContainer = document.getElementById("messages");
    if (messagesContainer) {
      this.addDateDividerIfNeeded();

      var messageDiv = this.createMessageElement(data);
      messagesContainer.appendChild(messageDiv);
      this.scrollToBottom();

      if (data.username !== window.currentUser) {
        this.markMessageAsRead(data.id);
      }
    }
  },

  addDateDividerIfNeeded: function() {
    var messagesContainer = document.getElementById("messages");
    var messages = messagesContainer.querySelectorAll(".message");
    var today = new Date();
    var todayStr = today.toLocaleDateString("ko-KR", { year: "numeric", month: "long", day: "numeric", weekday: "long" });

    var existingDividers = messagesContainer.querySelectorAll(".date-divider");
    var todayDate = today.toDateString();
    var hasTodayDivider = false;

    existingDividers.forEach(function(divider) {
      if (divider.getAttribute("data-date") === todayDate) {
        hasTodayDivider = true;
      }
    });

    if (messages.length > 0) {
      var lastMessage = messages[messages.length - 1];
      var lastMessageDate = lastMessage.getAttribute("data-date");

      if (lastMessageDate !== todayDate && !hasTodayDivider) {
        var divider = document.createElement("div");
        divider.className = "date-divider";
        divider.setAttribute("data-date", todayDate);
        divider.innerHTML = '<span class="date-divider-text">' + this.escapeHtml(todayStr) + '</span>';
        messagesContainer.appendChild(divider);
      }
    } else if (!hasTodayDivider) {
      var divider = document.createElement("div");
      divider.className = "date-divider";
      divider.setAttribute("data-date", todayDate);
      divider.innerHTML = '<span class="date-divider-text">' + this.escapeHtml(todayStr) + '</span>';
      messagesContainer.appendChild(divider);
    }
  },

  createMessageElement: function(data) {
    var today = new Date().toDateString();
    var isMine = data.username === window.currentUser;

    // 시스템 메시지
    if (data.message_type === "system") {
      var sysDiv = document.createElement("div");
      sysDiv.className = "system-message";
      sysDiv.setAttribute("data-message-id", data.id);
      sysDiv.innerHTML = '<span class="system-message-text">' + this.escapeHtml(data.content) + '</span>';
      return sysDiv;
    }

    var messageDiv = document.createElement("div");
    messageDiv.className = isMine ? "message message-mine" : "message";
    messageDiv.setAttribute("data-message-id", data.id);
    messageDiv.setAttribute("data-date", today);

    var nicknameHtml = "";
    if (!isMine) {
      nicknameHtml = '<div class="message-sender">' + this.escapeHtml(data.nickname || data.username) + '</div>';
    }

    var readStatusHtml = "";
    if (isMine) {
      var readCount = data.read_count || 1;
      var checkHtml = readCount > 1
        ? '<span class="checkmark double">✓✓</span>'
        : '<span class="checkmark single">✓</span>';
      readStatusHtml = '<span class="read-status" data-read-count="' + readCount + '">' + checkHtml + '</span>';
    }

    // 신고 버튼
    var reportBtnHtml = "";
    if (!isMine) {
      reportBtnHtml = '<button class="btn-report" onclick="reportMessage(' + data.id + ')" title="신고">⚠️</button>';
    }

    // 이미지
    var imageHtml = "";
    if (data.image_url) {
      var thumbUrl = data.image_thumbnail_url || data.image_url;
      imageHtml = '<div class="message-image" onclick="openImageViewer(\'' + this.escapeAttr(data.image_url) + '\')"><img src="' + this.escapeAttr(thumbUrl) + '" class="chat-thumbnail" loading="lazy"></div>';
    }

    // 텍스트
    var contentHtml = "";
    if (data.content) {
      contentHtml = '<div class="message-content">' + this.escapeHtml(data.content) + '</div>';
    }

    messageDiv.innerHTML =
      '<div class="message-bubble-wrapper">' +
        nicknameHtml +
        '<div class="message-content-wrapper">' +
          imageHtml +
          contentHtml +
        '</div>' +
        '<div class="message-info">' +
          reportBtnHtml +
          readStatusHtml +
          '<span class="message-time">' + data.created_at + '</span>' +
        '</div>' +
      '</div>';

    return messageDiv;
  },

  updateReadStatus: function(messageId, readCount) {
    var messageDiv = document.querySelector('[data-message-id="' + messageId + '"]');
    if (messageDiv) {
      var readStatus = messageDiv.querySelector(".read-status");
      if (readStatus) {
        readStatus.setAttribute("data-read-count", readCount);
        if (readCount > 1) {
          readStatus.innerHTML = '<span class="checkmark double">✓✓</span>';
        } else {
          readStatus.innerHTML = '<span class="checkmark single">✓</span>';
        }
      }
    }
  },

  markMessageAsRead: function(messageId) {
    var csrfMeta = document.querySelector('meta[name="csrf-token"]');
    var csrfToken = csrfMeta ? csrfMeta.getAttribute("content") : "";

    var xhr = new XMLHttpRequest();
    xhr.open("POST", "/messages/mark_read", true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.setRequestHeader("X-CSRF-Token", csrfToken);
    xhr.send(JSON.stringify({ message_ids: [messageId] }));
  },

  markUnreadMessages: function() {
    var messages = document.querySelectorAll(".message:not(.message-mine)");
    var messageIds = [];
    for (var i = 0; i < messages.length; i++) {
      var id = messages[i].getAttribute("data-message-id");
      if (id) messageIds.push(id);
    }

    if (messageIds.length > 0) {
      var csrfMeta = document.querySelector('meta[name="csrf-token"]');
      var csrfToken = csrfMeta ? csrfMeta.getAttribute("content") : "";

      var xhr = new XMLHttpRequest();
      xhr.open("POST", "/messages/mark_read", true);
      xhr.setRequestHeader("Content-Type", "application/json");
      xhr.setRequestHeader("X-CSRF-Token", csrfToken);
      xhr.send(JSON.stringify({ message_ids: messageIds }));
    }
  },

  escapeHtml: function(text) {
    var div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  },

  escapeAttr: function(text) {
    return text.replace(/&/g, "&amp;").replace(/'/g, "&#39;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  },

  scrollToBottom: function() {
    var messagesContainer = document.getElementById("messages");
    if (messagesContainer) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  }
});
