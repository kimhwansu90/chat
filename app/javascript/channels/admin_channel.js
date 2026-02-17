import consumer from "channels/consumer"

// Turbo 페이지 이동에 대응하는 구독 관리
var adminSubscription = null;

function ensureAdminSubscription() {
  if (!document.querySelector(".admin-layout")) return;

  if (adminSubscription) return;

  adminSubscription = consumer.subscriptions.create("AdminChannel", {
    connected: function() {
      console.log("[ActionCable] AdminChannel connected");
    },

    disconnected: function() {
      console.log("[ActionCable] AdminChannel disconnected");
    },

    rejected: function() {
      console.log("[ActionCable] AdminChannel rejected");
      adminSubscription = null;
    },

    received: function(data) {
      if (data.type === "online_users") {
        var countEl = document.getElementById("online-count");
        if (countEl) {
          countEl.textContent = data.count;
        }

        var listEl = document.getElementById("online-users-list");
        if (listEl) {
          if (data.users.length > 0) {
            var html = "";
            for (var i = 0; i < data.users.length; i++) {
              html += '<span class="online-user-tag">' + data.users[i] + "</span>";
            }
            listEl.innerHTML = html;
          } else {
            listEl.innerHTML = '<p class="admin-empty">접속자가 없습니다.</p>';
          }
        }
      }

      if (data.type === "new_report") {
        var badge = document.getElementById("report-badge");
        if (badge) {
          badge.textContent = data.count;
          badge.style.display = "inline-flex";
        }

        var pending = document.getElementById("pending-reports");
        if (pending) {
          pending.textContent = data.count;
        }
      }
    }
  });
}

// Turbo 페이지 이동 시 구독 확인
document.addEventListener("turbo:load", ensureAdminSubscription);
document.addEventListener("DOMContentLoaded", ensureAdminSubscription);

if (document.readyState !== "loading") {
  ensureAdminSubscription();
}
