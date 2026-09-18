FROM elixir:1.20.2-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./

RUN mix deps.get

COPY . .

EXPOSE 4001

CMD ["sh", "-c", "NODE_IP=$(hostname -i) && mix ecto.create --quiet; mix ecto.migrate && exec elixir --name backend_rover@${NODE_IP} --cookie ${RELEASE_COOKIE} -S mix phx.server"]
