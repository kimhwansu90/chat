import consumer from "channels/consumer"

consumer.subscriptions.create("LeadNotificationChannel", {
  received(data) {
    if (data.type === "new_lead") {
      showToast(`새 리드: ${data.name}`, data.source ? `채널: ${data.source}` : "직접 유입")

      // Navigate to lead detail on click
      const toast = document.querySelector(".toast:last-child")
      if (toast && data.lead_id) {
        toast.addEventListener("click", () => {
          window.location.href = `/admin/leads/${data.lead_id}`
        })
      }
    }
  }
})

function showToast(title, body) {
  let container = document.querySelector(".toast-container")
  if (!container) {
    container = document.createElement("div")
    container.className = "toast-container"
    document.body.appendChild(container)
  }

  const toast = document.createElement("div")
  toast.className = "toast"
  toast.innerHTML = `
    <div class="toast-title">${escapeHtml(title)}</div>
    <div class="toast-body">${escapeHtml(body)}</div>
  `
  container.appendChild(toast)

  setTimeout(() => {
    toast.style.transition = "opacity 0.3s"
    toast.style.opacity = "0"
    setTimeout(() => toast.remove(), 300)
  }, 5000)
}

function escapeHtml(text) {
  const div = document.createElement("div")
  div.textContent = text
  return div.innerHTML
}
