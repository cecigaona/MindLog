FROM hexpm/elixir:1.19.5-erlang-28.3.3-debian-bookworm-20260803-slim

ENV MIX_ENV=dev \
    LANG=C.UTF-8 \
    HEX_CACERTS_PATH=/etc/ssl/certs/ca-certificates.crt

RUN apt-get update \
    && apt-get install --no-install-recommends -y build-essential ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get && mix deps.compile

COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY assets ./assets
COPY test ./test

RUN mix compile && mix assets.setup && mix assets.build

EXPOSE 4000

CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix phx.server"]
