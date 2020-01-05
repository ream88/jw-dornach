defmodule DornachWeb.PageView do
  use DornachWeb, :view

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

  defp times(date) do
    for hour <- 0..23 do
      for minute <- Enum.take_every(0..59, 15) do
        {:ok, time} = Time.new(hour, minute, 0)
        {:ok, naive} = NaiveDateTime.new(date, time)
        {:ok, datetime} = DateTime.from_naive(naive, "Europe/Vienna")
        {:ok, utc_datetime} = DateTime.shift_zone(datetime, "UTC")

        {utc_datetime, datetime}
      end
    end
    |> List.flatten()
  end

  def from_select(form, date, opts \\ []) do
    options =
      date
      |> times()
      |> Enum.map(fn {utc_datetime, datetime} ->
        {NimbleStrftime.format(datetime, "%H:%M"), DateTime.to_iso8601(utc_datetime)}
      end)

    value = local_datetime_value(form, :from)
    select(form, :from, options, Keyword.merge([value: value], opts))
  end

  def to_select(form, date, opts \\ []) do
    from =
      case Ecto.Changeset.fetch_field!(form.source, :from) do
        nil ->
          {:ok, time} = Time.new(0, 0, 0)
          {:ok, naive} = NaiveDateTime.new(date, time)
          {:ok, datetime} = DateTime.from_naive(naive, "Europe/Vienna")

          datetime

        from ->
          from
      end

    options =
      date
      |> times()
      |> Enum.filter(fn {utc_datetime, _datetime} ->
        case from do
          nil -> true
          from -> DateTime.compare(from, utc_datetime) == :lt
        end
      end)
      |> Enum.map(fn {utc_datetime, datetime} ->
        value =
          NimbleStrftime.format(datetime, "%H:%M") <>
            " – " <> duration_in_hours(from, utc_datetime) <> " h"

        {value, DateTime.to_iso8601(utc_datetime)}
      end)

    value = local_datetime_value(form, :to)
    select(form, :to, options, Keyword.merge([value: value], opts))
  end

  defp duration_in_hours(from, to) do
    diff = DateTime.diff(to, from, :second)

    case {div(diff, 3600), rem(diff, 3600)} do
      {0, 900} -> "¼"
      {0, 1800} -> "½"
      {0, 2700} -> "¾"
      {quotient, 0} -> to_string(quotient)
      {quotient, 900} -> to_string(quotient) <> " ¼"
      {quotient, 1800} -> to_string(quotient) <> " ½"
      {quotient, 2700} -> to_string(quotient) <> " ¾"
      _ -> ""
    end
  end

  defp local_datetime_value(form, field) do
    case Ecto.Changeset.fetch_field!(form.source, field) do
      nil ->
        nil

      datetime ->
        {:ok, utc_datetime} = DateTime.shift_zone(datetime, "UTC")
        DateTime.to_iso8601(utc_datetime)
    end
  end
end
