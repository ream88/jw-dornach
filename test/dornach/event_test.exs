defmodule Dornach.EventTest do
  use Dornach.CalendarCase, async: false
  alias Dornach.{Calendar, Event}
  doctest Event

  @nineoclock ~U[2019-12-23 09:00:00Z]
  @elevenoclock ~U[2019-12-23 11:00:00Z]

  test "changeset does not fail even if from and to are not given" do
    assert Event.changeset(%Event{}, %{})
  end

  test "changeset is invalid if to is not in the future of from" do
    attrs = %{title: "Ida & Mario", from: @elevenoclock, to: @nineoclock}

    changeset = Event.changeset(%Event{}, attrs)
    refute changeset.valid?
    assert %{to: ["must be greater than from"]} = errors_on(changeset)
  end

  test "changeset is invalid if to is not in the future of from when updating an event" do
    attrs = %{title: "Ida & Mario", from: @nineoclock, to: @elevenoclock}
    event = %Event{} |> Event.changeset(attrs) |> Ecto.Changeset.apply_changes()

    changeset = Event.changeset(event, %{to: @nineoclock})
    refute changeset.valid?
    assert %{to: ["must be greater than from"]} = errors_on(changeset)
  end

  test "changeset is invalid if another event is overlapping" do
    attrs = %{title: "Ida & Mario", from: @nineoclock, to: @elevenoclock}

    :ok =
      %Event{}
      |> Event.changeset(attrs)
      |> Ecto.Changeset.apply_changes()
      |> Calendar.add_event()

    changeset = Event.changeset(%Event{}, attrs)
    refute changeset.valid?
    assert %{from: ["is overlapping"]} = errors_on(changeset)
  end

  test "changeset is valid if proper attributes are given" do
    attrs = %{title: "Ida & Mario", from: @nineoclock, to: @elevenoclock}

    changeset = Event.changeset(%Event{}, attrs)
    assert changeset.valid?
  end
end
