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
    new_entry = ShoppingList.Entry.new(shopping_list.next_entry_id, name, quantity)

    %{shopping_list |
      entries: Map.put(shopping_list.entries, new_entry.id, new_entry),
      next_entry_id: shopping_list.next_entry_id + 1
    }
  end

  def update_entry_quantity(shopping_list, entry_id, new_quantity) do
    if Map.has_key?(shopping_list.entries, entry_id) do
      new_entry =
        shopping_list.entries
        |> Map.fetch!(entry_id)
        |> ShoppingList.Entry.update_quantity(new_quantity)

      %{shopping_list | entries: Map.put(shopping_list.entries, entry_id, new_entry)}
    else
      shopping_list
    end
  end

  def delete_entry(shopping_list, entry_id), do:
    %{shopping_list | entries: Map.delete(shopping_list.entries, entry_id)}
end
