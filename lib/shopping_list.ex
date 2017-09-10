defmodule ShoppingList do
  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  def new(), do:
    %{next_entry_id: 1, entries: %{}}

  def entries(shopping_list), do:
    Map.values(shopping_list.entries)

  def size(shopping_list), do:
    Map.size(shopping_list.entries)

  def add_entry(shopping_list, name, quantity) do
    new_entry = new_entry(shopping_list.next_entry_id, name, quantity)

    %{shopping_list |
      entries: Map.put(shopping_list.entries, new_entry.id, new_entry),
      next_entry_id: shopping_list.next_entry_id + 1
    }
  end

  def delete_entry(shopping_list, entry_id), do:
    %{shopping_list | entries: Map.delete(shopping_list.entries, entry_id)}


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp new_entry(id, name, quantity), do:
    %{
      id: id,
      name: name,
      quantity: quantity
    }
end
