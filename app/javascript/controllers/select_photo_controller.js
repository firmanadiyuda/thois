import { Controller } from "@hotwired/stimulus"
import { v4 as uuidv4 } from 'uuid';

// Connects to data-controller="select-photo"
export default class extends Controller {
  static targets = ["overlayImg", "overlayCanvas", "output", "container", "aspectRatio", "canvasDataField", "photo", "exportForm", "exportField", "qrurl"]

  connect() {
    this.initializeCanvas();

    const canvasData = this.canvasDataFieldTarget.value;

    if (canvasData) {
      const parsedData = JSON.parse(canvasData);
      try {
        this.canvas.loadFromJSON(parsedData, () => {
          requestAnimationFrame(() => {
            this.canvas.getObjects().forEach((object) => {
              object.selectable = false;
            });

            this.bringOverlayToFront()
            this.setOverlayOpacity()
            this.updateQr()
            this.canvas.renderAll();
          });
        });
      } catch (e) {
        console.error('Failed to parse canvas data:', e);
      }
    }

  }

  disconnect() {
    this.canvas.dispose();
  }

  initializeCanvas() {
    const canvasElement = this.overlayCanvasTarget;
    this.canvas = new fabric.Canvas(canvasElement.id);
    // this.container = this.containerTarget
    this.loadOverlayImage();
  }

  selectPhoto(event) {
    event.preventDefault()
    const photoIndex = event.target.dataset.index

    const objectToUpdate = this.canvas.getObjects().find(object => object.id === 'placeholder' && !object.used);

    if (objectToUpdate) {
      const left = objectToUpdate.left;
      const top = objectToUpdate.top;
      const width = objectToUpdate.width * objectToUpdate.scaleX;
      const height = objectToUpdate.height * objectToUpdate.scaleY;

      const angle = objectToUpdate.angle;

      const imgElement = this.photoTargets[photoIndex];

      if (imgElement) {
        const img = new Image();
        img.src = imgElement.src;

        img.onload = () => {
          const imgAspectRatio = img.width / img.height;
          const placeholderAspectRatio = width / height;

          let scaleX, scaleY;

          if (imgAspectRatio > placeholderAspectRatio) {
            scaleX = width / img.width;
            scaleY = scaleX;
          } else {
            scaleY = height / img.height;
            scaleX = scaleY;
          }

          const imgInstance = new fabric.Image(imgElement, {
            used: 'true',
            left: left,
            top: top,
            scaleX: scaleX,
            scaleY: scaleY,
            angle: angle,
            selectable: false,
            originX: 'center',
          });

          this.canvas.remove(objectToUpdate)
          this.canvas.add(imgInstance)
          this.bringOverlayToFront()
          this.canvas.renderAll();
        }

      }
    }

  }

  updateQr() {
    const padding = 16; // Padding yang ingin ditambahkan
    const qrSize = 128; // Ukuran QR Code

    const qrcode = new QRCode(document.createElement('div'), {
      text: this.qrurlTarget.value,
      width: qrSize,
      height: qrSize,
      colorDark: "#000000",
      colorLight: "#ffffff",
      correctLevel: QRCode.CorrectLevel.H
    });

    qrcode._oDrawing._elImage.onload = ev => {
      const qrImageSrc = ev.target.src;

      // Buat canvas sementara untuk menambahkan padding
      const tempCanvas = document.createElement('canvas');
      const ctx = tempCanvas.getContext('2d');

      // Ukur ukuran baru dengan padding
      const paddedWidth = qrSize + 2 * padding;
      const paddedHeight = qrSize + 2 * padding;

      tempCanvas.width = paddedWidth;
      tempCanvas.height = paddedHeight;

      // Gambar QR Code dengan padding di tengah canvas
      ctx.fillStyle = "#ffffff"; // Warna latar belakang putih
      ctx.fillRect(0, 0, paddedWidth, paddedHeight); // Mengisi seluruh canvas dengan warna putih
      const img = new Image();
      img.src = qrImageSrc;

      img.onload = () => {
        ctx.drawImage(img, padding, padding, qrSize, qrSize); // Menggambar QR Code dengan padding

        const paddedImageSrc = tempCanvas.toDataURL(); // Menghasilkan data URL dari canvas dengan padding

        // Mengganti objek QR Code di canvas
        this.canvas.getObjects().forEach((objectToUpdate) => {
          if (objectToUpdate.id === "qr") {
            const left = objectToUpdate.left;
            const top = objectToUpdate.top;
            const width = objectToUpdate.width * objectToUpdate.scaleX;
            const height = objectToUpdate.height * objectToUpdate.scaleY;
            const angle = objectToUpdate.angle;

            const paddedImg = new Image();
            paddedImg.src = paddedImageSrc;

            paddedImg.onload = () => {
              const imgAspectRatio = paddedImg.width / paddedImg.height;
              const placeholderAspectRatio = width / height;

              let scaleX, scaleY;

              if (imgAspectRatio > placeholderAspectRatio) {
                scaleX = width / paddedImg.width;
                scaleY = scaleX;
              } else {
                scaleY = height / paddedImg.height;
                scaleX = scaleY;
              }

              const imgInstance = new fabric.Image(paddedImg, {
                id: 'qr',
                left: left,
                top: top,
                scaleX: scaleX,
                scaleY: scaleY,
                angle: angle,
                selectable: false,
              });

              this.canvas.remove(objectToUpdate);
              this.canvas.add(imgInstance);
              this.bringOverlayToFront();
              this.canvas.renderAll();
            };
          }
        });
      };
    };
  }

  finish() {
    const image = this.canvas.toDataURL({
      format: 'png',
      multiplier: 2.5
    })

    const blob = this.dataURLtoBlob(image);
    const file = new File([blob], uuidv4() + '.png', {
      type: blob.type
    });

    // const fileInput = document.getElementById('imageFileInput');
    const dataTransfer = new DataTransfer();
    dataTransfer.items.add(file);
    this.exportFieldTarget.files = dataTransfer.files;

    // document.getElementById('dataURLForm').submit();

    this.exportFormTarget.requestSubmit()
  }

  dataURLtoBlob(dataURL) {
    const [header, data] = dataURL.split(',');
    const mime = header.split(':')[1].split(';')[0];
    const binary = atob(data);
    const array = [];
    for (let i = 0; i < binary.length; i++) {
      array.push(binary.charCodeAt(i));
    }
    return new Blob([new Uint8Array(array)], {
      type: mime
    });
  }

  setOverlayOpacity() {
    const objects = this.canvas.getObjects()
    const overlay = objects.find(obj => obj.id === 'overlay')
    if (overlay) {
      overlay.set('opacity', 1)
    }
  }

  bringOverlayToFront() {
    const objects = this.canvas.getObjects()
    const overlay = objects.find(obj => obj.id === 'overlay')
    if (overlay) {
      this.canvas.bringObjectToFront(overlay)
    }
    this.bringQrToFront()
  }

  bringQrToFront() {
    this.canvas.getObjects().forEach((object) => {
      if (object.id == "qr") {
        this.canvas.bringObjectToFront(object)
      }
    });
  }

  loadOverlayImage(event) {
    const imgElement = this.overlayImgTarget;

    if (imgElement) {
      const img = new Image();
      img.src = imgElement.src;

      img.onload = () => {
        const imgInstance = new fabric.Image(imgElement, {
          left: 0,
          top: 0,
          selectable: false,
          evented: false,
          opacity: 0.5
        });

        const originalWidth = imgElement.naturalWidth;
        const originalHeight = imgElement.naturalHeight;
        const scale = 0.3;
        const canvasWidth = originalWidth * scale;
        const canvasHeight = originalHeight * scale;

        this.canvas.setWidth(canvasWidth);
        this.canvas.setHeight(canvasHeight);

        const zoomFactor = 1.5
        this.canvas.setZoom(zoomFactor);
        this.canvas.setWidth(canvasWidth * zoomFactor);
        this.canvas.setHeight(canvasHeight * zoomFactor);

        this.canvas.renderAll();
      }
    }
  }

}