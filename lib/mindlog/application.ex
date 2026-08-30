defmodule Mindlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MindlogWeb.Telemetry,
      Mindlog.Repo,
      {DNSCluster, query: Application.get_env(:mindlog, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Mindlog.PubSub},
      # Start a worker by calling: Mindlog.Worker.start_link(arg)
      # {Mindlog.Worker, arg},
      # Start to serve requests, typically the last entry
      MindlogWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mindlog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MindlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
