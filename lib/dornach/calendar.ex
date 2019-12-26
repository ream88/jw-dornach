defmodule Dornach.Calendar do
  use GenServer

  defstruct events: []

  def start_link(events) do
    GenServer.start_link(__MODULE__, events, name: __MODULE__)
  end

  def get_events() do
    GenServer.call(__MODULE__, :events)
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
  def handle_call(:events, _from, state) do
    {:reply, state.events, state}
  end

  @impl true
  def handle_call({:add, event}, _from, %{events: events} = state) do
    events = [event | events]
    {:reply, :ok, %{state | events: events}}
  end
end
