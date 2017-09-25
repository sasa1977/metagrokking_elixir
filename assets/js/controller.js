import $ from "jquery"
import {Socket} from "phoenix"
import {View} from "./view"
import uuidv4 from "uuid/v4"

let sendEntryCommand = (csrfToken, signedListId, entry) => {
  entry.id = uuidv4();
  $.ajax({
    method: "POST",
    url: `/lists/${signedListId}/entries`,
    data: JSON.stringify(entry),
    contentType: 'application/json',
    processData: false,
    headers: {"x-csrf-token": csrfToken},
  });
}

let sendUpdateEntryQuantityCommand = (csrfToken, signedListId, entryId, quantity) =>
  $.ajax({
    method: "PUT",
    url: `/lists/${signedListId}/entries/${entryId}`,
    data: JSON.stringify({quantity: quantity}),
    contentType: 'application/json',
    processData: false,
    headers: {"x-csrf-token": csrfToken},
  });

let sendDeleteEntryCommand = (csrfToken, signedListId, entryId) =>
  $.ajax({
    method: "DELETE",
    url: `/lists/${signedListId}/entries/${entryId}`,
    headers: {"x-csrf-token": csrfToken},
  });

let entries = [];
let render = () => View.render(entries);

export let initialize = (signedListId, csrfToken) => {
  View.initialize({
    onEntryAdded: (entry) =>
      sendEntryCommand(csrfToken, signedListId, entry),
    onEntryQuantityUpdated: (entryId, quantity) =>
      sendUpdateEntryQuantityCommand(csrfToken, signedListId, entryId, quantity),
    onEntryDeleted: (entryId) =>
      sendDeleteEntryCommand(csrfToken, signedListId, entryId),
  });

  let socket = new Socket("/socket");
  socket.connect();

  let channel = socket.channel(`notifications:${signedListId}`);
  entries = channel.join().
    receive("ok", (initialMessage) => {
      entries = initialMessage.entries;
      render();
    });

  channel.on("entry_added", (entry) => {
    entries.push(entry);
    render();
  });

  channel.on("entry_quantity_updated", (payload) => {
    entries = entries.map((entry) => {
      if (entry.id == payload.id)
        entry.quantity = payload.quantity;
      return entry
    });

    render();
  });

  channel.on("entry_deleted", (payload) => {
    entries = entries.filter((entry) => entry.id != payload.id);
    render();
  });
}
