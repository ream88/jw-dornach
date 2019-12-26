defmodule Dornach.CalendarTest do
  use Dornach.DataCase, async: true
  alias Dornach.{Calendar, Event}

  test "add_event adds a new event to the list of events" do
    event = %Event{}
    :ok = Calendar.add_event(event)
    assert [event] == Calendar.get_events()
  end

  test "set_events (re)sets the list of events" do
    events = [%Event{id: 1}, %Event{id: 2}]
    :ok = Calendar.set_events(events)
    assert events == Calendar.get_events()

    events = [%Event{id: 1}]
    :ok = Calendar.set_events(events)
    assert events == Calendar.get_events()
  end
end
