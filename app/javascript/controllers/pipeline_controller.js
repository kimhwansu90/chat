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
    event.currentTarget.classList.remove("drag-over")
  }

  drop(event) {
    event.preventDefault()
    const column = event.currentTarget
    column.classList.remove("drag-over")

    const leadId = event.dataTransfer.getData("text/plain")
    const newStatus = column.dataset.status
    const card = document.getElementById(`lead_${leadId}`)

    if (card) {
      column.appendChild(card)
      this.updateLeadStatus(leadId, newStatus)
    }
  }

  async updateLeadStatus(leadId, newStatus) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch(`/admin/leads/${leadId}/update_status`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": csrfToken
        },
        body: `status=${newStatus}`
      })

      if (!response.ok) {
        window.location.reload()
      }
    } catch (error) {
      window.location.reload()
    }
  }
}
