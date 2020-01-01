defmodule Dornach.Calendar do
  @moduledoc """
  A GenServer which is the source-of-truth for all calendar events handled by
  Dornach.
  """

  use GenServer
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

  @spec add_event(Event.t()) :: :ok
  def add_event(event) do
    GenServer.call(__MODULE__, {:add, event})
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
  def handle_call({:add, event}, _from, %__MODULE__{events: events} = state) do
    events = events ++ [event]
    {:reply, :ok, %{state | events: events}}
  end
end
