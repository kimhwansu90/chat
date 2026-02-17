import consumer from "channels/consumer"

// 관리자 페이지에서만 구독
if (document.querySelector(".admin-layout")) {
  consumer.subscriptions.create("AdminChannel", {
    connected: function() {
      console.log("관리자 채널에 연결되었습니다");
    },

    disconnected: function() {
      console.log("관리자 채널 연결이 끊어졌습니다");
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
