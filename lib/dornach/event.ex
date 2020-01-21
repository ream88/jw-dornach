defmodule Dornach.Event do
  @moduledoc """
  The calendar event model.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Dornach.Calendar
  alias GoogleApi.Calendar.V3.Model.Event, as: GoogleEvent
  alias GoogleApi.Calendar.V3.Model.EventDateTime, as: GoogleDateTime

  @type t :: %__MODULE__{title: String.t(), from: DateTime.t(), to: DateTime.t()}

  embedded_schema do
    field :title, :string
    field :from, :utc_datetime
    field :to, :utc_datetime
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :from, :to])
    |> validate_required([:title, :from, :to])
    |> validate_dates()
    |> validate_overlap()
  end

  defp validate_dates(changeset) do
    from = fetch_field!(changeset, :from)
    to = fetch_field!(changeset, :to)

    if from >= to do
      add_error(changeset, :to, "must be greater than from")
    else
      changeset
    end
  end

  defp validate_overlap(changeset) do
    from = fetch_field!(changeset, :from)
    to = fetch_field!(changeset, :to)

    Calendar.get_events()
    |> Enum.reduce(changeset, fn event, changeset ->
      if overlap?({from, to}, {event.from, event.to}) do
        add_error(changeset, :from, "is overlapping")
      else
        changeset
      end
    end)
  end

  @doc """
  Checks whether the given time ranges overlap.

  ## Examples

      iex> Dornach.Event.overlap?({~U[2019-12-23 09:00:00Z], ~U[2019-12-23 11:00:00Z]}, {~U[2019-12-23 09:00:00Z], ~U[2019-12-23 11:00:00Z]})
      true

      iex> Dornach.Event.overlap?({~U[2019-12-23 09:00:00Z], ~U[2019-12-23 11:00:00Z]}, {~U[2019-12-23 09:30:00Z], ~U[2019-12-23 11:30:00Z]})
      true

      iex> Dornach.Event.overlap?({~U[2019-12-23 09:00:00Z], ~U[2019-12-23 11:00:00Z]}, {~U[2019-12-23 07:00:00Z], ~U[2019-12-23 13:00:00Z]})
      true

      iex> Dornach.Event.overlap?({~U[2019-12-23 09:00:00Z], ~U[2019-12-23 11:00:00Z]}, {~U[2019-12-23 11:00:00Z], ~U[2019-12-23 13:00:00Z]})
      false

      iex> Dornach.Event.overlap?({~U[2019-12-23 09:00:00Z], ~U[2019-12-23 11:00:00Z]}, {~U[2019-12-23 07:00:00Z], ~U[2019-12-23 09:00:00Z]})
      false
  """
  def overlap?({from, to}, {other_from, other_to}) do
    from < other_to && other_from < to
  end

  @spec from_google_event(GoogleEvent.t()) :: t()
  def from_google_event(%GoogleEvent{} = google_event) do
    %__MODULE__{
      title: google_event.summary,
      from: google_event.start.dateTime,
      to: google_event.end.dateTime
    }
  end

  @spec to_google_event(t()) :: GoogleDateTime.t()
  def to_google_event(%__MODULE__{} = event) do
    %GoogleEvent{
      summary: event.title,
      start: %GoogleDateTime{dateTime: event.from},
      end: %GoogleDateTime{dateTime: event.to}
    }
  end
end
