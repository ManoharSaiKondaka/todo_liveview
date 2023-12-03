defmodule ToDo.Tasks do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Todo.Repo

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "tasks" do
    field :name, :string
    field :depend_on, {:array, Ecto.UUID}, default: []
    field :completed, :boolean, default: false
    belongs_to :groups, ToDo.Groups, foreign_key: :group_name, type: :string

    timestamps()
  end

  def changeset(task, params \\ %{}) do
    task
    |> cast(params, [:name, :completed, :depend_on, :group_name])
    |> validate_required([:name, :group_name, :depend_on])
    |> unique_constraint(:name, message: "Group Name has already been taken.")
  end

  def add_task(attrs \\ %{}) do
    %ToDo.Tasks{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def list_tasks do
    Repo.all(ToDo.Tasks)
  end

  def list_tasks_by_group_name(nil) do
    []
  end

  def list_tasks_by_group_name(group_name) do
    from(t in ToDo.Tasks,
      where: t.group_name == ^group_name,
      order_by: [asc: t.inserted_at]
    )
    |> Repo.all()
  end

  def update_task_completed_status(task_id, completed_status) do
    task = Repo.get(ToDo.Tasks, task_id)

    case task do
      nil ->
        {:error, "Task not found"}

      _ ->
        task
        |> Ecto.Changeset.change(completed: completed_status)
        |> Repo.update()

        {:ok, "Task completed status updated successfully"}
    end
  end
end
