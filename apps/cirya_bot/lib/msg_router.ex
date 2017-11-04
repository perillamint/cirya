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
      src = RouteSrc.where(svc_name == svc) |> Amnesia.Selection.values
      case src do
        [] ->
          []
        [entry] ->
          entry |> RouteSrc.get_destinations()
      end
    end

    #Hedwig.Robot.send(CiryaBot.Robot.Telegram, msg)
    {:noreply, state}
  end
end
