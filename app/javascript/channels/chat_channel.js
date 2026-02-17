import consumer from "channels/consumer"

consumer.subscriptions.create("ChatChannel", {
  connected() {
    console.log("채팅 채널에 연결되었습니다");
    this.markUnreadMessages();
  },

  disconnected() {
    console.log("채팅 채널 연결이 끊어졌습니다");
  },

  received(data) {
    console.log("데이터 수신:", data);

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
      const msgEl = document.querySelector('[data-message-id="' + data.message_id + '"]');
      if (msgEl) {
        msgEl.remove();
      }
      return;
    }

    // 새 메시지 수신
    const messagesContainer = document.getElementById("messages");
    if (messagesContainer) {
      this.addDateDividerIfNeeded();

      const messageDiv = this.createMessageElement(data);
      messagesContainer.appendChild(messageDiv);
      this.scrollToBottom();

      if (data.username !== window.currentUser) {
        this.markMessageAsRead(data.id);
      }
    }
  },

  addDateDividerIfNeeded() {
    const messagesContainer = document.getElementById("messages");
    const messages = messagesContainer.querySelectorAll(".message");
    const today = new Date();
    const todayStr = today.toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' });

    const existingDividers = messagesContainer.querySelectorAll(".date-divider");
    const todayDate = today.toDateString();
    let hasTodayDivider = false;

    existingDividers.forEach(divider => {
      if (divider.getAttribute("data-date") === todayDate) {
        hasTodayDivider = true;
      }
    });

    if (messages.length > 0) {
      const lastMessage = messages[messages.length - 1];
      const lastMessageDate = lastMessage.getAttribute("data-date");

      if (lastMessageDate !== todayDate && !hasTodayDivider) {
        const divider = document.createElement("div");
        divider.className = "date-divider";
        divider.setAttribute("data-date", todayDate);
        divider.innerHTML = `<span class="date-divider-text">${todayStr}</span>`;
        messagesContainer.appendChild(divider);
      }
    } else if (!hasTodayDivider) {
      const divider = document.createElement("div");
      divider.className = "date-divider";
      divider.setAttribute("data-date", todayDate);
      divider.innerHTML = `<span class="date-divider-text">${todayStr}</span>`;
      messagesContainer.appendChild(divider);
    }
  },

  createMessageElement(data) {
    const today = new Date().toDateString();
    const isMine = data.username === window.currentUser;

    // 시스템 메시지
    if (data.message_type === "system") {
      const sysDiv = document.createElement("div");
      sysDiv.className = "system-message";
      sysDiv.setAttribute("data-message-id", data.id);
      sysDiv.innerHTML = `<span class="system-message-text">${this.escapeHtml(data.content)}</span>`;
      return sysDiv;
    }

    const messageDiv = document.createElement("div");
    messageDiv.className = isMine ? "message message-mine" : "message";
    messageDiv.setAttribute("data-message-id", data.id);
    messageDiv.setAttribute("data-date", today);

    const nicknameHtml = !isMine ? `<div class="message-sender">${this.escapeHtml(data.nickname || data.username)}</div>` : '';

    const readStatusHtml = isMine ? `
      <span class="read-status" data-read-count="${data.read_count || 1}">
        ${data.read_count > 1 ? '<span class="checkmark double">✓✓</span>' : '<span class="checkmark single">✓</span>'}
      </span>
    ` : '';

    // 신고 버튼 (상대방 메시지에만)
    const reportBtnHtml = !isMine ? `<button class="btn-report" onclick="reportMessage(${data.id})" title="신고">⚠️</button>` : '';

    // 이미지 HTML
    let imageHtml = '';
    if (data.image_url) {
      const thumbUrl = data.image_thumbnail_url || data.image_url;
      imageHtml = `<div class="message-image" onclick="openImageViewer('${this.escapeAttr(data.image_url)}')"><img src="${this.escapeAttr(thumbUrl)}" class="chat-thumbnail" loading="lazy"></div>`;
    }

    // 텍스트 HTML
    let contentHtml = '';
    if (data.content) {
      contentHtml = `<div class="message-content">${this.escapeHtml(data.content)}</div>`;
    }

    messageDiv.innerHTML = `
      <div class="message-bubble-wrapper">
        ${nicknameHtml}
        <div class="message-content-wrapper">
          ${imageHtml}
          ${contentHtml}
        </div>
        <div class="message-info">
          ${reportBtnHtml}
          ${readStatusHtml}
          <span class="message-time">${data.created_at}</span>
        </div>
      </div>
    `;

    return messageDiv;
  },

  updateReadStatus(messageId, readCount) {
    const messageDiv = document.querySelector(`[data-message-id="${messageId}"]`);
    if (messageDiv) {
      const readStatus = messageDiv.querySelector(".read-status");
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

  markMessageAsRead(messageId) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    fetch("/messages/mark_read", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({ message_ids: [messageId] })
    }).catch(error => {
      console.error("읽음 처리 오류:", error);
    });
  },

  markUnreadMessages() {
    const messages = document.querySelectorAll(".message:not(.message-mine)");
    const messageIds = Array.from(messages).map(msg => msg.getAttribute("data-message-id")).filter(id => id);

    if (messageIds.length > 0) {
      const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

      fetch("/messages/mark_read", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ message_ids: messageIds })
      }).catch(error => {
        console.error("읽음 처리 오류:", error);
      });
    }
  },

  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  },

  escapeAttr(text) {
    return text.replace(/&/g, '&amp;').replace(/'/g, '&#39;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  },

  scrollToBottom() {
    const messagesContainer = document.getElementById("messages");
    if (messagesContainer) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  }
});
