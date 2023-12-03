defmodule Todo.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :name, :string, null: false
      add :completed, :boolean, default: false
      add :depend_on, {:array, :uuid}, default: []
      add :group_name, references(:groups, column: :name, type: :string, on_delete: :delete_all)

      timestamps()
    end
  end
end
