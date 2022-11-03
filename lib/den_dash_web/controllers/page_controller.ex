defmodule DenDashWeb.PageController do
  use DenDashWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def support(conn, _params) do
    render(conn, "support.html", title: "Support ⛑️")
  end
end
