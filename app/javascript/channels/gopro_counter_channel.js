import consumer from "channels/consumer"

const eventId = document.querySelector("[data-event-id]").dataset.eventId;
const counterElement = document.querySelector("#counter");

consumer.subscriptions.create({channel:"GoproCounterChannel", event_id: eventId }, {
  connected() {
    // Called when the subscription is ready for use on the server
    // console.log("sgsdg")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    counterElement.textContent = `${data.counter}`;
  }
});
