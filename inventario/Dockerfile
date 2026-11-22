FROM elixir:1.20.2-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates build-essential git \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV MIX_ENV=prod
RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
COPY config/config.exs config/prod.exs config/
RUN mix deps.compile

COPY lib lib
COPY priv priv
COPY config/runtime.exs config/
COPY rel rel
RUN mix compile && mix release

FROM debian:trixie-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      libstdc++6 openssl libncurses6 locales ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 PHX_SERVER=true
WORKDIR /app
COPY --from=build /app/_build/prod/rel/inventario ./
EXPOSE 4000
CMD ["sh", "-c", "/app/bin/inventario eval 'Inventario.Release.migrate' && exec /app/bin/inventario start"]
