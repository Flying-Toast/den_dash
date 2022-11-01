defmodule DenDash.Payment do
  def recent_payments() do
    now = DateTime.utc_now()
    start_date = now
                 |> DateTime.add(-3, :day)
                 |> Calendar.strftime("%Y-%m-%d")

    end_date = now
                 |> DateTime.add(3, :day)
                 |> Calendar.strftime("%Y-%m-%d")

    url = "https://api.venmo.com/v1/transaction-history?start_date=#{start_date}&end_date=#{end_date}"
    api_key = Application.fetch_env!(:den_dash, :venmo_api_key)

    HTTPoison.get!(url, [{"Cookie", "api_access_token=#{api_key}"}])
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
