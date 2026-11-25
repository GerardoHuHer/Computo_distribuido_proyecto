defmodule Observability.Trace do
  def setup(opts \\ []) do
    OpentelemetryBandit.setup()
    OpentelemetryPhoenix.setup(adapter: :bandit)

    if repo = opts[:repo], do: OpentelemetryEcto.setup(repo)

    :ok
  end
end