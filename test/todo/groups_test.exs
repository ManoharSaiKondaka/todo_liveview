defmodule ToDo.GroupsTest do
  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Todo.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Todo.Repo, {:shared, self()})
    :ok
  end

  describe "Groups functionality" do
    alias ToDo.Groups

    test "adding a group" do
      group_attrs = %{name: "Test Group"}

      {:ok, group} = Groups.add_group(group_attrs)

      assert %Groups{} = group
      assert group.name == "Test Group"
      assert group.total_no_of_tasks == 0
      assert group.tasks_completed == 0
    end

    test "updating a group" do
      group_attrs = %{name: "Group to Update"}
      {:ok, group} = Groups.add_group(group_attrs)

      updated_attrs = %{name: "Updated Group", total_no_of_tasks: 3}

      {:ok, updated_group} = Groups.update_group(group, updated_attrs)

      assert %Groups{} = updated_group
      assert updated_group.name == "Updated Group"
      assert updated_group.total_no_of_tasks == 3
      assert updated_group.tasks_completed == 0
    end

    test "listing groups" do
      Groups.add_group(%{name: "Group 1"})
      Groups.add_group(%{name: "Group 2"})

      groups = Groups.list_groups()

      assert length(groups) == 2
      assert Enum.map(groups, & &1.name) == ["Group 1", "Group 2"]
    end
  end
end
