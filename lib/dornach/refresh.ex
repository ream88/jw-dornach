defmodule Dornach.Refresh do
  @moduledoc """
  This GenServer is used to sync the events from Google Calendar to Dornach
  periodically.

  This GenServer is very simple on purpose, and does not know anything about
  Google Calendar or how Dornach stores its events. Its only job is to run the
  given callback periodically.
  """

  use GenServer

  def start_link(callback, interval \\ interval()) do
    GenServer.start(__MODULE__, {callback, interval}, name: __MODULE__)
  end

  def refresh() do
    GenServer.call(__MODULE__, :manual)
  end

  # GenServer API

  @impl true
  def init({callback, interval}) do
    {:ok, {callback, interval}, {:continue, :initial}}
  end

  @impl true
  def handle_continue(:initial, {callback, interval}) do
    send(self(), :periodic)
    {:noreply, {callback, interval}}
  end

  @impl true
  def handle_call(:manual, _, {callback, interval}) do
    callback.()
    {:reply, :ok, {callback, interval}}
  end

  @impl true
  def handle_info(:periodic, {callback, interval}) do
    callback.()
    Process.send_after(self(), :periodic, interval)
    {:noreply, {callback, interval}}
  end

  defp interval() do
    case Application.fetch_env!(:dornach, :refresh_interval) do
      {:system, env_var} -> env_var |> System.get_env() |> String.to_integer()
      interval -> interval
    end
  end
end
