defmodule TodoWeb.TaskLive do
  use TodoWeb, :live_view
  alias ToDo.Tasks
  alias Todo.Repo
  alias ToDo.Groups
  alias Todo.TasksHelper
  alias Todo.GroupsHelper
  use Ecto.Schema

  @impl true
  def mount(params, _session, socket) do
    group_id = params["group_id"]
    group_name = params["group_name"]

    tasks = Tasks.list_tasks_by_group_name(group_name)
    Process.send_after(self(), :clear_flash, 3000)

    {:ok,
     socket
     |> assign(tasks: tasks)
     |> assign(group_id: group_id)
     |> assign(completed: false)
     |> assign(group_name: group_name)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("add_task", _params, socket) do
    {:noreply,
     socket
     |> redirect(
       to:
         Routes.live_path(socket, TodoWeb.AddLive,
           group_id: socket.assigns.group_id,
           group_name: socket.assigns.group_name
         )
     )}
  end

  def handle_event("redirect_to_groups", _params, socket) do
    {:noreply,
     socket
     |> redirect(to: Routes.live_path(socket, TodoWeb.GroupLive))}
  end

  @impl true
  def handle_event("change_status", params, socket) do
    completed = String.to_atom(params["completed"])
    Tasks.update_task_completed_status(params["task_id"], completed)
    tasks = ToDo.Tasks.list_tasks_by_group_name(socket.assigns.group_name)
    group = Repo.get_by(Groups, %{name: socket.assigns.group_name})
    GroupsHelper.update_task_completed_in_group(group, completed)

    updated_socket =
      socket
      |> assign(completed: completed)
      |> assign(tasks: tasks)

    {:noreply, updated_socket}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
