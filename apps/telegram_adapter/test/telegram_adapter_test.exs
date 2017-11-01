defmodule Hedwig.Adapters.TelegramTest do
  use ExUnit.Case
  doctest Hedwig.Adapters.Telegram

  test "greets the world" do
    assert Hedwig.Adapters.Telegram.hello() == :world
  end
end
