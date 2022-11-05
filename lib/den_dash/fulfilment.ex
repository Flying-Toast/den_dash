defmodule DenDash.Fulfilment do
  def accepting_orders?() do
    {:ok, now} = DateTime.utc_now()
                 |> DateTime.shift_zone("America/New_York")

    is_good_day = Date.day_of_week(now) in [5, 6]
    is_good_time = :gt == Time.compare(now, ~T[22:00:00])
               and :lt == Time.compare(now, ~T[23:59:59])

    is_good_time and is_good_day
  end
end
