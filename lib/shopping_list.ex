defmodule ShoppingList do
  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  def new(), do:
    %{size: 0, next_entry_id: 1, entries: []}

  def entries(shopping_list), do:
    shopping_list.entries

  def size(shopping_list), do:
    shopping_list.size

  def add_entry(shopping_list, name, quantity) do
    new_entry = new_entry(shopping_list.next_entry_id, name, quantity)

    %{shopping_list |
      entries: [new_entry | shopping_list.entries],
      size: shopping_list.size + 1,
      next_entry_id: shopping_list.next_entry_id + 1
    }
  end


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
