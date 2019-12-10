defmodule DornachWeb.PageController do
  use DornachWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
