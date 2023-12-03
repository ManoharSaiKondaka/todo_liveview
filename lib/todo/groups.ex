defmodule ToDo.Groups do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Todo.Repo

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "groups" do
    field :name, :string
    field :total_no_of_tasks, :integer, default: 0
    field :tasks_completed, :integer, default: 0

    timestamps()
  end

  def changeset(task, params \\ %{}) do
    task
    |> cast(params, [:name, :total_no_of_tasks, :tasks_completed])
    |> validate_required([:name])
    |> unique_constraint(:name, message: "Group Name has already been taken.")
  end

  def add_group(attrs \\ %{}) do
    %ToDo.Groups{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def list_groups do
    from(g in ToDo.Groups, order_by: [asc: g.inserted_at])
    |> Repo.all()
  end

  def update_group(group, attrs) do
    group
    |> changeset(attrs)
    |> Repo.update()
  end
end
