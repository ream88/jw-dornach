defmodule DornachWeb.PageController do
  use DornachWeb, :controller
  alias DornachWeb.PageView
  alias Dornach.{Calendar, Event}

  plug :assign_current_date
  plug :assign_calendar_dates
  plug DornachWeb.Plugs.DateTimeParser, ["event", "from"] when action in [:create]
  plug DornachWeb.Plugs.DateTimeParser, ["event", "to"] when action in [:create]

  def index(conn, _params) do
    conn
    |> render("index.html", event: Event.changeset(%Event{}, %{}))
  end

  def create(conn, params) do
    event = Event.changeset(%Event{}, Map.get(params, "event", %{}))

    if event.valid? do
      event
      |> Ecto.Changeset.apply_changes()
      |> Calendar.add_event()

      conn
      |> put_flash(:notice, :ok)
      |> redirect(to: Routes.page_path(conn, :index, Date.to_iso8601(conn.assigns.current_date)))
    else
      # https://elixirforum.com/t/phoenix-why-not-show-changeset-errors/996/2
      event = %{event | action: :insert}

      conn
      |> put_flash(:error, :invalid)
      |> put_status(:unprocessable_entity)
      |> render("index.html", event: event)
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
