import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "addBtn"]

  addField() {
    const index = this.containerTarget.querySelectorAll(".form-field-row").length
    const template = this.buildFieldRow(index)
    this.containerTarget.insertAdjacentHTML("beforeend", template)
  }

  removeField(event) {
    const row = event.currentTarget.closest(".form-field-row")
    const destroyInput = row.querySelector("input[name*='_destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
      row.style.display = "none"
    } else {
      row.remove()
    }
  }

  buildFieldRow(index) {
    const prefix = `form[form_fields_attributes][${index}]`
    return `
      <div class="form-field-row" data-form-builder-target="field">
        <input type="text" name="${prefix}[label]" placeholder="라벨" required>
        <select name="${prefix}[field_type]">
          <option value="text">text</option>
          <option value="email">email</option>
          <option value="phone">phone</option>
          <option value="select">select</option>
          <option value="textarea">textarea</option>
        </select>
        <input type="text" name="${prefix}[name]" placeholder="필드명 (영문)">
        <label class="form-checkbox">
          <input type="hidden" name="${prefix}[required]" value="0">
          <input type="checkbox" name="${prefix}[required]" value="1"> 필수
        </label>
        <input type="hidden" name="${prefix}[position]" value="${index}">
        <button type="button" class="btn-remove-field" data-action="click->form-builder#removeField">&times;</button>
      </div>
    `
  }
}
