import consumer from "channels/consumer"

var eventId = null;
var counterElement = null;
if (document.querySelector("[data-event-id]")) {
  eventId = document.querySelector("[data-event-id]").dataset.eventId;
  counterElement = document.querySelector("#counter");
}

consumer.subscriptions.create({channel:"GoproCounterChannel", event_id: eventId }, {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    counterElement.textContent = `${data.counter}`;
  }
});
