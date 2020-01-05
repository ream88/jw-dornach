defmodule Dornach.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  # Embed Mix.env into compiled app.
  @env Mix.env()

  def env(), do: @env

  def start(_type, _args) do
    children = [
      # Load events from Google Calendar on startup
      {Dornach.Calendar, load_events(env())},
      DornachWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Dornach.Supervisor)
  end

  def load_events(:test), do: []

  def load_events(_) do
    Dornach.GoogleCalendar.find_events()
    |> Enum.map(&Dornach.Event.from_google_event/1)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DornachWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
