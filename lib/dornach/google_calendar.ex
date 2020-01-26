defmodule Dornach.GoogleCalendar do
  @moduledoc """
  A module which simplifies the API for Google Calendar.
  """

  require Logger

  def find_events do
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

    Logger.info("Looking for Google Calendar events between #{from} and #{to}")

    {:ok, events} =
      GoogleApi.Calendar.V3.Api.Events.calendar_events_list(conn(), calendar_id(),
        timeMin: DateTime.to_iso8601(from),
        timeMax: DateTime.to_iso8601(to)
      )

    events.items
  end

  def create_event(%GoogleApi.Calendar.V3.Model.Event{} = event) do
    Logger.info(
      "Creating Google Calendar event #{inspect(event.summary)} on #{event.start.dateTime}"
    )

    {:ok, event} =
      GoogleApi.Calendar.V3.Api.Events.calendar_events_insert(conn(), calendar_id(), body: event)

    event
  end

  defp conn do
    {:ok, %{token: token}} = Goth.Token.for_scope("https://www.googleapis.com/auth/calendar")
    GoogleApi.Calendar.V3.Connection.new(token)
  end

  defp calendar_id do
    case Application.fetch_env!(:dornach, :google_calendar_id) do
      {:system, env_var} -> System.get_env(env_var)
      calendar_id -> calendar_id
    end
  end
end
