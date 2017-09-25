import $ from "jquery"

let listHtml = (entries) => {
  if (entries.length == 0) {
    return "";
  }
  else {
    return entries.
      sort((a, b) => {return a.name.localeCompare(b.name)}).
      reduce((acc, entry) => {return acc + entryHtml(entry)}, "");
  }
}

let entryHtml= (entry) => {
  return `
    <tr id="entry_${entry.id}">
      <td>${entry.name}</td>
      <td>
        <input id="entry_quantity_${entry.id}" type="number" data-update="${entry.id}" value="${entry.quantity}" />
      </td>
      <td><a href="#" data-delete="${entry.id}">delete</a></td>
    </tr>
  `
}

export let View = {
  initialize: (handlers) => {
    $("#new_entry_form").submit((event) => {
      if ($("#entry_name").val() == "") {
        $("#entry_name").focus();
      }
      else if ($("#entry_quantity").val() == "") {
        $("#entry_quantity").focus();
      }
      else {
        handlers.onEntryAdded({name: $("#entry_name").val(), quantity: parseInt($("#entry_quantity").val())})
        $("#entry_name").val("").focus();
        $("#entry_quantity").val("");
      }
      event.preventDefault();
    });

    $("#list_data").on("click", "[data-delete]", (event) => {
      handlers.onEntryDeleted($(event.target).data("delete"));
      $("#entry_name").focus();
      event.preventDefault();
    });

    $("#list_data").on("change", "[data-update]", (event) => {
      handlers.onEntryQuantityUpdated($(event.target).data("update"), parseInt($(event.target).val()));
    });
  },

  render: (entries) => {
    $("#list_data").html(listHtml(entries));
    $("#new_entry_form").show()
  }
}
