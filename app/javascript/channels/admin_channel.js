import consumer from "channels/consumer"

// 관리자 페이지에서만 구독
if (document.querySelector('.admin-layout')) {
  consumer.subscriptions.create("AdminChannel", {
    connected() {
      console.log("관리자 채널에 연결되었습니다");
    },

    disconnected() {
      console.log("관리자 채널 연결이 끊어졌습니다");
    },

    received(data) {
      console.log("관리자 데이터 수신:", data);

      if (data.type === "online_users") {
        const countEl = document.getElementById("online-count");
        if (countEl) {
          countEl.textContent = data.count;
        }

        const listEl = document.getElementById("online-users-list");
        if (listEl) {
          if (data.users.length > 0) {
            listEl.innerHTML = data.users.map(u =>
              `<span class="online-user-tag">${u}</span>`
            ).join("");
          } else {
            listEl.innerHTML = '<p class="admin-empty">접속자가 없습니다.</p>';
          }
        }
      }

      if (data.type === "new_report") {
        const badge = document.getElementById("report-badge");
        if (badge) {
          badge.textContent = data.count;
          badge.style.display = "inline-flex";
        }

        const pending = document.getElementById("pending-reports");
        if (pending) {
          pending.textContent = data.count;
        }
      }
    }
  });
}
