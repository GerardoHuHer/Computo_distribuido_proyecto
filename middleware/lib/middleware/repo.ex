defmodule Middleware.Repo do
  use Ecto.Repo,
    otp_app: :middleware,
    adapter: Ecto.Adapters.Postgres
end
