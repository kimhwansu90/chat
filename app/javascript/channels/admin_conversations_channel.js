import consumer from "channels/consumer"

var adminConversationsSubscription = null;

function ensureAdminConversationsSubscription() {
  var chatList = document.getElementById("conversation-list");
  if (!chatList) {
    if (adminConversationsSubscription) {
      consumer.subscriptions.remove(adminConversationsSubscription);
      adminConversationsSubscription = null;
    }
    return;
  }
  if (adminConversationsSubscription) return;

  adminConversationsSubscription = consumer.subscriptions.create(
    "AdminConversationsChannel",
    {
      connected: function() {
        console.log("[ActionCable] AdminConversationsChannel connected");
      },

      received: function(data) {
        if (data.type === "new_message") {
          var item = document.querySelector(
            '[data-conversation-id="' + data.conversation_id + '"]'
          );
          if (item) {
            var preview = item.querySelector(".conversation-preview");
            if (preview) preview.textContent = data.preview;

            var badge = item.querySelector(".unread-badge");
            if (badge) {
              badge.textContent = data.unread_count;
              badge.style.display = data.unread_count > 0 ? "flex" : "none";
            }

            var time = item.querySelector(".conversation-time");
            if (time) time.textContent = data.last_message_at;

            chatList.prepend(item);
          }
        }
      }
    }
  );
}

document.addEventListener("turbo:load", ensureAdminConversationsSubscription);
document.addEventListener("DOMContentLoaded", ensureAdminConversationsSubscription);

if (document.readyState !== "loading") {
  ensureAdminConversationsSubscription();
}
