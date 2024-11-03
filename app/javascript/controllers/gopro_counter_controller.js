import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Connects to data-controller="gallery"
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
      { channel: "GoproCounterChannel", event_id: eventId },
      {
        connected: () => {
        },
        disconnected: () => {
        },
        received: (data) => {
          if (this.hasCounterTarget) {
            this.counterTarget.textContent = `${data.counter}`
          }
        }
      }
    )
  }
}