import consumer from "channels/consumer"

var eventId = null;
var progressElement = null;
if (document.querySelector("[data-event-id]")) {
  eventId = document.querySelector("[data-event-id]").dataset.eventId;
}

consumer.subscriptions.create({ channel: "ProgressChannel", event_id: eventId }, {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    const sessionId = data.session_id
    progressElement = document.querySelector("#progress_" + sessionId);
    if (progressElement) {
      if (data.progress >= 100) {
        progressElement.textContent = "";
      } else {
        progressElement.textContent = `${data.progress}%`;
      }
    }
  }
});
