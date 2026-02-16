import consumer from "channels/consumer"

// ChatChannel 구독 - 실시간 메시지 수신
consumer.subscriptions.create("ChatChannel", {
  connected() {
    // 웹소켓 연결이 성공적으로 수립됨
    console.log("채팅 채널에 연결되었습니다");
    
    // 연결 후 읽지 않은 메시지 읽음 처리
    this.markUnreadMessages();
  },

  disconnected() {
    // 웹소켓 연결이 종료됨
    console.log("채팅 채널 연결이 끊어졌습니다");
  },

  received(data) {
    console.log("데이터 수신:", data);
    
    // 읽음 확인 업데이트인 경우
    if (data.type === "read_receipt") {
      this.updateReadStatus(data.message_id, data.read_count);
      return;
    }
    
    // 새 메시지 수신
    const messagesContainer = document.getElementById("messages");
    if (messagesContainer) {
      // 날짜 구분선 추가 (카카오톡 스타일)
      this.addDateDividerIfNeeded();
      
      const messageDiv = this.createMessageElement(data);
      messagesContainer.appendChild(messageDiv);
      
      // 스크롤을 맨 아래로 이동
      this.scrollToBottom();
      
      // 상대방 메시지면 읽음 처리
      if (data.username !== window.currentUser) {
        this.markMessageAsRead(data.id);
      }
    }
  },
  
  // 날짜가 바뀌면 날짜 구분선 추가 (카카오톡 스타일)
  addDateDividerIfNeeded() {
    const messagesContainer = document.getElementById("messages");
    const messages = messagesContainer.querySelectorAll(".message");
    const today = new Date();
    const todayStr = today.toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' });
    
    // 이미 오늘 날짜 구분선이 있는지 확인
    const existingDividers = messagesContainer.querySelectorAll(".date-divider");
    const todayDate = today.toDateString();
    let hasTodayDivider = false;
    
    existingDividers.forEach(divider => {
      if (divider.getAttribute("data-date") === todayDate) {
        hasTodayDivider = true;
      }
    });
    
    // 마지막 메시지의 날짜 확인
    if (messages.length > 0) {
      const lastMessage = messages[messages.length - 1];
      const lastMessageDate = lastMessage.getAttribute("data-date");
      
      // 마지막 메시지와 오늘 날짜가 다르고, 오늘 날짜 구분선이 없으면 추가
      if (lastMessageDate !== todayDate && !hasTodayDivider) {
        const divider = document.createElement("div");
        divider.className = "date-divider";
        divider.setAttribute("data-date", todayDate);
        divider.innerHTML = `<span class="date-divider-text">${todayStr}</span>`;
        messagesContainer.appendChild(divider);
      }
    } else if (!hasTodayDivider) {
      // 첫 메시지인 경우 날짜 구분선 추가
      const divider = document.createElement("div");
      divider.className = "date-divider";
      divider.setAttribute("data-date", todayDate);
      divider.innerHTML = `<span class="date-divider-text">${todayStr}</span>`;
      messagesContainer.appendChild(divider);
    }
  },
  
  // 메시지 HTML 엘리먼트 생성
  createMessageElement(data) {
    const messageDiv = document.createElement("div");
    const today = new Date().toDateString();
    
    // 내가 보낸 메시지인지 확인
    const isMine = data.username === window.currentUser;
    messageDiv.className = isMine ? "message message-mine" : "message";
    messageDiv.setAttribute("data-message-id", data.id);
    messageDiv.setAttribute("data-date", today);
    
    // 읽음 표시 HTML (내가 보낸 메시지에만 표시)
    const readStatusHtml = isMine ? `
      <span class="read-status" data-read-count="${data.read_count || 1}">
        ${data.read_count > 1 ? '<span class="checkmark double">✓✓</span>' : '<span class="checkmark single">✓</span>'}
      </span>
    ` : '';
    
    messageDiv.innerHTML = `
      <div class="message-bubble-wrapper">
        <div class="message-content-wrapper">
          <div class="message-content">
            ${this.escapeHtml(data.content)}
          </div>
        </div>
        <div class="message-info">
          ${readStatusHtml}
          <span class="message-time">${data.created_at}</span>
        </div>
      </div>
    `;
    
    return messageDiv;
  },
  
  // 읽음 상태 업데이트
  updateReadStatus(messageId, readCount) {
    const messageDiv = document.querySelector(`[data-message-id="${messageId}"]`);
    if (messageDiv) {
      const readStatus = messageDiv.querySelector(".read-status");
      if (readStatus) {
        readStatus.setAttribute("data-read-count", readCount);
        
        // 체크마크 업데이트
        if (readCount > 1) {
          readStatus.innerHTML = '<span class="checkmark double">✓✓</span>';
        } else {
          readStatus.innerHTML = '<span class="checkmark single">✓</span>';
        }
      }
    }
  },
  
  // 특정 메시지를 읽음 처리
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
  
  // 화면의 모든 읽지 않은 메시지 읽음 처리
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
  
  // XSS 방지를 위한 HTML 이스케이프
  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  },
  
  // 메시지 컨테이너를 맨 아래로 스크롤
  scrollToBottom() {
    const messagesContainer = document.getElementById("messages");
    if (messagesContainer) {
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  }
});
