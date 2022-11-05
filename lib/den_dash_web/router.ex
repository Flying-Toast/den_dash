defmodule DenDashWeb.Router do
  use DenDashWeb, :router
  alias DenDashWeb.Router.Helpers, as: Routes
  alias DenDash.{Accounts, Fulfilment}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DenDashWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :me_assign
  end

  def me_assign(conn, _opts) do
    caseid = Plug.Conn.get_session(conn, :caseid)
    if caseid != nil do
      my_user = Accounts.get_or_create_user(caseid)
      assign(conn, :me, my_user)
    else
      conn
    end
  end

  def require_login(conn, _opts) do
    if Plug.Conn.get_session(conn, :caseid) == nil do
      conn
      |> redirect(to: Routes.login_path(conn, :login))
      |> halt()
    else
      conn
    end
  end

  def employees_only(conn, _opts) do
    if Accounts.employee?(conn.assigns.me) do
      conn
    else
      conn
      |> put_status(404)
      |> put_root_layout(false)
      |> put_view(DenDashWeb.ErrorView)
      |> render("404.html")
      |> halt()
    end
  end

  def must_be_open(conn, _opts) do
    if Fulfilment.accepting_orders?() do
      conn
    else
      conn
      |> render(DenDashWeb.FulfilmentView, "closed.html", title: "We're Closed 😢", layout: {DenDashWeb.LayoutView, :app})
      |> halt()
    end
  end

  scope "/", DenDashWeb do
    pipe_through [:browser]

    get "/", PageController, :index
    get "/login", LoginController, :login
    get "/sso", LoginController, :auth
  end

  scope "/", DenDashWeb do
    pipe_through [:browser, :require_login]

    get "/logout", LoginController, :logout
    # Support page requires login because it exposes my email
    get "/support", PageController, :support

    scope "/orders" do
      scope "/" do
        pipe_through [:must_be_open]

        get "/new", OrderController, :order_form
        post "/new", OrderController, :create
        get "/:id/pay", OrderController, :pay
      end

      get "/", OrderController, :list
      post "/:id/cancel", OrderController, :cancel
      get "/:id", OrderController, :show
    end
  end

  scope "/fulfilment", DenDashWeb do
    pipe_through [:browser, :require_login, :employees_only]

    get "/", FulfilmentController, :index
    post "/pickup", FulfilmentController, :picked_up
    post "/deliver", FulfilmentController, :delivered
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
