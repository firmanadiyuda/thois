import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ai-photobooth-form"
export default class extends Controller {
  static targets = ["overlayImg", "overlayInput"]

  connect() {
    // Event listener for overlay and overlay changes in the input file field
    this.overlayInputTarget.addEventListener('change', (event) => this.handleOverlayChange(event));
  }

  disconnect() {
  }

  handleOverlayChange(event) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const imgElement = this.overlayImgTarget;
        imgElement.src = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  }
}