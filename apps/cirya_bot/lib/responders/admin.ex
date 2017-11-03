defmodule CiryaBot.Responders.Admin do
  @moduledoc """
  Admin module
  """

  use Amnesia
  use Hedwig.Responder

  alias CiryaBot.Mnesia.ACL.User, as: ACLUser
  alias CiryaBot.Mnesia.ACL.Role, as: ACLRole

  @usage """
  flags - Show caller's permission flags
  """

  respond ~r/flags$/i, msg do
    flags = Amnesia.transaction do
      case ACLUser.read(msg.user.id) do
        nil ->
          []
        x ->
          IO.inspect(x)
          x |> ACLUser.get_flags()
      end
    end |> Enum.reduce("", fn(elem, acc) ->
      acc <> elem <> ", "
    end) |> String.slice(0 .. -3)

    reply msg, flags
  end
end
