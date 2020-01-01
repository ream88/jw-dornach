defmodule DornachWeb.Plugs.DateTimeParserTest do
  use DornachWeb.ConnCase
  alias DornachWeb.Plugs.DateTimeParser

  test "given param is properly parsed to time" do
    conn =
      build_conn(:post, "/", %{"time" => "2019-12-31 09:00:00Z"})
      |> DateTimeParser.call("time")

    assert get_in(conn.params, ["time"]) == ~U[2019-12-31 09:00:00Z]
  end

  test "nested param is also properly parsed" do
    conn =
      build_conn(:post, "/", %{"event" => %{"time" => "2019-12-31 09:00:00Z"}})
      |> DateTimeParser.call(["event", "time"])

    assert get_in(conn.params, ["event", "time"]) == ~U[2019-12-31 09:00:00Z]
  end

  test "other params are ignored" do
    conn =
      build_conn(:post, "/", %{"other" => "2019-12-31 09:00:00Z"})
      |> DateTimeParser.call(["time"])

    assert get_in(conn.params, ["other"]) == "2019-12-31 09:00:00Z"
  end
end
