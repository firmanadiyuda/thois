import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Connects to data-controller="progress"
export default class extends Controller {
  static targets = [ "counter" ]
  static values = { eventId: String }

  connect() {
    this.subscription = null
  }

  initialize() {
    if (this.eventIdValue) {
      this.connectToChannel(this.eventIdValue)
    }
  }

  connectToChannel(eventId) {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }

    this.subscription = consumer.subscriptions.create(
      { channel: "ProgressChannel", event_id: eventId },
      {
        connected: () => {
        },
        disconnected: () => {
        },
        received: (data) => {

          const sessionId = data.session_id
          var progressElement = document.querySelector("#progress_" + sessionId);
          var progressHeadElement = document.querySelector("#progress_head_" + sessionId);
          if (progressHeadElement) {
            if (data.progress >= 100) {
              progressHeadElement.classList.add('hidden');
              progressElement.style.width = "0%";
            } else {
              progressHeadElement.classList.remove('hidden');
              progressElement.style.width = `${data.progress}%`;
            }
          }
        }
      }
    )
  }
}