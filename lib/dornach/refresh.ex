defmodule Dornach.Refresh do
  @moduledoc """
  This GenServer is used to sync the events from Google Calendar to Dornach
  periodically.

  This GenServer is very simple on purpose, and does not know anything about
  Google Calendar or how Dornach stores its events. Its only job is to run the
  given callback periodically.
  """

  use GenServer

  @type state :: {fun(), integer()}

  @spec start_link(fun(), integer()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(callback, interval \\ interval()) do
    GenServer.start(__MODULE__, {callback, interval}, name: __MODULE__)
  end

  @spec refresh :: :ok
  def refresh() do
    GenServer.call(__MODULE__, :manual)
  end

  # GenServer API

  @impl true
  @spec init(state()) :: {:ok, state(), {:continue, :initial}}
  def init({callback, interval}) do
    {:ok, {callback, interval}, {:continue, :initial}}
  end

  @impl true
  @spec handle_continue(:initial, state()) :: {:noreply, state()}
  def handle_continue(:initial, {callback, interval}) do
    send(self(), :periodic)
    {:noreply, {callback, interval}}
  end

  @impl true
  @spec handle_call(:manual, any(), state()) :: {:reply, :ok, state()}
  def handle_call(:manual, _, {callback, interval}) do
    callback.()
    {:reply, :ok, {callback, interval}}
  end

  @impl true
  @spec handle_info(:periodic, state()) :: {:noreply, state()}
  def handle_info(:periodic, {callback, interval}) do
    callback.()
    Process.send_after(self(), :periodic, interval)
    {:noreply, {callback, interval}}
  end

  @spec interval :: integer()
  defp interval() do
    case Application.fetch_env!(:dornach, :refresh_interval) do
      {:system, env_var} -> env_var |> System.get_env() |> String.to_integer()
      interval -> interval
    end
  end
end
