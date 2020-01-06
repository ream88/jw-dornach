defmodule DornachWeb.PageView do
  use DornachWeb, :view
  import DornachWeb.SelectHelpers

  @doc """
  Returns the first day for a calendar. As this calendar always starts with a
  Monday, this day could be in the previous month of the given date.

  ## Examples

      iex> first_day_of_calendar(~D[2019-11-01])
      ~D[2019-10-28]

      iex> first_day_of_calendar(~D[2019-12-01])
      ~D[2019-11-25]

      iex> first_day_of_calendar(~D[2020-01-01])
      ~D[2019-12-30]

  """
  def first_day_of_calendar(date \\ Date.utc_today()) do
    first = %{date | day: 1}
    Date.add(first, Date.day_of_week(first) * -1 + 1)
  end

  @doc """
  Returns the last day for a calendar. As this calendar always ends with a
  Sunday, this day could be in the next month of the given date.

  ## Examples

      iex> last_day_of_calendar(~D[2019-11-01])
      ~D[2019-12-01]

      iex> last_day_of_calendar(~D[2019-12-01])
      ~D[2020-01-05]

      iex> last_day_of_calendar(~D[2020-01-01])
      ~D[2020-02-02]

  """
  def last_day_of_calendar(date \\ Date.utc_today()) do
    last = %{date | day: Date.days_in_month(date)}
    Date.add(last, 7 - Date.day_of_week(last))
  end

  @doc """
  Returns the first day of the previous month for the given date.

  ## Examples

      iex> first_day_of_previous_month(~D[2019-11-01])
      ~D[2019-10-01]

      iex> first_day_of_previous_month(~D[2019-01-01])
      ~D[2018-12-01]

  """
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

  @doc """
  Returns the first day of the next month for the given date.

  ## Examples

    iex> first_day_of_next_month(~D[2019-11-01])
    ~D[2019-12-01]

    iex> first_day_of_next_month(~D[2019-12-01])
    ~D[2020-01-01]

  """
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
      |> Enum.map(& &1.from)
      |> Enum.map(fn datetime ->
        {:ok, datetime} = DateTime.shift_zone(datetime, "Europe/Vienna")
        datetime
      end)
      |> Enum.map(&DateTime.to_date/1)

    cond do
      date in events -> "is-primary"
      date == Date.utc_today() -> "is-light"
      true -> "is-white"
    end
  end
end
