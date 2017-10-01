defmodule ShoppingList.Storage do
  @moduledoc "Persistent storage for shopping list data."

  alias ShoppingList.EctoRepo
  import Ecto.Query


  # -------------------------------------------------------------------
  # API
  # -------------------------------------------------------------------

  @doc "Stores the shopping list event."
  @spec store_event!(ShoppingList.id, ShoppingList.event) :: :ok
  def store_event!(shopping_list_id, event) do
    {1, nil} =
      EctoRepo.insert_all(
        "events",
        [%{shopping_list_id: binary_id!(shopping_list_id), data: event}]
      )

    :ok
  end

  @doc "Returns the chronologically ordered list of events for the given shopping list."
  @spec events(ShoppingList.id) :: [ShoppingList.event]
  def events(shopping_list_id), do:
    from(
      event in "events",
      where: event.shopping_list_id == ^binary_id!(shopping_list_id),
      order_by: [asc: event.id],
      select: event.data
    )
    |> EctoRepo.all()
    |> Enum.map(&decode_event/1)


  # -------------------------------------------------------------------
  # Internal functions
  # -------------------------------------------------------------------

  defp binary_id!(shopping_list_id) do
    {:ok, binary_id} = Ecto.UUID.dump(shopping_list_id)
    binary_id
  end

  defp decode_event(event_with_string_keys), do:
    # converting string keys into atoms
    event_with_string_keys
    |> Enum.map(fn({key, value}) -> {String.to_existing_atom(key), value} end)
    |> Enum.into(%{})
    |> Map.update!(:event_name, &String.to_existing_atom/1)
end
