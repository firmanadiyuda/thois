import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ai-theme"
export default class extends Controller {
  static targets = ["previewInput", "removeCheckbox"];

  connect() {
    this.previewInputTarget.addEventListener("change", this.toggleCheckbox.bind(this));
  }

  disconnect() {
  }

  toggleCheckbox() {
    if (this.previewInputTarget.files.length > 0) {
      this.removeCheckboxTarget.checked = true;
    } else {
      this.removeCheckboxTarget.checked = false;
    }
  }
}