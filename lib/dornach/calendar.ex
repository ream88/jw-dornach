defmodule Dornach.Calendar do
  @moduledoc """
  A GenServer which is the source-of-truth for all calendar events handled by
  Dornach.
  """

  use GenServer
  require Logger
  alias Dornach.Event

  defstruct events: []

  def start_link(events) do
    GenServer.start_link(__MODULE__, events, name: __MODULE__)
  end

  @spec get_events() :: [Event.t()]
  def get_events() do
    GenServer.call(__MODULE__, :events)
  end

  @spec get_events(Date.t(), String.t()) :: [Event.t()]
  def get_events(%Date{} = date, zone \\ "UTC") do
    GenServer.call(__MODULE__, {:events, date, zone})
  end

  @spec set_events(Event.t()) :: :ok
  def set_events(events) do
    GenServer.call(__MODULE__, {:set_events, events})
  end

  @spec add_event(Event.t(), (Event.t() -> :ok | {:error, any()})) :: :ok
  def add_event(event, callback \\ fn _ -> :ok end) do
    GenServer.call(__MODULE__, {:add, event, callback})
  end

  # GenServer API

  @impl true
  def init(events) do
    {:ok, %__MODULE__{events: events}}
  end

  @impl true
  def handle_call(:events, _from, %__MODULE__{events: events} = state) do
    {:reply, events, state}
  end

  @impl true
  def handle_call({:events, date, zone}, _from, %__MODULE__{events: events} = state) do
    {:ok, from_time} = Time.new(0, 0, 0)
    {:ok, from_naive} = NaiveDateTime.new(date, from_time)
    {:ok, from} = DateTime.from_naive(from_naive, zone)

    {:ok, to_time} = Time.new(23, 59, 59, 999_999)
    {:ok, to_naive} = NaiveDateTime.new(date, to_time)
    {:ok, to} = DateTime.from_naive(to_naive, zone)

    events =
      Enum.filter(events, fn event ->
        Timex.between?(event.from, from, to) || Timex.between?(event.to, from, to)
      end)

    {:reply, events, state}
  end

  @impl true
  def handle_call({:set_events, events}, _from, %__MODULE__{} = state) do
    {:reply, :ok, %{state | events: events}}
  end

  @impl true
  def handle_call({:add, event, callback}, _from, %__MODULE__{events: events} = state) do
    case callback.(event) do
      :ok ->
        {:reply, :ok, %{state | events: events ++ [event]}}

      {:error, reason} ->
        Logger.warn("Could not add event for reason: #{inspect(reason)}")
        {:reply, :ok, state}
    end
  end
end
