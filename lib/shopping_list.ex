defmodule ShoppingList do
  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  def new(), do:
    []

  def entries(shopping_list), do:
    shopping_list

  def size(shopping_list), do:
    length(shopping_list)

  def add_entry(shopping_list, name, quantity) do
    new_entry = new_entry(name, quantity)
    [new_entry | shopping_list]
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
