defmodule DenDash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @mix_env_prod Mix.env() == :prod

  @impl true
  def start(_type, _args) do
    if @mix_env_prod do
      DenDash.Release.migrate()
    end

    children = [
      # Start the Ecto repository
      DenDash.Repo,
      # Start the Telemetry supervisor
      DenDashWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: DenDash.PubSub},
      # Start the Endpoint (http/https)
      DenDashWeb.Endpoint
      # Start a worker by calling: DenDash.Worker.start_link(arg)
      # {DenDash.Worker, arg}
    ] ++ List.wrap(if @mix_env_prod, do: DenDash.PaymentWatcher)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DenDash.Supervisor]
    res = Supervisor.start_link(children, opts)
    DenDash.Settings.prefill_defaults()
    res
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DenDashWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
