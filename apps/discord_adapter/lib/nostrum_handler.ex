defmodule Hedwig.Adapters.Discord.NostrumHandler do
  use Nostrum.Consumer
  alias Nostrum.Api

  require Logger

  defmodule State do
    defstruct parent: nil
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, [self(), args], [{:name, __MODULE__}])
  end

  def init([parent, config]) do
    Consumer.start_link(__MODULE__)
    {:ok, %State{parent: parent}}
  end

  def handle_event({:MESSAGE_CREATE, {msg}, ws_state}, state) do
    channel = case Api.get_channel(msg.channel_id) do
                {:ok, channel} ->
                  "#" <> channel.name
                {:error, msg} ->
                  "unknown"
              end

    IO.inspect(channel)
    #send(state.parent, {:message, msg});
    IO.inspect(msg)
    {:ok, state}
  end

  def handle_event(rawmsg, state) do
    {:ok, state}
  end
end
