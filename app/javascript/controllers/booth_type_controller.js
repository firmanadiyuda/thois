import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booth-type"
export default class extends Controller {
  static targets = ["photoboothForm", "spinboothForm"]

  connect() {
    this.toggleVisibility();
  }

  toggleVisibility() {
    const selectedValue = this.element.querySelector('input[name="event[booth_type]"]:checked')?.value;
    this.photoboothFormTarget.style.display = selectedValue == 0 ? "block" : "none";
    this.spinboothFormTarget.style.display = selectedValue == 1 ? "block" : "none";

  }
}