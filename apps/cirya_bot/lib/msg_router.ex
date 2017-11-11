defmodule CiryaBot.Router do
  use GenServer
  use Amnesia
  require Exquisite

  alias CiryaBot.Mnesia.RoutingTable.Source, as: RouteSrc
  alias CiryaBot.Mnesia.RoutingTable.Destination, as: RouteDst

  require RouteSrc

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
    IO.inspect(msg)
    userid = msg.user.id;
    {:ok, svcname} = userid |> String.split("@") |> Enum.fetch(-1)

    svc = String.to_atom(svcname)

    targets = Amnesia.transaction do
      src = RouteSrc.where(svc_name == svc and room == msg.room) |> Amnesia.Selection.values
      case src do
        [] ->
          []
        [entry] ->
          entry |> RouteSrc.get_destinations()
      end
    end

    targets |> Enum.each(fn(%RouteDst{svc_name: target_svc, room: target_room}) ->
      target = get_route_target(target_svc)
      msg_new = %{msg|room: target_room}

      # TODO: Append original room to text msg
      Hedwig.Robot.send(target, msg_new)
    end)

    {:noreply, state}
  end
end
