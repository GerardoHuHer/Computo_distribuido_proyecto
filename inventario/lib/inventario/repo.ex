defmodule Inventario.Repo do
  use Ecto.Repo,
    otp_app: :inventario,
    adapter: Ecto.Adapters.Postgres
end
