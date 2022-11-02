defmodule DenDash.PaymentWatcher do
  use GenServer
  alias Mailroom.IMAP

  @mail_check_interval_secs 5

  def start_link(_opts) do
    email = Application.fetch_env!(:den_dash, :notifications_email)
    secret = Application.fetch_env!(:den_dash, :notifications_email_password)
    {:ok, pid} = IMAP.connect("mail.gandi.net", email, secret, ssl: true)
    IMAP.select(pid, "Inbox")

    GenServer.start_link(__MODULE__, %{mailroom_pid: pid})
  end

  def terminate(_reason, state) do
    IMAP.close(state.mailroom_pid)
  end

  def handle_info(:check_mail, state) do
    {:ok, unseen_ids} = IMAP.search(state.mailroom_pid, "UNSEEN")

    for unseen_id <- unseen_ids do
      {:ok, [{_id, mail}]} = IMAP.fetch(state.mailroom_pid, unseen_id, [:envelope, "BODY[2]"])

      if List.first(mail.envelope.sender).email == "venmo@venmo.com" and Regex.match?(~r/ paid you \$/, mail.envelope.subject) do
        html = Regex.replace(~r/=(..)/, mail["BODY[2]"], fn _, x ->
          {n, _} = Integer.parse(x, 16)
          n
        end)
        |> Floki.parse_document!()

        [{"p", [], [venmo_note]}] = Floki.find(html, "table td div p")
        [{"span", _attrs, [raw_transfer_amount]}] = Floki.find(html, ~s(td span[style]))

        {venmo_amount, _} = raw_transfer_amount
                            |> String.trim()
                            |> String.trim_leading("+ $")
                            |> Float.parse()

        DenDash.Payment.process_venmo_payment(venmo_note, venmo_amount)
      end

      IMAP.add_flags(state.mailroom_pid, unseen_id, ["\\Seen"])
    end

    schedule_check_mail()
    {:noreply, state}
  end

  def init(state) do
    schedule_check_mail()
    {:ok, state}
  end

  defp schedule_check_mail() do
    Process.send_after(self(), :check_mail, 1000 * @mail_check_interval_secs)
  end
end
