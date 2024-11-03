import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="videobooth-form"
export default class extends Controller {
  static targets = ["overlayImg", "overlayInput", "overlayVideo", "overlayVideoInput", "music", "musicInput"]

  connect() {
    // Event listener for overlay and overlay changes in the input file field
    if (this.hasOverlayInputTarget) {
      this.overlayInputTarget.addEventListener('change', (event) => this.handleOverlayChange(event));
    }
    if (this.hasOverlayVideoInputTaeget) {
      this.overlayVideoInputTarget.addEventListener('change', (event) => this.handleOverlayVideoChange(event));
    }
    if (this.hasMusicInputTarget) {
      this.musicInputTarget.addEventListener('change', (event) => this.handleMusicChange(event));
    }
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

  handleOverlayVideoChange(event) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const videoElement = this.overlayVideoTarget;
        videoElement.src = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  }

  handleMusicChange(event) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const musicElement = this.musicTarget;
        musicElement.src = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  }
}