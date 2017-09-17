defmodule ShoppingList do
  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  def new(), do:
    %{entries: []}

  def entries(shopping_list), do:
    shopping_list.entries

  def size(shopping_list), do:
    length(shopping_list.entries)

  def add_entry(shopping_list, name, quantity) do
    new_entry = new_entry(name, quantity)
    new_entries = [new_entry | shopping_list.entries]
    %{shopping_list | entries: new_entries}
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
