FROM elixir:1.5-alpine

RUN apk add --no-cache git

ADD . /opt/cirya

WORKDIR /opt/cirya
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix release

# TODO: RUN ADD
