defmodule DenDash.Fulfilment.DeliveryNotifier do
  import Swoosh.Email
  alias DenDash.{Repo, Mailer, Accounts}

  def deliver_order_delivered(order) do
    order = Repo.preload(order, :user)

    mail = new()
           |> to({order.grubhub_name, Accounts.user_email(order.user)})
           |> from({"DenDash", "dendashcwru@outlook.com"})
           |> subject("Order ##{order.number} Was Delivered")
           |> text_body("Hi #{order.grubhub_name}!\nYour DenDash order has been delivered and is availible for pickup in Carlton Commons.\n")

    spawn(fn -> Mailer.deliver(mail) end)
  end

  def deliver_order_picked_up(order) do
    order = Repo.preload(order, :user)

    mail = new()
           |> to({order.grubhub_name, Accounts.user_email(order.user)})
           |> from({"DenDash", "dendashcwru@outlook.com"})
           |> subject("Order ##{order.number} is On The Way")
           |> text_body("Hi #{order.grubhub_name}!\nYour DenDash order has been picked up and is now on the way.\n")

    spawn(fn -> Mailer.deliver(mail) end)
  end
end
