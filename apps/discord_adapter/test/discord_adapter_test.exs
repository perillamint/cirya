defmodule Hedwig.Adapters.DiscordTest do
  use ExUnit.Case
  doctest Hedwig.Adapters.Discord

  test "greets the world" do
    assert Hedwig.Adapters.Discord.hello() == :world
  end
end
