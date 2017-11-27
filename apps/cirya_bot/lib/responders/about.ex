defmodule CiryaBot.Responders.About do
  @moduledoc """
  About module
  """

  use Hedwig.Responder

  @usage """
  hedwig info - Print information about Cirya bot
  """

  respond ~r/info$/i, msg do
    reply msg, """
    Cirya, The Chat Proxy Bot.

    Licensed under Affero GPL v3.

    https://github.com/perillamint/cirya
    """
  end
end
