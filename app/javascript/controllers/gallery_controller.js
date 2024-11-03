import { Controller } from "@hotwired/stimulus";

var viewQR = true;

// Connects to data-controller="gallery"
export default class extends Controller {
  static targets = ["qrelement", "qrImage", "thumbVideo"];

  connect() {
    this.toggleVisibility();
  }

  toggleVisibility() {
    if (viewQR) {
      viewQR = false
      this.qrelementTarget.classList.add('hidden')
    } else {
      viewQR = true
      this.qrelementTarget.classList.remove('hidden')
    }
  }

  showQR(event) {
    const exportUrl = event.currentTarget.dataset.exportUrl;
    const exportLink = event.currentTarget.dataset.exportLink;
    this.thumbVideoTarget.src = exportLink

    this.drawQRCode(exportUrl)
    this.toggleVisibility()
  }

  drawQRCode(url) {
    const qrSize = 128;

    const qrcode = new QRCode(document.createElement('div'), {
      text: "tholee.my.id/d/" + url,
      width: qrSize,
      height: qrSize,
      colorDark: "#000000",
      colorLight: "#ffffff",
      correctLevel: QRCode.CorrectLevel.H
    });

    this.qrImageTarget.src = qrcode._oDrawing._elCanvas.toDataURL("image/png")
  }
}
