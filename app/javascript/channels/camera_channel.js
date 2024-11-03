import consumer from "channels/consumer"

let isCapturing = false;
let cheese = false;

consumer.subscriptions.create({ channel: "CameraChannel" }, {
  connected() {
    // Called when the subscription is ready for use on the server
    // console.log("Ready")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const liveviewElement = document.getElementById('liveview');
    const previewCapturedElement = document.getElementById('preview-captured');
    const captureElement = document.getElementById('captured-image');
    const toggleButton = document.getElementById('toggle-liveview');
    const statusElement = document.getElementById('status');
    const countdownElement = document.getElementById('countdown');
    const startButton = document.getElementById('start-button');
    const nextButton = document.getElementById('next-button');
    const previousButton = document.getElementById('previous-button');
    const finishButton = document.getElementById('finish-button');
    const totalCapturedELement = document.getElementById('total-captured');

    if (data.operator_instruction) {
      const operator_instruction = data.operator_instruction
      // console.log(data.operator_instruction)
      if (nextButton && operator_instruction == "select_photo") {
        nextButton.click()
      }
      if (operator_instruction == "select_photo_id") {
        const photobtn = document.getElementById('select-photo-' + data.id)
        if (photobtn) {
          photobtn.click()
          // console.log(photobtn)
        }
      }
      if (previousButton && operator_instruction == "liveview") {
        previousButton.click()
      }
      if (finishButton && operator_instruction == "finish") {
        finishButton.click()
      }
    }

    // Received liveview data
    if (liveviewElement && data.liveview && !isCapturing && !cheese) {
      previewCapturedElement.classList.add('hidden');
      liveviewElement.classList.remove('hidden');
      liveviewElement.src = `data:image/jpeg;base64,${data.liveview}`;
    }

    // Received camera model
    if (statusElement && data.model) {
      statusElement.textContent = `Connected: ${data.model}`;
      statusElement.classList.add('text-green-600');
      statusElement.classList.remove('text-red-600');
    }

    // Received status data, connected or not
    if (statusElement && data.liveview_status !== undefined) {
      if (data.liveview_status) {
        toggleButton.textContent = 'Stop Liveview';
        toggleButton.dataset.enabled = 'true';
      } else {
        statusElement.textContent = 'Disconnected';
        statusElement.classList.remove('text-green-600');
        statusElement.classList.add('text-red-600');
        toggleButton.textContent = 'Start Liveview';
        toggleButton.dataset.enabled = 'false';
      }
    }

    // Received captured image data
    if (previewCapturedElement && data.captured_image) {
      isCapturing = true;
      previewCapturedElement.src = `data:image/jpeg;base64,${data.captured_image}`;
      previewCapturedElement.classList.remove('hidden');
      liveviewElement.classList.add('hidden');
      countdownElement.classList.add('hidden');
    }

    // Received end preview
    if (previewCapturedElement && data.end_preview) {
      startButton.classList.remove('hidden')
      previewCapturedElement.classList.add('hidden');
      liveviewElement.classList.remove('hidden');
      isCapturing = false;
      cheese = false;
      location.reload();
    }

    // Received countdown duration
    if (data.countdown_duration && startButton) {
        startButton.classList.add('hidden')
        nextButton.classList.add('hidden')
        totalCapturedELement.classList.add('hidden')
        countdownElement.classList.remove('hidden');
        let countdownDuration = parseInt(data.countdown_duration);

      function updateCountdown() {
        if (countdownDuration <= 0) {
          cheese = true
          liveviewElement.classList.add('hidden');
          countdownElement.textContent = '😜 cheese! 😆';
          clearInterval(countdownInterval);
        } else {
          countdownElement.textContent = countdownDuration;
          countdownDuration--;
        }
      }

      const countdownInterval = setInterval(updateCountdown, 1000);

      updateCountdown();
    }
  }
});