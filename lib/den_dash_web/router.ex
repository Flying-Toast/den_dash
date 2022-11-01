defmodule DenDashWeb.Router do
  use DenDashWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DenDashWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", DenDashWeb do
    pipe_through [:browser]

    get "/login", LoginController, :login
    get "/sso", LoginController, :auth
  end

  scope "/", DenDashWeb do
    pipe_through [:browser]

    get "/logout", LoginController, :logout
    get "/", PageController, :index
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
