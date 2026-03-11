import consumer from "channels/consumer"

var conversationSubscription = null;
var currentConversationId = null;

function ensureConversationSubscription() {
  var messagesContainer = document.getElementById("messages");
  if (!messagesContainer) {
    if (conversationSubscription) {
      consumer.subscriptions.remove(conversationSubscription);
      conversationSubscription = null;
      currentConversationId = null;
    }
    return;
  }

  var conversationId = messagesContainer.getAttribute("data-conversation-id");
  if (!conversationId) return;

  if (conversationSubscription && currentConversationId === conversationId) {
    scrollToBottom();
    markAllRead(conversationId);
    return;
  }

  if (conversationSubscription) {
    consumer.subscriptions.remove(conversationSubscription);
    conversationSubscription = null;
  }

  currentConversationId = conversationId;

  conversationSubscription = consumer.subscriptions.create(
    { channel: "ConversationChannel", conversation_id: conversationId },
    {
      connected: function() {
        console.log("[ActionCable] ConversationChannel connected:", conversationId);
        scrollToBottom();
        markAllRead(conversationId);
      },

      disconnected: function() {
        console.log("[ActionCable] ConversationChannel disconnected");
      },

      rejected: function() {
        console.log("[ActionCable] ConversationChannel rejected");
        conversationSubscription = null;
        currentConversationId = null;
      },

      received: function(data) {
        if (data.type === "read_receipt") {
          updateAllReadStatus();
          return;
        }

        if (data.type === "user_kicked") {
          if (data.username === window.currentUser) {
            alert("관리자에 의해 퇴장되었습니다.");
            window.location.href = "/login";
          }
          return;
        }

        if (data.type === "message_deleted") {
          var msgEl = document.querySelector('[data-message-id="' + data.message_id + '"]');
          if (msgEl) msgEl.remove();
          return;
        }

        var container = document.getElementById("messages");
        if (container) {
          addDateDividerIfNeeded(container);
          var messageDiv = createMessageElement(data);
          container.appendChild(messageDiv);
          scrollToBottom();

          if (data.username !== window.currentUser) {
            markAllRead(conversationId);
          }
        }
      }
    }
  );
}

function toISODateStr(date) {
  return date.getFullYear() + '-' + String(date.getMonth() + 1).padStart(2, '0') + '-' + String(date.getDate()).padStart(2, '0');
}

function createMessageElement(data) {
  var today = toISODateStr(new Date());
  var isMine = data.username === window.currentUser;

  if (data.message_type === "system") {
    var sysDiv = document.createElement("div");
    sysDiv.className = "system-message";
    sysDiv.setAttribute("data-message-id", data.id);
    sysDiv.innerHTML = '<span class="system-message-text">' + escapeHtml(data.content) + '</span>';
    return sysDiv;
  }

  var messageDiv = document.createElement("div");
  messageDiv.className = isMine ? "message message-mine" : "message";
  messageDiv.setAttribute("data-message-id", data.id);
  messageDiv.setAttribute("data-date", today);

  var nicknameHtml = "";
  if (!isMine) {
    nicknameHtml = '<div class="message-sender">' + escapeHtml(data.nickname || data.username) + '</div>';
  }

  var readStatusHtml = "";
  if (isMine) {
    readStatusHtml = '<span class="read-status"><span class="checkmark single">1</span></span>';
  }

  var imageHtml = "";
  if (data.image_url) {
    var thumbUrl = data.image_thumbnail_url || data.image_url;
    imageHtml = '<div class="message-image" onclick="openImageViewer(\'' + escapeAttr(data.image_url) + '\')"><img src="' + escapeAttr(thumbUrl) + '" class="chat-thumbnail" loading="lazy"></div>';
  }

  var contentHtml = "";
  if (data.content) {
    contentHtml = '<div class="message-content">' + escapeHtml(data.content) + '</div>';
  }

  messageDiv.innerHTML =
    '<div class="message-bubble-wrapper">' +
      nicknameHtml +
      '<div class="message-content-wrapper">' +
        imageHtml +
        contentHtml +
      '</div>' +
      '<div class="message-info">' +
        readStatusHtml +
        '<span class="message-time">' + data.created_at + '</span>' +
      '</div>' +
    '</div>';

  return messageDiv;
}

function addDateDividerIfNeeded(container) {
  var today = new Date();
  var weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  var todayStr = today.getFullYear() + '년 ' + (today.getMonth() + 1) + '월 ' + today.getDate() + '일 ' + weekdays[today.getDay()] + '요일';
  var todayDate = toISODateStr(today);

  var existingDividers = container.querySelectorAll(".date-divider");
  var hasTodayDivider = false;
  existingDividers.forEach(function(divider) {
    if (divider.getAttribute("data-date") === todayDate) {
      hasTodayDivider = true;
    }
  });

  if (!hasTodayDivider) {
    var messages = container.querySelectorAll(".message");
    if (messages.length > 0) {
      var lastMessage = messages[messages.length - 1];
      var lastMessageDate = lastMessage.getAttribute("data-date");
      if (lastMessageDate === todayDate) return;
    }

    var divider = document.createElement("div");
    divider.className = "date-divider";
    divider.setAttribute("data-date", todayDate);
    divider.innerHTML = '<span class="date-divider-text">' + escapeHtml(todayStr) + '</span>';
    container.appendChild(divider);
  }
}

function updateAllReadStatus() {
  var readStatuses = document.querySelectorAll(".read-status");
  readStatuses.forEach(function(el) {
    el.innerHTML = '<span class="checkmark double"></span>';
  });
}

function markAllRead(conversationId) {
  var csrfMeta = document.querySelector('meta[name="csrf-token"]');
  var csrfToken = csrfMeta ? csrfMeta.getAttribute("content") : "";

  var xhr = new XMLHttpRequest();
  xhr.open("POST", "/conversations/" + conversationId + "/mark_read", true);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.setRequestHeader("X-CSRF-Token", csrfToken);
  xhr.send(JSON.stringify({}));
}

function scrollToBottom() {
  var messagesContainer = document.getElementById("messages");
  if (messagesContainer) {
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
  }
}

function escapeHtml(text) {
  var div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

function escapeAttr(text) {
  return text.replace(/&/g, "&amp;").replace(/'/g, "&#39;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

document.addEventListener("turbo:load", ensureConversationSubscription);
document.addEventListener("DOMContentLoaded", ensureConversationSubscription);

if (document.readyState !== "loading") {
  ensureConversationSubscription();
}
