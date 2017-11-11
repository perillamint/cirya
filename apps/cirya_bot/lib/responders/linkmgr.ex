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
              id: room_id,
              svc_name: target_svc,
              room: target_room,
              alias: target_room_alias
            } = routedst;

            svcname = to_string(target_svc)
            roomname = case target_room_alias do
                         nil ->
                           to_string(target_room)
                         x ->
                           to_string(target_room) <> "(" <> x <> ")"
                       end

            acc ++ ["id: " <> to_string(room_id) <> " svc: " <> svcname <> " room:" <> roomname]
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
  respond ~r/startlink (?<room_id>[0-9]*)/, msg do
    reply msg, "Not ready yet"
  end

  @usage """
  hedwig killlink - Kill link
  """
  respond ~r/killlink (?<room_id>[0-9]*)/i, msg do
    userid = msg.user.id
    {:ok, svcname} = userid |> String.split("@") |> Enum.fetch(-1)
    svc = String.to_atom(svcname)
    {room_id, _} = Integer.parse(msg.matches["room_id"])

    replymsg = Amnesia.transaction do
      src = Room.where(svc_name == svc and room == msg.room) |> Amnesia.Selection.values

      case src do
        [] ->
          "No room found on DB."
        [entry] ->
          %{entry|destinations: entry.destinations |> List.delete(room_id)}
          |> Room.write()

          "Link removed."
      end
    end

    reply msg, replymsg
  end
end
