defmodule DenDash.Fulfilment do
  alias DenDash.Settings

  def accepting_orders?() do
    Settings.get().open_now
  end
end
