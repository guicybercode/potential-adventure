FROM elixir:1.17-alpine AS builder

RUN apk add --no-cache build-base git rust cargo zig

WORKDIR /app

COPY mix.exs mix.lock ./
COPY apps/realtime_processor/mix.exs ./apps/realtime_processor/
COPY config ./config

RUN mix deps.get --only prod
RUN mix deps.compile

COPY . .

RUN mix compile
RUN mix release

FROM alpine:latest

RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

COPY --from=builder /app/_build/prod/rel/elixir_rust_zig ./

EXPOSE 4000

CMD ["./bin/elixir_rust_zig", "start"]

