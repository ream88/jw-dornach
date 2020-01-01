defmodule Dornach.CalendarTest do
  use Dornach.DataCase, async: true
  alias Dornach.{Calendar, Event}

  test "add_event adds a new event to the list of events" do
    event = %Event{}
    :ok = Calendar.add_event(event)
    assert [event] == Calendar.get_events()
  end

  describe "get_events" do
    setup do
      events = [
        %Event{from: ~U[2019-12-26 09:00:00Z], to: ~U[2019-12-26 11:00:00Z]},
        %Event{from: ~U[2019-12-26 23:00:00Z], to: ~U[2019-12-27 01:00:00Z]},
        %Event{from: ~U[2019-12-28 09:00:00Z], to: ~U[2019-12-28 11:00:00Z]}
      ]

      Enum.each(events, &Calendar.add_event/1)

      {:ok, events: events}
    end

    test "get_events returns all events", %{events: events} do
      assert events == Calendar.get_events()
    end

    test "get_events returns events for the given date", %{events: [first, second, _]} do
      assert [first, second] == Calendar.get_events(~D[2019-12-26])
    end

    test "get_events returns events for the given date and timezone", %{events: [_, _, third]} do
      assert [third] == Calendar.get_events(~D[2019-12-27], "US/Hawaii")
    end
  end
end
