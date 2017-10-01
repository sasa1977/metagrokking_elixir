defmodule ShoppingList.EctoRepo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :shopping_list_id, :uuid
      add :data, :map
    end

    create index(:events, [:shopping_list_id])
  end
end
