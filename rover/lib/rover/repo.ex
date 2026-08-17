defmodule Rover.Repo do
  use Ecto.Repo,
    otp_app: :rover,
    adapter: Ecto.Adapters.Postgres
end
