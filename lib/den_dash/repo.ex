defmodule DenDash.Repo do
  use Ecto.Repo,
    otp_app: :den_dash,
    adapter: Ecto.Adapters.SQLite3
end
