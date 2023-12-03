defmodule Todo.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :uuid, null: false
      add :name, :string, primary_key: true
      add :total_no_of_tasks, :integer, default: 0
      add :tasks_completed, :integer, default: 0

      timestamps()
    end
  end
end
