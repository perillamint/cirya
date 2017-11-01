defmodule CiryaBotTest do
  use ExUnit.Case
  doctest CiryaBot

  test "greets the world" do
    assert CiryaBot.hello() == :world
  end
end
