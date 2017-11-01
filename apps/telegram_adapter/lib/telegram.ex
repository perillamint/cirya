defmodule Hedwig.Adapters.Telegram.TelegramServer do
  use GenServer

  @timeout 100
  @lptimeout 5000

  defmodule State do
    defstruct parent: nil,
      offset: nil
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, [self(), args], [{:name, __MODULE__}])
  end

  def init([parent, config]) do
    {:ok, updates} = Nadia.get_updates(offset: -1, limit: 1);

    offset = case updates do
               [] ->
                 0
               [lastmsg] ->
                 lastmsg.update_id + 1
             end

    {:ok, %State{parent: parent, offset: offset}, @timeout}
  end

  def handle_call(_, _, state) do
    {:stop, {:error, :unknownmsg}, state}
  end

  def handle_cast({:message, message}, state) do
    {:noreply, state}
  end

  def handle_info(timeout, state) do
    {:ok, updates} = Nadia.get_updates(offset: state.offset, timeout: @lptimeout)

   updates |> Enum.each(fn(update) ->
      send(state.parent, {:message, update.message})
    end)

    # Update state offset
    offset = case Enum.take(updates, -1) do
               [] ->
                 state.offset
               [lastmsg] ->
                 lastmsg.update_id + 1
             end

    state = %{state|offset: offset}
    {:noreply, state, @timeout}
  end
end
