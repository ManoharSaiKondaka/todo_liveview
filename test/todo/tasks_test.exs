defmodule ToDo.TasksTest do
  use ExUnit.Case
  alias ToDo.{Tasks, Groups}
  alias Todo.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    {:ok, %{}}
  end

  test "adding a task" do
    group_attrs = %{name: "Test Group"}
    {:ok, group} = Groups.add_group(group_attrs)

    task_attrs = %{name: "Test Task", group_name: group.name}

    {:ok, task} = Tasks.add_task(task_attrs)

    assert %Tasks{} = task
    assert task.name == "Test Task"
    assert task.group_name == group.name
  end

  test "listing tasks" do
    group_attrs = %{name: "Group 1"}
    group_attrs2 = %{name: "Group 2"}
    Groups.add_group(group_attrs)
    Groups.add_group(group_attrs2)
    Tasks.add_task(%{name: "Task 1", group_name: "Group 1"})
    Tasks.add_task(%{name: "Task 2", group_name: "Group 2"})

    tasks = Tasks.list_tasks()

    assert length(tasks) == 2
    assert Enum.map(tasks, & &1.name) == ["Task 1", "Task 2"]
  end

  test "listing tasks by group name" do
    group_attrs = %{name: "Test Group"}
    {:ok, group} = Groups.add_group(group_attrs)

    Tasks.add_task(%{name: "Task 1", group_name: group.name})
    Tasks.add_task(%{name: "Task 2", group_name: group.name})

    tasks = Tasks.list_tasks_by_group_name(group.name)

    assert length(tasks) == 2
    assert Enum.map(tasks, & &1.name) == ["Task 1", "Task 2"]
  end

  test "updating task completed status" do
    group_attrs = %{name: "Test Group"}
    {:ok, group} = Groups.add_group(group_attrs)

    {:ok, task} = Tasks.add_task(%{name: "Test Task", group_name: group.name})

    assert Tasks.update_task_completed_status(task.id, true) ==
             {:ok, "Task completed status updated successfully"}

    updated_task = Repo.get(ToDo.Tasks, task.id)
    assert updated_task.completed
  end

  test "add dependent task" do
    group_attrs = %{name: "Test Group"}
    {:ok, group} = Groups.add_group(group_attrs)
    task_attrs = %{name: "Test Task", group_name: group.name}
    {:ok, task} = Tasks.add_task(task_attrs)

    second_task_attrs = %{name: "Test Task 2", group_name: group.name, depend_on: [task.id]}

    {:ok, task2} = Tasks.add_task(second_task_attrs)
    tasks = Tasks.list_tasks()

    assert task.name == "Test Task"
    assert task2.name == "Test Task 2"

    assert length(tasks) == 2
    assert task.group_name == group.name
    assert task2.depend_on == [task.id]
  end
end
