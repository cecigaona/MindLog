defmodule MindlogWeb.Router do
  use MindlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MindlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MindlogWeb do
    pipe_through :browser

    get "/", JournalController, :index
    post "/entries", JournalController, :create
    get "/entries/:id", JournalController, :show
    delete "/entries/:id", JournalController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", MindlogWeb do
  #   pipe_through :api
  # end
end
