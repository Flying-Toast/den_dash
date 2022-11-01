defmodule DenDashWeb.LoginController do
  use DenDashWeb, :controller

  def login(conn, _params) do
    redirect(conn, external: "https://login.case.edu/cas/login?service=#{Routes.login_url(conn, :auth)}")
  end

  def auth(conn, %{"ticket" => ticket}) do
    %{status_code: 200, body: body} = HTTPoison.get!("https://login.case.edu/cas/validate?ticket=#{ticket}&service=#{Routes.login_url(conn, :auth)}")

    case String.split(body, "\n", trim: true) do
      ["no"] ->
        render(conn, "failed.html")

      ["yes", caseid] ->
        conn = put_session(conn, "caseid", caseid)
        redirect(conn, to: Routes.page_path(conn, :index))
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session("caseid")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
