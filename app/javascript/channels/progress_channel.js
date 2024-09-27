import consumer from "channels/consumer"

const sessionId = document.querySelector("[data-session-id]").dataset.sessionId;
const progressElement = document.querySelector("#progress");

consumer.subscriptions.create({ channel: "ProgressChannel", session_id: sessionId }, {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Ready")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log(data)
    progressElement.textContent = `${data.progress}%`;
  }
});
