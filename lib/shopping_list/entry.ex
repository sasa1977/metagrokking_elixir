defmodule ShoppingList.Entry do
  alias ShoppingList.Entry

  defstruct [:id, :name, :quantity]

  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  def new(id, name, quantity), do:
    %Entry{
      id: id,
      name: name,
      quantity: quantity
    }

  def update_quantity(entry, new_quantity), do:
    %Entry{entry | quantity: new_quantity}
end
