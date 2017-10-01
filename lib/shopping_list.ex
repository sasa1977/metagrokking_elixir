defmodule ShoppingList do
  @moduledoc "A shopping list abstraction."

  alias ShoppingList.Entry

  defstruct [:id, :entries]

  @opaque t :: %ShoppingList{id: id, entries: %{Entry.id => Entry.t}}

  @type id :: String.t

  @type event ::
    entry_added_event |
    entry_quantity_updated_event |
    entry_deleted_event

  @type entry_added_event ::
    %{event_name: :entry_added, id: Entry.id, name: Entry.name, quantity: Entry.quantity}

  @type entry_quantity_updated_event ::
    %{event_name: :entry_quantity_updated, id: Entry.id, quantity: Entry.quantity}

  @type entry_deleted_event ::
    %{event_name: :entry_deleted, id: Entry.id}


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @spec new_id() :: id
  def new_id(), do:
    Ecto.UUID.generate()

  @doc "Creates a new shopping list."
  @spec new(id, [event]) :: t
  def new(id \\ new_id(), events \\ []), do:
    Enum.reduce(
      events,
      %ShoppingList{id: id, entries: %{}},
      fn event, shopping_list -> apply_event(shopping_list, event) end
    )

  @doc "Returns the shopping list id."
  @spec id(t) :: id
  def id(shopping_list), do:
    shopping_list.id

  @doc """
  Returns shopping list entries.

  The ordering of the entries is non-deterministic.
  """
  @spec entries(t) :: [Entry.t]
  def entries(shopping_list), do:
    Map.values(shopping_list.entries)

  @doc "Returns the number of entries in the shopping list."
  @spec size(t) :: non_neg_integer
  def size(shopping_list), do:
    Map.size(shopping_list.entries)

  @doc "Adds a new entry."
  @spec add_entry(t, Entry.id, Entry.name, Entry.quantity) :: t
  def add_entry(shopping_list, entry_id, name, quantity) do
    false = Map.has_key?(shopping_list.entries, entry_id)
    new_entry = Entry.new(entry_id, name, quantity)

    %ShoppingList{shopping_list |
      entries: Map.put(shopping_list.entries, new_entry.id, new_entry)
    }
  end

  @doc "Updates the quantity of the existing entry."
  @spec update_entry_quantity(t, Entry.id, Entry.quantity) :: t
  def update_entry_quantity(shopping_list, entry_id, new_quantity) do
    if Map.has_key?(shopping_list.entries, entry_id) do
      new_entry =
        shopping_list.entries
        |> Map.fetch!(entry_id)
        |> Entry.update_quantity(new_quantity)

      %ShoppingList{shopping_list |
        entries: Map.put(shopping_list.entries, entry_id, new_entry)
      }
    else
      shopping_list
    end
  end

  @doc "Deletes the entry."
  @spec delete_entry(t, Entry.id) :: t
  def delete_entry(shopping_list, entry_id), do:
    %ShoppingList{shopping_list |
      entries: Map.delete(shopping_list.entries, entry_id)
    }

  @doc "Creates the entry added event."
  @spec entry_added(Entry.id, Entry.name, Entry.quantity) :: entry_added_event
  def entry_added(id, name, quantity), do:
    %{event_name: :entry_added, id: id, name: name, quantity: quantity}

  @doc "Creates the entry updated event."
  @spec entry_quantity_updated(Entry.id, Entry.quantity) :: entry_quantity_updated_event
  def entry_quantity_updated(id, quantity), do:
    %{event_name: :entry_quantity_updated, id: id, quantity: quantity}

  @doc "Creates the entry deleted event."
  @spec entry_deleted(Entry.id) :: entry_deleted_event
  def entry_deleted(id), do:
    %{event_name: :entry_deleted, id: id}

  @doc "Applies the event to the shopping list model."
  @spec apply_event(t, event) :: t
  def apply_event(shopping_list, %{event_name: :entry_added} = event), do:
    add_entry(shopping_list, event.id, event.name, event.quantity)
  def apply_event(shopping_list, %{event_name: :entry_quantity_updated} = event), do:
    update_entry_quantity(shopping_list, event.id, event.quantity)
  def apply_event(shopping_list, %{event_name: :entry_deleted} = event), do:
    delete_entry(shopping_list, event.id)
end
