import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="overlay-layout"
export default class extends Controller {
  static targets = ["overlayImg", "overlayHorizontalImg", "overlayInput", "overlayHorizontalInput", "overlayCanvas", "aspectRatio", "overlayLayoutField"]

  connect() {
    this.initializeCanvas();
    this.loadCanvasData()

    // Event listener for overlay and overlay_horizontal changes in the input file field
    this.overlayInputTarget.addEventListener('change', (event) => this.handleOverlayChange(event));
    this.overlayHorizontalInputTarget.addEventListener('change', (event) => this.handleOverlayHorizontalChange(event));

    // Event listener for form if submit triggered

      document.getElementById('config_form').addEventListener('submit', (event) => {
      // Update overlay layout field with current canvas data
      this.updateOverlayLayoutField();
    });
  }

  disconnect() {
    this.canvas.dispose();
  }

  loadCanvasData() {

    // Get canvas data
    const canvasData = this.overlayLayoutFieldTarget.value;

    // If there's any canvas data from database
    if (canvasData) {
      const parsedData = JSON.parse(canvasData);
      try {
        this.canvas.loadFromJSON(parsedData, () => {
          requestAnimationFrame(() => {
            this.setAllObjectControlVisibility()
            this.canvas.renderAll();
          });
        });
      } catch (e) {
        console.error('Failed to parse canvas data:', e);
      }
    }

  }

  initializeCanvas() {

    const canvasElement = this.overlayCanvasTarget;
    this.canvas = new fabric.Canvas(canvasElement.id);
    this.canvas.backgroundColor = "gray";
    this.loadOverlayImage();
    this.canvas.renderAll();

  }

  loadOverlayImage(event) {
    if (this.hasOverlayImgTarget) {
      const imgElement = this.overlayImgTarget;
      const img = new Image();
      img.src = imgElement.src;

      img.onload = () => {
        const imgInstance = new fabric.Image(imgElement, {
          id: 'overlay',
          left: 0,
          top: 0,
          selectable: false,
          evented: false,
          opacity: 1
        });

        const originalWidth = imgElement.naturalWidth;
        const originalHeight = imgElement.naturalHeight;
        const scale = 0.3;
        const canvasWidth = originalWidth * scale;
        const canvasHeight = originalHeight * scale;

        this.canvas.setWidth(canvasWidth);
        this.canvas.setHeight(canvasHeight);

        imgInstance.scaleToWidth(canvasWidth);
        imgInstance.scaleToHeight(canvasHeight);

        const objects = this.canvas.getObjects()
        const overlay = objects.find(obj => obj.id === 'overlay')
        if (overlay) {
          overlay.setElement(imgElement);
          this.canvas.sendObjectToBack(overlay)
        } else {
          this.canvas.add(imgInstance);
          this.canvas.sendObjectToBack(imgInstance)
        }

        this.canvas.renderAll();
      }
    }
  }

  handleOverlayChange(event) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const imgElement = this.overlayImgTarget;
        imgElement.src = e.target.result;
        this.loadOverlayImage();
      };
      reader.readAsDataURL(file);
    }
  }

  handleOverlayHorizontalChange(event) {
    const file = event.target.files[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const imgElement = this.overlayHorizontalImgTarget;
        imgElement.src = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  }

  addPlaceholder() {
    event.preventDefault();

    const placeholder = new fabric.Rect({
      left: 50,
      top: 50,
      width: 180,
      height: 120,
      fill: 'rgba(0, 0, 0, 0.75)',
      selectable: true,
      padding: 0
    });

    const text = new fabric.Text('PHOTO', {
      left: 50 + 180 / 2,
      top: 50 + 120 / 2,
      fontSize: 20,
      fontFamily: 'Arial',
      fontWeight: 'bold',
      originX: 'center',
      originY: 'center',
      fill: 'white',
      selectable: false,
      padding: 0
    });

    const group = new fabric.Group([placeholder, text], {
      id: 'placeholder',
      left: 50,
      top: 50,
      borderColor: 'blue',
      cornerColor: 'blue',
      cornerSize: 15,
      padding: 0,
      hasRotatingPoint: false,
      lockRotation: true,
      lockScalingFlip: true,
      originX: 'center'

    });

    group.setControlsVisibility({
      'ml': false,
      'mr': false,
      'mt': false,
      'mb': false,
      'mtr': false
    })

    this.canvas.add(group);
    this.canvas.setActiveObject(group)

    // group.scaleY = group.scaleX / this.aspectRatio
    // group.scaleX = group.scaleY * this.aspectRatio

    group.setCoords()
    this.canvas.renderAll();
  }

  removeSelectedObject() {
    event.preventDefault();

    var activeObject = this.canvas.getActiveObject();

    if (activeObject) {
      this.canvas.remove(activeObject);
      this.canvas.renderAll();
    }
  }

  removeAllPlaceholder() {
    event.preventDefault();

    this.canvas.getObjects().forEach((object) => {
      if (object.id != 'overlay') {
        this.canvas.remove(object);
      }
    });

    this.canvas.renderAll();
  }

  addQR() {
    event.preventDefault();

    const placeholder = new fabric.Rect({
      left: 50,
      top: 50,
      width: 100,
      height: 100,
      fill: 'rgba(255, 255, 255, 1)',
      selectable: true,
      padding: 0,
      stroke: 'black',
      strokeWidth: 2
    });

    const text = new fabric.Text('QR', {
      left: 50 + 100 / 2,
      top: 50 + 100 / 2,
      fontSize: 40,
      fontFamily: 'Arial',
      fontWeight: 'bold',
      originX: 'center',
      originY: 'center',
      fill: 'black',
      selectable: false,
      padding: 0
    });

    const group = new fabric.Group([placeholder, text], {
      id: 'qr',
      left: 50,
      top: 50,
      borderColor: 'blue',
      cornerColor: 'blue',
      cornerSize: 15,
      padding: 0,
      hasRotatingPoint: false,
      lockRotation: true,
      lockScalingFlip: true,
    });

    group.setControlsVisibility({
      'ml': false,
      'mr': false,
      'mt': false,
      'mb': false,
      'mtr': false
    })

    this.canvas.add(group);
    this.canvas.setActiveObject(group)
    group.setCoords()
    this.canvas.renderAll();
  }

  updateOverlayLayoutField() {
    // Save overlay layout canvas data with attributes
    const canvasData = JSON.stringify(this.canvas.toDatalessJSON([
      'selectable', 'borderColor', 'cornerColor', 'cornerSize', 'padding', 'hasRotatingPoint', 'lockRotation', 'lockScalingFlip', 'id'
    ]));

    // Update input value
    this.overlayLayoutFieldTarget.value = canvasData;
  }

  bringOverlayToFront() {
    event.preventDefault();

    const objects = this.canvas.getObjects()
    const overlay = objects.find(obj => obj.id === 'overlay')
    if (overlay) {
      this.canvas.bringObjectToFront(overlay)
    }
    this.bringQrToFront()
  }

  sendOverlayToBack() {
    event.preventDefault();

    const objects = this.canvas.getObjects()
    const overlay = objects.find(obj => obj.id === 'overlay')
    if (overlay) {
      this.canvas.sendObjectToBack(overlay)
    }
    this.bringQrToFront()
  }

  bringQrToFront() {
    event.preventDefault();

    this.canvas.getObjects().forEach((object) => {
      if (object.id == "qr") {
        this.canvas.bringObjectToFront(object)
      }
    });
  }

  setAllObjectControlVisibility() {
    this.canvas.getObjects().forEach((object) => {
      if (object.id != 'overlay') {
        object.setControlsVisibility({
          'ml': false,
          'mr': false,
          'mt': false,
          'mb': false,
          'mtr': false
        })
      }
    });
  }

}