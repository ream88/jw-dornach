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

  def get_events() do
    GenServer.call(__MODULE__, :events)
  end

  def get_events(%Date{} = date) do
    GenServer.call(__MODULE__, {:events, date, date})
  end

  def get_events(%Date{} = from, %Date{} = to) do
    GenServer.call(__MODULE__, {:events, from, to})
  end

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
  def handle_call({:events, from, to}, _from, %__MODULE__{events: events} = state) do
    range = Date.range(from, to)

    events =
      Enum.filter(events, fn %Event{} = event ->
        DateTime.to_date(event.from) in range or DateTime.to_date(event.to) in range
      end)

    {:reply, events, state}
  end

  @impl true
  def handle_call({:add, event}, _from, %__MODULE__{events: events} = state) do
    events = events ++ [event]
    {:reply, :ok, %{state | events: events}}
  end
end
