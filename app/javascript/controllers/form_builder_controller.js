import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "addBtn"]

  addField() {
    const index = this.containerTarget.querySelectorAll(".fb-simple-row").length +
                  this.containerTarget.querySelectorAll(".fb-field-card").length
    const template = this._buildRow(index)
    this.containerTarget.insertAdjacentHTML("beforeend", template)
  }

  removeField(event) {
    const row = event.currentTarget.closest(".fb-simple-row") ||
                event.currentTarget.closest(".fb-field-card")
    if (!row) return

    const destroyInput = row.querySelector("input[name*='_destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
      row.style.display = "none"
    } else {
      row.remove()
    }
  }

  _buildRow(index) {
    const prefix = `form[form_fields_attributes][${index}]`
    return `
      <div class="fb-simple-row" data-form-builder-target="field">
        <div class="fb-simple-grip">&#x2630;</div>
        <div class="fb-simple-label">
          <input type="text" name="${prefix}[label]" class="fb-input" placeholder="질문 입력" required>
        </div>
        <div class="fb-simple-type">
          <select name="${prefix}[field_type]" class="fb-select">
            <option value="text">텍스트</option>
            <option value="email">이메일</option>
            <option value="phone">전화번호</option>
            <option value="select">드롭다운</option>
            <option value="textarea">서술형</option>
            <option value="button_select">버튼선택</option>
          </select>
        </div>
        <div class="fb-simple-options">
          <input type="text" name="${prefix}[options]" class="fb-input" placeholder="선택지 (쉼표 구분)">
        </div>
        <label class="fb-simple-check">
          <input type="hidden" name="${prefix}[required]" value="0">
          <input type="checkbox" name="${prefix}[required]" value="1"> 필수
        </label>
        <button type="button" class="btn-remove-sm" data-action="click->form-builder#removeField">&times;</button>
        <input type="hidden" name="${prefix}[name]" value="field_${index}">
        <input type="hidden" name="${prefix}[position]" value="${index}">
        <input type="hidden" name="${prefix}[placeholder]" value="">
        <input type="hidden" name="${prefix}[subtitle]" value="">
        <input type="hidden" name="${prefix}[half_width]" value="0">
      </div>
    `
  }
}
