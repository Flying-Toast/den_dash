defmodule DenDashWeb.PageController do
  use DenDashWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
