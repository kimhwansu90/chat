import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column"]

  dragStart(event) {
    const card = event.currentTarget
    card.classList.add("dragging")
    event.dataTransfer.setData("text/plain", card.dataset.leadId)
    event.dataTransfer.effectAllowed = "move"
  }

  dragEnd(event) {
    event.currentTarget.classList.remove("dragging")
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
    const card = document.getElementById(`lead_${leadId}`)

    if (!card || !leadId || !newStatus) return

    const originalParent = card.parentElement
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
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": csrfToken,
          "Accept": "application/json"
        },
        body: `status=${encodeURIComponent(newStatus)}`
      })

      if (response.ok) {
        return true
      } else {
        const data = await response.json().catch(() => ({}))
        console.error("Status update failed:", data.error || response.status)
        return false
      }
    } catch (error) {
      console.error("Network error:", error)
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
