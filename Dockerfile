FROM elixir:1.6-alpine

RUN apk add --no-cache git bash

RUN mix local.hex --force
RUN mix local.rebar --force

ADD . /opt/cirya

WORKDIR /opt/cirya
RUN mix deps.get
RUN mix release

CMD /opt/cirya/entrypoint.sh
