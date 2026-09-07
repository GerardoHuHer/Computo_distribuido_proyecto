defmodule Clima.Repo do
  use Ecto.Repo,
    otp_app: :clima,
    adapter: Ecto.Adapters.Postgres
end
