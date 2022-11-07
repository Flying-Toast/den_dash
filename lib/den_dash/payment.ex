defmodule DenDash.Payment do
  require Logger
  alias DenDash.Orders

  @tag_extractor ~r/!(\S+)!/

  def process_venmo_payment(note, amount) do
    case Regex.run(@tag_extractor, note, capture: :all_but_first) do
      [venmo_tag] ->
        matching_order = Orders.get_order_by_venmo_tag(venmo_tag)
        cond do
          amount != matching_order.price ->
            Logger.warn("Received venmo payment with wrong amount. Note: `#{note}`, Amount: `#{amount}`")

          matching_order == nil ->
            Logger.warn("Received venmo payment with invalid tag. Note: `#{note}`, Amount: `#{amount}`")

          true ->
            Logger.info("Order #{venmo_tag} paid!")
            Orders.mark_order_as_paid(matching_order)
        end

      _ ->
        Logger.warn("Couldn't extract tag from note: `#{note}`")
    end
  end
end
