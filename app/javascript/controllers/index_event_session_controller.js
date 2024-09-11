import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="booth-type"
export default class extends Controller {
  static targets = ["photoboothEvent", "videoboothEvent"]

  connect() {
    this.toggleVisibility();
  }

  toggleVisibility() {
    // const selectedValue = this.element.querySelector('input[name="event[booth_type]"]:checked')?.value;
    // const selectedValue = this.element.querySelector('input[name="event[booth_type]"]:checked')?.value;
    this.photoboothEventTarget.style.display = selectedValue == 'photobooth' ? "block" : "none";
    this.videoboothEventTarget.style.display = selectedValue == 'videobooth' ? "block" : "none";

  }
}