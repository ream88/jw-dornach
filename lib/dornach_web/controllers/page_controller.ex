defmodule DornachWeb.PageController do
  use DornachWeb, :controller
  alias DornachWeb.PageView
  alias Dornach.{Calendar, Event}

  plug DornachWeb.Plugs.DateTimeParser, ["event", "from"] when action in [:create]
  plug DornachWeb.Plugs.DateTimeParser, ["event", "to"] when action in [:create]

  def index(conn, params) do
    conn
    |> assign_calendar_variables(params)
    |> render("index.html", event: Event.changeset(%Event{}, %{}))
  end

  @spec create(Plug.Conn.t(), nil | keyword | map) :: Plug.Conn.t()
  def create(conn, params) do
    event = Event.changeset(%Event{}, params["event"])

    if event.valid? do
      event
      |> Ecto.Changeset.apply_changes()
      |> Calendar.add_event()

      conn
      |> assign_calendar_variables(params)
      |> render("index.html", event: event)
    else
      conn
      |> assign_calendar_variables(params)
      |> put_flash(:error, :invalid)
      |> render("index.html", event: event)
    end
  end

  defp assign_calendar_variables(conn, params) do
    date =
      case params do
        %{"date" => string} ->
          {:ok, date} = Date.from_iso8601(string)
          date

        _ ->
          Date.utc_today()
      end

    conn
    |> assign(:date, date)
    |> assign(
      :dates,
      Date.range(PageView.first_day_of_calendar(date), PageView.last_day_of_calendar(date))
    )
  end
end
