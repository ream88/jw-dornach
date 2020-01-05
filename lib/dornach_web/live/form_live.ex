defmodule DornachWeb.FormLive do
  @moduledoc """
  A Phoenix LiveView which improves UX for the form.
  """

  use Phoenix.LiveView
  alias Dornach.Event

  def mount(
        %{csrf_token: csrf_token, event: event, current_date: current_date} = _session,
        socket
      ) do
    socket =
      socket
      # TODO: Change this once https://github.com/phoenixframework/phoenix_live_view/pull/488 is ready.
      |> assign(:csrf_token, csrf_token)
      |> assign(:event, event)
      |> assign(:current_date, current_date)

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(DornachWeb.PageView, "_form.html", assigns)
  end

  def handle_event("change", %{"event" => params}, socket) do
    socket =
      socket
      |> assign(event: Event.changeset(socket.assigns.event, params))

    {:noreply, socket}
  end
end
