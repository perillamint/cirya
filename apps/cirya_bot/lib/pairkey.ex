defmodule CiryaBot.PairKey do
  use GenServer

  @ttl 300
  @timeout 10000
  @bits 64

  defmodule State do
    defstruct table: nil
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, [args], [{:name, __MODULE__}])
  end

  def init([config]) do
    state = %State{
      table: :ets.new(:pairkey, [:set, :private, :named_table])
    }

    {:ok, state, @timeout}
  end

  def handle_call({:getkey, room}, _from, state) do
    # TODO: Run RNG and write it to ETS
    key = EntropyString.random_string(@bits)
    ts = :os.system_time(:seconds)
    :ets.insert(state.table, {key, room, ts})

    {:reply, key, state, @timeout}
  end

  def handle_call({:getpair, key}, _from, state) do
    room = case :ets.lookup(state.table, key) do
             [] ->
               nil
             [{_, room, _}] ->
               :ets.delete(state.table, key)
               room
           end

    {:reply, room, state, @timeout}
  end

  def handle_info(:timeout, state) do
    # TODO: Find way to run this more periodically
    expire_before = :os.system_time(:seconds) - @ttl
    ms = [{{:"$1", :_, :"$2"}, [{:<, :"$2", {:const, expire_before}}], [:"$1"]}]

    :ets.select(state.table, ms) |> Enum.each(fn (key) ->
      :ets.delete(state.table, key)
    end)
    {:noreply, state, @timeout}
  end
end
