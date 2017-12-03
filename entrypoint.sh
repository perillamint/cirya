#!/bin/bash

APPNAME=cirya
DBDIR=Mnesia.$APPNAME@$(hostname -f)

if [ ! -d $DBDIR ]; then
    elixir --sname cirya -S mix amnesia.create -d CiryaBot.Mnesia.RoutingTable
    elixir --sname cirya -S mix amnesia.create -d CiryaBot.Mnesia.ACL
fi

elixir --sname cirya --no-halt -S mix
#./_build/dev/rel/cirya/bin/cirya foreground
