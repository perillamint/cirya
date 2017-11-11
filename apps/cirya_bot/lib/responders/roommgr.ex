defmodule CiryaBot.Responders.RoomManager do
  @moduledoc """
  Room management command provider
  """

  use Amnesia
  use Hedwig.Responder
  require Exquisite

  alias CiryaBot.Mnesia.RoutingTable.Room, as: Room

  require Room

  @usage """
  hedwig setalias <alias> - Set room alias
  """
  respond ~r/setalias (?<alias>[^ ]*)/, msg do
    userid = msg.user.id
    {:ok, svcname} = userid |> String.split("@") |> Enum.fetch(-1)
    svc = String.to_atom(svcname)

    replymsg = Amnesia.transaction do
      src = Room.where(svc_name == svc and room == msg.room) |> Amnesia.Selection.values
      case src do
        [] ->
          "No room found on DB. Cannot set alias."
        [entry] ->
          %{entry|alias: msg.matches["alias"]} |> Room.write
          "Room found on DB. Aliased as: " <> msg.matches["alias"]
      end
    end

    reply msg, replymsg
  end

  @usage """
  hedwig createroom - Create room on DB
  """
  respond ~r/createroom$/i, msg do
    userid = msg.user.id
    {:ok, svcname} = userid |> String.split("@") |> Enum.fetch(-1)
    svc = String.to_atom(svcname)

    replymsg = Amnesia.transaction do
      src = Room.where(svc_name == svc and room == msg.room) |> Amnesia.Selection.values

      case src do
        [] ->
          %Room{
            svc_name: svc,
            room: msg.room,
            alias: nil,
            destinations: []
          } |> Room.write()
          "Room created."
        [entry] ->
          "Room already exists!"
      end
    end

    reply msg, replymsg
  end
end
