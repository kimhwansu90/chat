import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column"]

  connect() {
    this._dragging = false
  }

  dragStart(event) {
    this._dragging = true
    const card = event.currentTarget
    const leadId = card.dataset.leadId
    card.classList.add("dragging")
    // <div>이므로 URL 충돌 없음. text/plain에 ID만 세팅
    event.dataTransfer.setData("text/plain", leadId)
    event.dataTransfer.effectAllowed = "move"
  }

  dragEnd(event) {
    event.currentTarget.classList.remove("dragging")
    // 드래그 종료 후 짧은 시간 후 클릭 방지 플래그 해제
    setTimeout(() => { this._dragging = false }, 100)
  }

  // 드래그 중이 아닐 때만 카드 클릭 → 상세 페이지 이동
  openLead(event) {
    if (this._dragging) return
    const href = event.currentTarget.dataset.href
    if (href) window.location.href = href
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  dragEnter(event) {
    event.preventDefault()
    event.currentTarget.classList.add("drag-over")
  }

  dragLeave(event) {
    if (!event.currentTarget.contains(event.relatedTarget)) {
      event.currentTarget.classList.remove("drag-over")
    }
  }

  async drop(event) {
    event.preventDefault()
    const column = event.currentTarget
    column.classList.remove("drag-over")

    const leadId = event.dataTransfer.getData("text/plain")
    const newStatus = column.dataset.status

    if (!leadId || !newStatus) return

    const card = document.getElementById(`lead_${leadId}`)
    if (!card) return

    const originalParent = card.parentElement
    // 같은 컬럼이면 무시
    if (originalParent === column) return

    column.appendChild(card)

    const ok = await this.updateLeadStatus(leadId, newStatus)
    if (!ok) {
      originalParent.appendChild(card)
    } else {
      this.updateColumnCounts()
    }
  }

  async updateLeadStatus(leadId, newStatus) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(`/admin/leads/${leadId}/update_status`, {
        method: "PATCH",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: `status=${encodeURIComponent(newStatus)}`
      })

      const data = await response.json().catch(() => ({}))
      return response.ok && data.ok
    } catch {
      return false
    }
  }

  updateColumnCounts() {
    this.columnTargets.forEach(column => {
      const header = column.closest(".pipeline-column")?.querySelector(".pipeline-column-count")
      if (header) {
        header.textContent = column.querySelectorAll(".lead-card").length
      }
    })
  }
}
