defmodule Dornach.CalendarTest do
  use Dornach.DataCase, async: true
  alias Dornach.{Calendar, Event}

  test "add_event adds a new event to the list of events" do
    event = %Event{}
    :ok = Calendar.add_event(event)
    assert [event] == Calendar.get_events()
  end
end
