import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column"]

  connect() {
    this._draggedCard = null
    this._draggedCardId = null
    this._originalColumn = null
    this._processing = false
  }

  // ─── 카드 이벤트 ─────────────────────────────────────────────

  dragStart(event) {
    const card = event.currentTarget
    this._draggedCard = card
    this._draggedCardId = card.dataset.leadId
    this._originalColumn = card.closest(".pipeline-column-body")
    this._processing = false

    card.classList.add("dragging")
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this._draggedCardId)
  }

  dragEnd(event) {
    event.currentTarget.classList.remove("dragging")
    this.columnTargets.forEach(col => col.classList.remove("drag-over"))

    setTimeout(() => {
      this._draggedCard = null
      this._draggedCardId = null
      this._originalColumn = null
      this._processing = false
    }, 50)
  }

  openLead(event) {
    if (this._draggedCard) return
    const href = event.currentTarget.dataset.href
    if (href) window.location.href = href
  }

  // ─── 컬럼 이벤트 ─────────────────────────────────────────────

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  dragEnter(event) {
    event.preventDefault()
    event.currentTarget.classList.add("drag-over")
  }

  dragLeave(event) {
    const column = event.currentTarget
    if (!column.contains(event.relatedTarget)) {
      column.classList.remove("drag-over")
    }
  }

  async drop(event) {
    event.preventDefault()
    const column = event.currentTarget
    column.classList.remove("drag-over")
    this.columnTargets.forEach(c => c.classList.remove("drag-over"))

    if (this._processing) return

    // 인스턴스 변수 우선, fallback으로 dataTransfer
    const leadId = this._draggedCardId || event.dataTransfer.getData("text/plain")
    const card = this._draggedCard || document.getElementById(`lead_${leadId}`)
    if (!leadId || !card) return

    const newStatus = column.dataset.status
    if (!newStatus) return

    const originalColumn = this._originalColumn || card.closest(".pipeline-column-body")
    if (originalColumn === column) return

    this._processing = true

    // 낙관적 UI 업데이트
    column.appendChild(card)
    this._updateColumnCounts()

    const ok = await this._updateLeadStatus(leadId, newStatus)
    if (!ok) {
      originalColumn.appendChild(card)
      this._updateColumnCounts()
    }
  }

  // ─── 내부 메서드 ─────────────────────────────────────────────

  async _updateLeadStatus(leadId, newStatus) {
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

  _updateColumnCounts() {
    this.columnTargets.forEach(column => {
      const header = column.closest(".pipeline-column")
        ?.querySelector(".pipeline-column-count")
      if (header) {
        header.textContent = column.querySelectorAll(".lead-card").length
      }
    })
  }
}
