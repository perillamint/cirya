defmodule CiryaBot.Router do
  use GenServer
  use Amnesia
  require Exquisite

  alias CiryaBot.Mnesia.RoutingTable.Room, as: Room

  require Room

  defmodule State do
    defstruct foo: nil
  end

  defp get_route_target(targetname) do
    [route_map: table] = Application.get_env(:cirya_bot, CiryaBot.Router)
    table |> Keyword.fetch(targetname)
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, [args], [{:name, __MODULE__}])
  end

  def init([config]) do
    state = %State{
    }

    {:ok, state}
  end

  def handle_cast({:message, %Hedwig.Message{} = msg}, state) do
    userid = msg.user.id;
    {:ok, svcname} = userid |> String.split("@") |> Enum.fetch(-1)
    svc = String.to_atom(svcname)

    targets = Amnesia.transaction do
      src = Room.where(svc_name == svc and room_id == msg.room.id) |> Amnesia.Selection.values
      case src do
        [] ->
          []
        [entry] ->
          entry |> Room.get_destinations()
      end
    end

    roomname = Amnesia.transaction do
      src = Room.where(svc_name == svc and room_id == msg.room.id) |> Amnesia.Selection.values

      case src do
        [] ->
          to_string(msg.room.title) <> "(" <> svcname <> ")"
        [entry] ->
          case entry.alias do
            nil ->
              to_string(msg.room.title) <> "(" <> svcname <> ")"
            x ->
              x
          end
      end
    end

    targets |> Enum.each(fn(%Room{svc_name: target_svc, room: target_room}) ->
      {:ok, target} = get_route_target(target_svc)
      msg_new = %{msg|room: target_room, text: userid <> "#" <> roomname <> ": " <> msg.text}
      Hedwig.Robot.send(target, msg_new)
    end)

    {:noreply, state}
  end
end
