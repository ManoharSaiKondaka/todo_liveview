defmodule Todo.GroupsHelper do
  alias ToDo.Groups

  def update_task_completed_in_group(group, true) do
    Groups.update_group(group, %{tasks_completed: group.tasks_completed + 1})
  end

  def update_task_completed_in_group(group, false) do
    Groups.update_group(group, %{tasks_completed: group.tasks_completed - 1})
  end

  def create_group(nil, _), do: {:error, "Group name should not be empty."}
  def create_group("", _), do: {:error, "Group name should not be empty."}

  def create_group(group_name, group_id) do
    all_groups = Groups.list_groups()

    case Enum.find(all_groups, &(&1.name == group_name)) do
      %Groups{} ->
        {:error, "Group already exists. Group name should be unique."}

      nil ->
        attrs = %{
          "id" => group_id,
          "name" => group_name
        }

        ToDo.Groups.add_group(attrs)
        {:ok, Success}
    end
  end
end
