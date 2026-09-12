defmodule Inventario.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      InventarioWeb.Telemetry,
      Inventario.Repo,
      {DNSCluster, query: Application.get_env(:inventario, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Inventario.PubSub},
      # Start a worker by calling: Inventario.Worker.start_link(arg)
      # {Inventario.Worker, arg},
      # Start to serve requests, typically the last entry
      InventarioWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Inventario.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InventarioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
