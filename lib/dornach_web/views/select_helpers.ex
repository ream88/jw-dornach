defmodule DornachWeb.SelectHelpers do
  @moduledoc """
  A module which helps with creating the select fields for the event datetimes.
  """

  defmodule Option do
    @moduledoc false

    defstruct local: nil, utc: nil, disabled: false, selected: false
  end

  @opaque option :: [key: String.t(), value: String.t(), disabled: boolean(), selected: boolean()]

  alias Dornach.Calendar
  alias DornachWeb.SelectHelpers.Option

  @spec from_options(Phoenix.HTML.Form.t(), Date.t()) :: [option()]
  def from_options(form, date) do
    events = Calendar.get_events(date)
    from = fetch_field(form, :from, default(:from, date))

    date
    |> options()
    |> Enum.map(fn %{local: local, utc: utc} ->
      [
        key: NimbleStrftime.format(local, "%H:%M"),
        value: DateTime.to_iso8601(utc),
        disabled: Enum.any?(events, &Timex.between?(utc, &1.from, &1.to, inclusive: :start)),
        selected: DateTime.compare(utc, from) == :eq
      ]
    end)
  end

  @spec to_options(Phoenix.HTML.Form.t(), Date.t()) :: [option()]
  def to_options(form, date) do
    from = fetch_field(form, :from, default(:from, date))
    to = fetch_field(form, :to, default(:to, date))

    date
    |> options()
    |> Enum.filter(fn %{utc: utc} -> DateTime.compare(from, utc) == :lt end)
    |> Enum.map(fn %{local: local, utc: utc} ->
      key = NimbleStrftime.format(local, "%H:%M") <> " – " <> duration_in_hours(from, utc) <> " h"

      [
        key: key,
        value: DateTime.to_iso8601(utc),
        disabled: false,
        selected: DateTime.compare(utc, to) == :eq
      ]
    end)
  end

  defp options(date) do
    for hour <- 0..23 do
      for minute <- Enum.take_every(0..59, 15) do
        {:ok, time} = Time.new(hour, minute, 0)
        {:ok, naive} = NaiveDateTime.new(date, time)
        {:ok, local} = DateTime.from_naive(naive, "Europe/Vienna")
        {:ok, utc} = DateTime.shift_zone(local, "UTC")

        %Option{local: local, utc: utc}
      end
    end
    |> List.flatten()
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

  defp fetch_field(form, field, default_value) do
    case Ecto.Changeset.fetch_field!(form.source, field) do
      nil -> default_value
      value -> value
    end
  end

  defp default(:from, date) do
    {:ok, time} = Time.new(0, 0, 0)
    {:ok, naive} = NaiveDateTime.new(date, time)
    {:ok, local} = DateTime.from_naive(naive, "Europe/Vienna")

    local
  end

  defp default(:to, date) do
    default(:from, date) |> DateTime.add(900, :second)
  end
end
