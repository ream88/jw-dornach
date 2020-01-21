defmodule Dornach.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Dornach.Calendar,
      {Dornach.Refresh, load_events(Application.fetch_env!(:dornach, :env))},
      DornachWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Dornach.Supervisor)
  end

  def load_events(:test), do: fn -> nil end

  def load_events(_) do
    fn ->
      from = Date.utc_today() |> Timex.beginning_of_month()
      to = Date.utc_today() |> Date.add(180) |> Timex.end_of_month()

      Dornach.GoogleCalendar.find_events(from, to)
      |> Enum.map(&Dornach.Event.from_google_event/1)
      |> Dornach.Calendar.set_events()
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DornachWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
