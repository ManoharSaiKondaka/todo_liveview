defmodule ToDOWeb.LiveHelper do
  @moduledoc """
  The Liveview helper functions and Context.
  """
  use TodoWeb, :live_view

  def handle_flash_error(socket, msg, event_name) do
    {:noreply,
     socket
     |> put_flash(:error, msg)
     |> push_event(event_name, %{})}
  end

  def handle_flash_error_msg(socket, msg) do
    {:noreply,
     socket
     |> put_flash(:error, msg)}
  end
end
