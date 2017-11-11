defmodule CiryaBot.PairKey do
  use GenServer

  @ttl 300
  @timeout 10000

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

  def handle_call({:getkey, room}, state) do
    # TODO: Run RNG and write it to ETS
    key = "superduperkey"
    ts = :os.system_time(:seconds)
    :ets.insert(state.table, {key, room, ts})

    {:reply, key, state}
  end

  def handle_call({:getpair, key}, state) do
    room = case :ets.lookup(state.table, key) do
             [] ->
               nil
             [{_, room, _}] ->
               room
           end

    {:reply, room, state}
  end

  def handle_info(:timeout, state) do
    expire_before = :os.system_time(:seconds) - @ttl
    ms = :ets.fun2ms(fn {key, room, ts} when ts < expire_before -> key end)

    :ets.select(state.table, ms) |> Enum.each(fn (key) ->
      :ets.delete(state.table, key)
    end)
    {:noreply, state, @timeout}
  end
end
