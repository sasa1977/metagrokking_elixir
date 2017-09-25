defmodule ShoppingList do
  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  def new(), do:
    %{size: 0, entries: []}

  def entries(shopping_list), do:
    shopping_list.entries

  def size(shopping_list), do:
    shopping_list.size

  def add_entry(shopping_list, name, quantity) do
    new_entry = new_entry(name, quantity)

    %{shopping_list |
      entries: [new_entry | shopping_list.entries],
      size: shopping_list.size + 1
    }
  end


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp new_entry(name, quantity), do:
    %{
      name: name,
      quantity: quantity
    }
end
