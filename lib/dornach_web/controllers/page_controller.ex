defmodule DornachWeb.PageController do
  use DornachWeb, :controller
  alias DornachWeb.PageView

  def index(conn, params) do
    date =
      case params do
        %{"date" => string} ->
          {:ok, date} = Date.from_iso8601(string)
          date

        _ ->
          Date.utc_today()
      end

    render(conn, "index.html",
      date: date,
      dates: Date.range(PageView.first(date), PageView.last(date))
    )
  end
end
