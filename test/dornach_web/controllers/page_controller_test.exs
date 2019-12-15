defmodule DornachWeb.PageControllerTest do
  use DornachWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "JW Dornach"
  end
end
