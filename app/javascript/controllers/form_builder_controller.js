import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "addBtn"]

  addField() {
    const index = this.containerTarget.querySelectorAll(".fb-field-card").length
    const template = this.buildFieldCard(index)
    this.containerTarget.insertAdjacentHTML("beforeend", template)
  }

  removeField(event) {
    const card = event.currentTarget.closest(".fb-field-card")
    const destroyInput = card.querySelector("input[name*='_destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
      card.style.display = "none"
    } else {
      card.remove()
    }
  }

  buildFieldCard(index) {
    const prefix = `form[form_fields_attributes][${index}]`
    return `
      <div class="fb-field-card" data-form-builder-target="field">
        <div class="fb-field-header">
          <span class="fb-field-label">새 필드</span>
          <button type="button" class="btn-remove-field" data-action="click->form-builder#removeField">&times;</button>
        </div>
        <div class="fb-field-grid">
          <div>
            <label class="fb-label">라벨 *</label>
            <input type="text" name="${prefix}[label]" class="fb-input" placeholder="예: 상호명" required>
          </div>
          <div>
            <label class="fb-label">필드 유형</label>
            <select name="${prefix}[field_type]" class="fb-select">
              <option value="text">텍스트</option>
              <option value="email">이메일</option>
              <option value="phone">전화번호</option>
              <option value="select">드롭다운</option>
              <option value="textarea">텍스트박스</option>
              <option value="privacy_checkbox">개인정보동의</option>
            </select>
          </div>
          <div>
            <label class="fb-label">필드명 (영문, 저장 키)</label>
            <input type="text" name="${prefix}[name]" class="fb-input" placeholder="예: company_name">
          </div>
          <div>
            <label class="fb-label">플레이스홀더</label>
            <input type="text" name="${prefix}[placeholder]" class="fb-input" placeholder="입력 안내 문구">
          </div>
        </div>
        <div class="fb-field-bottom">
          <div>
            <label class="fb-label">선택지 (select 유형, 쉼표 구분)</label>
            <input type="text" name="${prefix}[options]" class="fb-input" placeholder="옵션1,옵션2,옵션3">
          </div>
          <div>
            <label class="fb-label">설명 (필드 아래 표시)</label>
            <input type="text" name="${prefix}[subtitle]" class="fb-input" placeholder="추가 안내 문구">
          </div>
        </div>
        <div class="fb-field-checks">
          <label class="form-checkbox">
            <input type="hidden" name="${prefix}[required]" value="0">
            <input type="checkbox" name="${prefix}[required]" value="1"> 필수 입력
          </label>
          <label class="form-checkbox">
            <input type="hidden" name="${prefix}[half_width]" value="0">
            <input type="checkbox" name="${prefix}[half_width]" value="1"> 2열 배치
          </label>
        </div>
        <input type="hidden" name="${prefix}[position]" value="${index}">
      </div>
    `
  }
}
