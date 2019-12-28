defmodule DornachWeb.PageView do
  use DornachWeb, :view

  def first_day_of_calendar(date \\ Date.utc_today()) do
    first = %{date | day: 1}
    Date.add(first, Date.day_of_week(first) * -1 + 1)
  end

  def last_day_of_calendar(date \\ Date.utc_today()) do
    last = %{date | day: Date.days_in_month(date)}
    Date.add(last, 7 - Date.day_of_week(last))
  end

  def first_day_of_previous_month(date) do
    {year, month, _} = Date.to_erl(date)
    max = Date.months_in_year(date)

    {:ok, date} =
      case month do
        1 -> Date.new(year - 1, max, 1)
        month -> Date.new(year, month - 1, 1)
      end

    date
  end

  def first_day_of_next_month(date) do
    {year, month, _} = Date.to_erl(date)
    max = Date.months_in_year(date)

    {:ok, date} =
      case month do
        ^max -> Date.new(year + 1, 1, 1)
        month -> Date.new(year, month + 1, 1)
      end

    date
  end

  def same_month?(a, b) do
    a.month == b.month && a.year == b.year
  end

  def color(date) do
    events =
      Dornach.Calendar.get_events()
      |> Enum.map(fn %Dornach.Event{from: from} -> DateTime.to_date(from) end)

    cond do
      date == Date.utc_today() -> "is-light"
      date in events -> "is-primary"
      true -> "is-white"
    end
  end
end
