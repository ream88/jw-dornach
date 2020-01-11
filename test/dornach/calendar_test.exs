defmodule Dornach.CalendarTest do
  use Dornach.CalendarCase, async: false
  alias Dornach.{Calendar, Event}

  describe "add_event" do
    test "adds a new event to the list of events" do
      event = %Event{}
      :ok = Calendar.add_event(event)
      assert [event] == Calendar.get_events()
    end

    test "runs the given callback before returning" do
      pid = self()

      callback = fn event ->
        send(pid, {:callback, event})
        :ok
      end

      event = %Event{}
      :ok = Calendar.add_event(event, callback)

      assert_received {:callback, event}
    end

    @tag capture_log: true
    test "does not explode when the gicen callback fails" do
      :ok = Calendar.add_event(%Event{}, fn _ -> {:error, "boom"} end)

      assert [] == Calendar.get_events()
    end
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

    test "returns all events", %{events: events} do
      assert events == Calendar.get_events()
    end

    test "returns events for the given date", %{events: [first, second, _]} do
      assert [first, second] == Calendar.get_events(~D[2019-12-26])
    end

    test "returns events for the given date and timezone", %{events: [_, _, third]} do
      assert [third] == Calendar.get_events(~D[2019-12-27], "US/Hawaii")
    end
  end

  describe "set_events" do
    test "overrides all events" do
      [first, second, third] = [
        %Event{from: ~U[2019-12-26 09:00:00Z], to: ~U[2019-12-26 11:00:00Z]},
        %Event{from: ~U[2019-12-26 23:00:00Z], to: ~U[2019-12-27 01:00:00Z]},
        %Event{from: ~U[2019-12-28 09:00:00Z], to: ~U[2019-12-28 11:00:00Z]}
      ]

      Calendar.add_event(first)
      assert [first] == Calendar.get_events()

      Calendar.set_events([second, third])
      assert [second, third] == Calendar.get_events()
    end
  end
end
