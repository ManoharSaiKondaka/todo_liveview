defmodule TodoWeb.GroupLive do
  use TodoWeb, :live_view
  alias ToDo.Groups
  # alias ToDo.Tasks

  @impl true
  def mount(_params, _session, socket) do
    groups = Groups.list_groups()
    Process.send_after(self(), :clear_flash, 3000)

    {:ok,
     socket
     |> assign(groups: groups)}
  end

  @impl true
  def handle_event("open_group", params, socket) do
    {:noreply,
     socket
     |> redirect(
       to:
         Routes.live_path(socket, TodoWeb.TaskLive,
           group_id: params["group_id"],
           group_name: params["group_name"]
         )
     )}
  end

  @impl true
  def handle_event("add_group", _params, socket) do
    {:noreply,
     socket
     |> redirect(to: Routes.live_path(socket, TodoWeb.AddLive))}
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
