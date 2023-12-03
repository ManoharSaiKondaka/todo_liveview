defmodule TodoWeb.AddLive do
  use TodoWeb, :live_view
  alias ToDo.Tasks
  alias ToDo.Groups
  alias Todo.Repo
  alias Todo.GroupsHelper
  alias Todo.TasksHelper

  @impl true
  def mount(params, _session, socket) do
    group_id = params["group_id"]
    group_name = params["group_name"]
    tasks = Tasks.list_tasks_by_group_name(group_name)
    all_groups = Groups.list_groups()

    {:ok,
     socket
     |> assign(tasks: tasks)
     |> assign(all_groups: all_groups)
     |> assign(group_name: group_name)
     |> assign(group_id: group_id)
     |> assign(show_dependency: false)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("form_submit", params, socket) do
    group_name = params["task"]["group_name"] || socket.assigns.group_name
    group = Repo.get_by(Groups, %{name: group_name})
    group_id = if is_nil(group), do: Ecto.UUID.generate(), else: group.id

    cond do
      is_nil(group) ->
        handle_group_creation(group_name, group_id, params, socket)

      group.name == params["task"]["group_name"] ->
        Process.send_after(self(), :clear_flash, 3000)

        {:noreply,
         socket
         |> put_flash(:error, "Group already exists. Group name should be unique.")}

      true ->
        handle_task_creation(group, params, socket)
    end
  end

  @impl true
  def handle_event("redirect_to_groups", _params, socket) do
    {:noreply,
     socket
     |> redirect(to: Routes.live_path(socket, TodoWeb.GroupLive))}
  end

  @impl true
  def handle_event("redirect_to_tasks", _params, socket) do
    {:noreply,
     socket
     |> redirect(
       to:
         Routes.live_path(socket, TodoWeb.TaskLive,
           group_id: socket.assigns.group_id,
           group_name: socket.assigns.group_name
         )
     )}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_group_creation(group_name, group_id, params, socket) do
    with {:ok, Success} <- GroupsHelper.create_group(group_name, group_id) do
      group = Repo.get_by(Groups, %{name: group_name})

      if params["task"]["task_name"] != "" do
        attrs = Map.put_new(params, "depend_on", [])
        TasksHelper.create_task(group, attrs)
      end

      tasks = ToDo.Tasks.list_tasks_by_group_name(group.name)

      updated_socket =
        socket
        |> assign(tasks: tasks)

      Process.send_after(self(), :clear_flash, 3000)

      {:noreply,
       socket
       |> put_flash(:info, "Group Added Successfully.")
       |> redirect(
         to:
           Routes.live_path(updated_socket, TodoWeb.GroupLive,
             group_name: group_name,
             group_id: group_id
           )
       )}
    else
      {:error, message} ->
        Process.send_after(self(), :clear_flash, 3000)

        {:noreply,
         socket
         |> put_flash(:error, message)}
    end
  end

  def handle_task_creation(group, params, socket) do
    attrs = Map.put_new(params, "depend_on", [])

    with {:ok, Success} <- TasksHelper.create_task(group, attrs) do
      tasks = ToDo.Tasks.list_tasks_by_group_name(group.name)

      updated_socket =
        socket
        |> assign(tasks: tasks)

      Process.send_after(self(), :clear_flash, 3000)

      {:noreply,
       socket
       |> put_flash(:info, "Task Added Successfully.")
       |> redirect(
         to:
           Routes.live_path(updated_socket, TodoWeb.TaskLive,
             group_name: group.name,
             group_id: group.id
           )
       )}
    else
      {:error, message} ->
        Process.send_after(self(), :clear_flash, 3000)

        {:noreply,
         socket
         |> put_flash(:error, message)}
    end
  end
end
