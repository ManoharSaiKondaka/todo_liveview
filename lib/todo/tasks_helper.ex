defmodule Todo.TasksHelper do
  alias ToDo.Tasks
  alias ToDo.Groups
  alias Todo.Repo
  import Ecto.Query

  def check_locked(task_id) do
    task = Repo.get(Tasks, task_id)
    dependent_tasks = get_dependent_tasks(task.depend_on || [])
    Enum.any?(dependent_tasks, &(&1.completed == false))
  end

  def get_dependent_tasks(dependent_task_ids) do
    from(t in Tasks, where: t.id in ^dependent_task_ids)
    |> Repo.all()
  end

  def create_task(group, %{"task" => %{"task_name" => task_name}, "depend_on" => depend_on})
      when task_name != "" do
    tasks = Tasks.list_tasks_by_group_name(group.name)

    case Enum.find(tasks, &(&1.name == task_name)) do
      %Tasks{} = _existing_task ->
        {:error, "Task already exists. Task name should be unique."}

      nil ->
        attrs = %{
          "id" => Ecto.UUID.generate(),
          "group_name" => group.name,
          "name" => task_name,
          "depend_on" => depend_on
        }

        ToDo.Tasks.add_task(attrs)
        Groups.update_group(group, %{total_no_of_tasks: group.total_no_of_tasks + 1})
        {:ok, Success}
    end
  end

  def create_task(_, %{"task" => %{"task_name" => ""} = _params}) do
    {:error, "Task name should not be empty."}
  end

  def create_task(_, _params), do: {:error, "Task name should not be empty."}
end
