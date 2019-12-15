defmodule DornachWeb.PageView do
  use DornachWeb, :view

  @selected [~D[2019-12-01], ~D[2019-12-13]]

  def first(date \\ Date.utc_today()) do
    first = %{date | day: 1}
    Date.add(first, Date.day_of_week(first) * -1 + 1)
  end

  def last(date \\ Date.utc_today()) do
    last = %{date | day: Date.days_in_month(date)}
    Date.add(last, 7 - Date.day_of_week(last))
  end

  def same_month?(a, b) do
    a.month == b.month && a.year == b.year
  end

  def color(date) do
    cond do
      date == Date.utc_today() -> "is-light"
      date in @selected -> "is-primary"
      true -> "is-white"
    end
  end
end
