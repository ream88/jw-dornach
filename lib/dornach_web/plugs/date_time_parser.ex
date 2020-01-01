defmodule DornachWeb.Plugs.DateTimeParser do
  @moduledoc """
  Parses and updates the given params as DateTime.

  ## Examples

      plug DateTimeParser, "param"
      plug DateTimeParser, ["nested", "param"]
  """

  def init(opts), do: opts

  def call(conn, keys) do
    case keys do
      [] ->
        conn

      key when not is_list(key) ->
        call(conn, [key])

      keys ->
        case get_in(conn.params, keys) do
          nil -> conn
          _ -> %{conn | params: update_in(conn.params, keys, &parse_time/1)}
        end
    end
  end

  defp parse_time(string) do
    case DateTime.from_iso8601(string) do
      {:ok, datetime, _} -> datetime
      _ -> string
    end
  end
end
