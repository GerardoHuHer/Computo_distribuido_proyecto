defmodule Middleware.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Cluster.Supervisor, [topologies, [name: Middleware.ClusterSupervisor]]},
      MiddlewareWeb.Telemetry,
      Middleware.Repo,
      {DNSCluster, query: Application.get_env(:middleware, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Middleware.PubSub},
      # Start a worker by calling: Middleware.Worker.start_link(arg)
      # {Middleware.Worker, arg},
      # Start to serve requests, typically the last entry
      MiddlewareWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Middleware.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MiddlewareWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
