defmodule CiryaBot.Responders.LinkManager do
  @moduledoc """
  Chat link management command provider
  """

  use Amnesia
  use Hedwig.Responder
  require Exquisite

  alias CiryaBot.Mnesia.RoutingTable.Room, as: Room

  require Room

  @usage """
  hedwig showlink - Show chat link status
  """
  respond ~r/showlink$/i, msg do
    userid = msg.user.id
    {:ok, svcname} = userid |> String.split("@") |> Enum.fetch(-1)
    svc = String.to_atom(svcname)

    replymsg = Amnesia.transaction do
      src = Room.where(svc_name == svc and room == msg.room) |> Amnesia.Selection.values
      case src do
        [] ->
          "Room not registered."
        [entry] ->
          destinations = entry |> Room.get_destinations()
          |> Enum.reduce([], fn(routedst, acc) ->
            %Room{
              svc_name: target_svc,
              room: target_room,
              alias: target_room_alias
            } = routedst;

            svcname = to_string(target_svc)
            roomname = case target_room_alias do
                         nil ->
                           to_string(target_room)
                         x ->
                           to_string(target_room) <> "(" <> target_room_alias <> ")"
                       end

            acc ++ ["svc: " <> svcname <> " room:" <> roomname]
          end)
          |> Enum.reduce("", fn(entry, acc) ->
            acc <> entry <> "\n"
          end)

          "Room link status: \n" <> destinations
      end
    end

    reply msg, replymsg
  end

  @usage """
  hedwig startlink - Start link
  """
  respond ~r/startlink$/i, msg do
    reply msg, "Not ready yet"
  end

  @usage """
  hedwig killlink - Kill link
  """
  respond ~r/killlink$/i, msg do
    reply msg, "Not ready yet"
  end
end
