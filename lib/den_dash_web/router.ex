defmodule DenDashWeb.Router do
  use DenDashWeb, :router
  alias DenDashWeb.Router.Helpers, as: Routes
  alias DenDash.Accounts

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DenDashWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  def require_login(conn, _opts) do
    caseid = Plug.Conn.get_session(conn, :caseid)
    if caseid == nil do
      conn
      |> redirect(to: Routes.login_path(conn, :login))
      |> halt()
    else
      my_user = Accounts.get_or_create_user(caseid)
      assign(conn, :me, my_user)
    end
  end

  scope "/", DenDashWeb do
    pipe_through [:browser]

    get "/login", LoginController, :login
    get "/sso", LoginController, :auth
  end

  scope "/", DenDashWeb do
    pipe_through [:browser, :require_login]

    get "/logout", LoginController, :logout
    get "/", PageController, :index

    scope "/orders" do
      get "/new", OrderController, :order_form
      post "/new", OrderController, :create

      get "/:id", OrderController, :show
    end
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
