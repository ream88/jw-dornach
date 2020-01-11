defmodule DornachWeb.SelectHelpersTest do
  use Dornach.CalendarCase, async: false
  alias Dornach.{Calendar, Event}
  alias DornachWeb.SelectHelpers

  describe "from_options" do
    test "returns options for the given date" do
      changeset = Event.changeset(%Event{}, %{})
      options = SelectHelpers.from_options(%Phoenix.HTML.Form{source: changeset}, ~D[2020-01-05])

      assert Enum.count(options) == 24 * 4
      assert Enum.count(options, &Keyword.get(&1, :selected)) == 1

      assert [
               key: "00:00",
               value: "2020-01-04T23:00:00+00:00",
               disabled: false,
               selected: true
             ] == hd(options)
    end

    test "options are disabled for existing events" do
      Calendar.add_event(%Event{from: ~U[2020-01-05 01:00:00Z], to: ~U[2020-01-05 02:00:00Z]})
      changeset = Event.changeset(%Event{}, %{})
      options = SelectHelpers.from_options(%Phoenix.HTML.Form{source: changeset}, ~D[2020-01-05])

      assert Enum.count(options, &Keyword.get(&1, :disabled)) == 4
    end
  end

  describe "to_options" do
    test "returns options for the given date" do
      changeset = Event.changeset(%Event{}, %{})
      options = SelectHelpers.to_options(%Phoenix.HTML.Form{source: changeset}, ~D[2020-01-05])

      # Returns always one less option, so the minimum selectable amount is 15 minutes.
      assert Enum.count(options) == 24 * 4 - 1
      assert Enum.count(options, &Keyword.get(&1, :selected)) == 1

      assert [
               key: "00:15 – ¼ h",
               value: "2020-01-04T23:15:00+00:00",
               disabled: false,
               selected: true
             ] = hd(options)
    end

    test "options are removed based on the from param" do
      changeset = Event.changeset(%Event{}, %{from: ~U[2020-01-05 11:00:00Z]})
      form = %Phoenix.HTML.Form{source: changeset}
      options = SelectHelpers.to_options(form, ~D[2020-01-05])

      assert Enum.count(options) == 12 * 4 - 1

      assert [
               key: "12:15 – ¼ h",
               value: "2020-01-05T11:15:00+00:00",
               disabled: false,
               selected: false
             ] = hd(options)
    end
  end
end
