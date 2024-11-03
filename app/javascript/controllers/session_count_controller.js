import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

// Connects to data-controller="session-count"
export default class extends Controller {
  static targets = [ "count" ]
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
      { channel: "SessionCountChannel", event_id: eventId },
      {
        connected: () => {
        },
        disconnected: () => {
        },
        received: (data) => {
          const session_count = data.count
          if (this.hasCountTarget) {
            this.countTarget.textContent = session_count
          }
        }
      }
    )
  }
}