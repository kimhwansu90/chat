import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column"]

  dragStart(event) {
    // 링크 기본 드래그(URL 드래그) 방지
    event.stopPropagation()
    const card = event.currentTarget
    const leadId = card.dataset.leadId
    card.classList.add("dragging")
    event.dataTransfer.clearData()
    event.dataTransfer.setData("text/plain", leadId)
    event.dataTransfer.effectAllowed = "move"
    console.log("[Pipeline] dragStart leadId=", leadId)
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
    console.log("[Pipeline] drop leadId=", leadId, "newStatus=", newStatus)

    if (!leadId || !newStatus) {
      console.warn("[Pipeline] drop aborted: missing leadId or newStatus")
      return
    }

    const card = document.getElementById(`lead_${leadId}`)
    if (!card) {
      console.warn("[Pipeline] drop aborted: card not found for lead_" + leadId)
      return
    }

    const originalParent = card.parentElement
    column.appendChild(card)

    const ok = await this.updateLeadStatus(leadId, newStatus)
    if (!ok) {
      console.error("[Pipeline] status update failed, reverting card")
      originalParent.appendChild(card)
    } else {
      console.log("[Pipeline] status updated successfully")
      this.updateColumnCounts()
    }
  }

  async updateLeadStatus(leadId, newStatus) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    if (!csrfToken) {
      console.error("[Pipeline] CSRF token not found")
      return false
    }

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
      console.log("[Pipeline] server response:", response.status, data)

      if (response.ok && data.ok) {
        return true
      } else {
        console.error("[Pipeline] server error:", data.error || response.status)
        return false
      }
    } catch (error) {
      console.error("[Pipeline] network error:", error)
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
