defmodule DornachWeb.Router do
  use DornachWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DornachWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/:date", PageController, :index
    post "/", PageController, :create
    post "/:date", PageController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", DornachWeb do
  #   pipe_through :api
  # end
end
