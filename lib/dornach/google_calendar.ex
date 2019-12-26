defmodule Dornach.GoogleCalendar do
  require Logger

  @api_key Application.fetch_env!(:dornach, :google_api_key)
  @calendar_id "8k0kfnfhtbno2ck9m21lvj5s9k@group.calendar.google.com"

  def find_events() do
    now = Date.utc_today()
    from = now |> Timex.beginning_of_month()
    to = now |> Timex.end_of_month()

    find_events(from, to)
  end

  def find_events(%Date{} = date) do
    find_events(date, date)
  end

  def find_events(%Date{} = from, %Date{} = to) do
    from = from |> Timex.to_datetime() |> Timex.beginning_of_day()
    to = to |> Timex.to_datetime() |> Timex.end_of_day()

    conn = GoogleApi.Calendar.V3.Connection.new()

    Logger.debug("Searching Google Calendar events between #{from} and #{to}")

    {:ok, events} =
      GoogleApi.Calendar.V3.Api.Events.calendar_events_list(conn, @calendar_id,
        key: @api_key,
        timeMin: DateTime.to_iso8601(from),
        timeMax: DateTime.to_iso8601(to)
      )

    events.items
  end
end
