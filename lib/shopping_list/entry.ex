defmodule ShoppingList.Entry do
  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  def new(id, name, quantity), do:
    %{
      id: id,
      name: name,
      quantity: quantity
    }

  def update_quantity(entry, new_quantity), do:
    %{entry | quantity: new_quantity}
end
