import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column"]

  connect() {
    this._dragging = false
  }

  // ─── 카드 이벤트 ────────────────────────────────────────────
  dragStart(event) {
    this._dragging = true
    const card = event.currentTarget
    card.classList.add("dragging")
    event.dataTransfer.setData("text/plain", card.dataset.leadId)
    event.dataTransfer.effectAllowed = "move"
  }

  dragEnd(event) {
    event.currentTarget.classList.remove("dragging")
    setTimeout(() => { this._dragging = false }, 100)
  }

  openLead(event) {
    if (this._dragging) return
    const href = event.currentTarget.dataset.href
    if (href) window.location.href = href
  }

  // 카드 위에 드래그할 때 – 부모 컬럼으로 위임
  cardDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    const column = event.currentTarget.closest(".pipeline-column-body")
    if (column) column.classList.add("drag-over")
  }

  // 카드 위에 드롭할 때 – 부모 컬럼을 대상으로 처리
  cardDrop(event) {
    event.preventDefault()
    event.stopPropagation()            // 컬럼 drop �핸들러 중복 방지
    const column = event.currentTarget.closest(".pipeline-column-body")
    if (column) this.processDropOnColumn(event, column)
  }

  // ─── 컬럼 이벤트 (빈 공간에 드롭 시) ───────────────────────
  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    event.currentTarget.classList.add("drag-over")
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

  drop(event) {
    event.preventDefault()
    this.processDropOnColumn(event, event.currentTarget)
  }

  // ─── 공통 처리 ──────────────────────────────────────────────
  async processDropOnColumn(event, column) {
    column.classList.remove("drag-over")
    // 모든 컬럼의 drag-over 클래스 정리
    this.columnTargets.forEach(c => c.classList.remove("drag-over"))

    const leadId = event.dataTransfer.getData("text/plain")
    const newStatus = column.dataset.status

    if (!leadId || !newStatus) return

    const card = document.getElementById(`lead_${leadId}`)
    if (!card) return

    const originalParent = card.parentElement
    if (originalParent === column) return   // 같은 컬럼이면 무시

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
