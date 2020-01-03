defmodule DornachWeb.PageControllerTest do
  use DornachWeb.ConnCase

  defp has_class?(html, class) do
    html
    |> Floki.attribute("class")
    |> List.flatten()
    |> Enum.map(&String.split/1)
    |> List.flatten()
    |> Enum.member?(class)
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200)
  end

  test "GET /2020-01-02", %{conn: conn} do
    conn = get(conn, "/2020-01-02")

    {:ok, html} = Floki.parse_document(conn.resp_body)
    button = Floki.find(html, ".calendar a.button[href='/2020-01-02']")

    assert Enum.count(button) == 1
    assert has_class?(button, "has-border")
  end

  test "POST /2020-01-02", %{conn: conn} do
    conn = post(conn, "/2020-01-02", %{})

    assert html_response(conn, 422) =~ "Bitte überprüfe deine Eingaben!"

    {:ok, html} = Floki.parse_document(conn.resp_body)

    assert has_class?(Floki.find(html, "#event_title"), "is-danger")
    assert has_class?(Floki.find(html, ".select"), "is-danger")
  end

  test "POST /2020-01-02 with valid params", %{conn: conn} do
    conn =
      post(conn, "/2020-01-02", %{
        "event" => %{
          "title" => "Ida & Mario",
          "from" => "2020-01-02T08:00:00+00:00",
          "to" => "2020-01-03T10:00:00+00:00"
        }
      })

    assert "/2020-01-02" = redirected_to(conn, 302)

    conn = get(recycle(conn), "/2020-01-02")
    assert html_response(conn, 200) =~ "Dein Termin wurde eingetragen!"

    {:ok, html} = Floki.parse_document(conn.resp_body)
    button = Floki.find(html, ".calendar a.button[href='/2020-01-02']")

    assert Enum.count(button) == 1
    assert has_class?(button, "is-primary")
  end
end
