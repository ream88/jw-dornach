defmodule Dornach.CalendarTest do
  use ExUnit.Case, async: true
  alias Dornach.{Calendar, Event}

  test "add adds a new event to the list of events" do
    event = %Event{}
    :ok = Calendar.add(event)
    assert [event] == Calendar.events()
  end
end
