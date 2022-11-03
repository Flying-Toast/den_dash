defmodule DenDashWeb.PageController do
  use DenDashWeb, :controller

  def index(conn, _params) do
    if conn.assigns[:me] do
      render(conn, "_logged_in_index.html")
    else
      render(conn, "_logged_out_index.html")
    end
  end

  def support(conn, _params) do
    render(conn, "support.html", title: "Support ⛑️")
  end
end
