import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="booth-type"
export default class extends Controller {
  static targets = ["photoboothForm", "aiPhotoboothForm", "videoboothForm", "weddingForm"];

  connect() {
    this.toggleVisibility();
  }

  toggleVisibility() {
    const selectedValue = this.element.querySelector(
      'input[name="event[booth_type]"]:checked'
    )?.value;

    this.photoboothFormTarget.style.display = selectedValue == "photobooth" ? "block" : "none";
    this.aiPhotoboothFormTarget.style.display = selectedValue == "ai_photobooth" ? "block" : "none";
    this.videoboothFormTarget.style.display = selectedValue == "videobooth" ? "block" : "none";
    this.weddingFormTarget.style.display = selectedValue == "wedding" ? "block" : "none";
  }
}
