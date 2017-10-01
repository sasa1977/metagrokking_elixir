defmodule ShoppingList.Entry do
  @moduledoc "A shopping list entry abstraction."

  alias ShoppingList.Entry

  defstruct [:id, :name, :quantity]

  @type id :: String.t
  @type name :: String.t
  @type quantity :: pos_integer

  @type t :: %Entry{id: id, name: name, quantity: quantity}


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Creates the new entry."
  @spec new(id, name, quantity) :: t
  def new(id, name, quantity), do:
    %Entry{
      id: id,
      name: name,
      quantity: quantity
    }

  @doc "Updates the quantity of the entry."
  @spec update_quantity(t, quantity) :: t
  def update_quantity(entry, new_quantity), do:
    %Entry{entry | quantity: new_quantity}
end
