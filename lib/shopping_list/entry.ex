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
end
