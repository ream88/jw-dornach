defmodule NimbleStrftime.German do
  @moduledoc """
  (Austrian) German translations for NimbleStrftime.
  """

  def day_of_week_names(day_of_week) do
    {"Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"}
    |> elem(day_of_week - 1)
  end

  def abbreviated_day_of_week_names(day_of_week) do
    {"Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"}
    |> elem(day_of_week - 1)
  end

  def month_names(month) do
    {"Jänner", "Feber", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober",
     "November", "Dezember"}
    |> elem(month - 1)
  end
end
