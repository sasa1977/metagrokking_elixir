defmodule ShoppingList do
  @moduledoc "A shopping list abstraction."

  alias ShoppingList.Entry

  defstruct [:next_entry_id, :entries]

  @opaque t :: %ShoppingList{
    next_entry_id: Entry.id,
    entries: %{Entry.id => Entry.t}
  }


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Creates a new shopping list."
  @spec new() :: t
  def new(), do:
    %ShoppingList{next_entry_id: 1, entries: %{}}

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
  @spec add_entry(t, Entry.name, Entry.quantity) :: t
  def add_entry(shopping_list, name, quantity) do
    new_entry = Entry.new(shopping_list.next_entry_id, name, quantity)

    %ShoppingList{shopping_list |
      entries: Map.put(shopping_list.entries, new_entry.id, new_entry),
      next_entry_id: shopping_list.next_entry_id + 1
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
end
