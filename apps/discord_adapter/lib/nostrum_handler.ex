defmodule Hedwig.Adapters.Discord.NostrumHandler do
  use Nostrum.Consumer
  alias Nostrum.Api

  require Logger

  defmodule State do
    defstruct parent: nil,
      myid: nil
  end

  def start_link(args) do
    {:ok, myself} = Api.get_current_user()
    {myid, _} = Integer.parse(myself["id"]);

    state = %State{
      parent: self(),
      myid: myid
    }

    GenStage.start_link(Nostrum.Consumer, %{mod: __MODULE__, state: state})
  end

  def handle_event({:MESSAGE_CREATE, {msg}, ws_state}, state) do
    channel = case Api.get_channel(msg.channel_id) do
                {:ok, channel} ->
                  %{id: msg.channel_id, title: "#" <> channel["name"]}
                {:error, err} ->
                  IO.inspect(err)
                  %{id: msg.channel_id, title: "unknown"}
              end

    if state.myid != msg.author.id do
      send(state.parent, {:message, channel, msg});
    end
    {:ok, state}
  end

  def handle_event(rawmsg, state) do
    {:ok, state}
  end
end
