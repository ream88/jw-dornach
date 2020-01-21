defmodule DornachWeb.PageController do
  use DornachWeb, :controller
  alias DornachWeb.PageView
  alias Dornach.{Calendar, Event, GoogleCalendar}

  plug :assign_current_date
  plug :assign_calendar_dates
  plug DornachWeb.Plugs.DateTimeParser, ["event", "from"] when action in [:create]
  plug DornachWeb.Plugs.DateTimeParser, ["event", "to"] when action in [:create]

  def index(conn, _params) do
    conn
    |> assign(:event, Event.changeset(%Event{}, %{}))
    |> render("index.html")
  end

  def create(conn, %{"event" => params}) do
    changeset = Event.changeset(%Event{}, params)

    if changeset.valid? do
      event = Ecto.Changeset.apply_changes(changeset)

      Calendar.add_event(event, fn event ->
        # TODO: There is probably a better way to do this, like using bypass.
        case Application.fetch_env!(:dornach, :env) do
          :test ->
            :ok

          _ ->
            event |> Event.to_google_event() |> GoogleCalendar.create_event()
            :ok
        end
      end)

      conn
      |> put_flash(:notice, :ok)
      |> redirect(to: Routes.page_path(conn, :index, Date.to_iso8601(conn.assigns.current_date)))
    else
      conn
      # https://elixirforum.com/t/phoenix-why-not-show-changeset-errors/996/2
      |> assign(:event, %{changeset | action: :insert})
      |> put_flash(:error, :invalid)
      |> put_status(:unprocessable_entity)
      |> render("index.html")
    end
  end

  defp assign_current_date(conn, []) do
    current_date =
      case conn.params do
        %{"date" => string} ->
          {:ok, date} = Date.from_iso8601(string)
          date

        _ ->
          Date.utc_today()
      end

    conn |> assign(:current_date, current_date)
  end

  defp assign_calendar_dates(conn, []) do
    conn
    |> assign(
      :dates,
      Date.range(
        PageView.first_day_of_calendar(conn.assigns.current_date),
        PageView.last_day_of_calendar(conn.assigns.current_date)
      )
    )
  end
end
