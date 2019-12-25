defmodule Dornach.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Dornach.Calendar,
      DornachWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Dornach.Supervisor)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DornachWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
