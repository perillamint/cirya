defmodule CiryaBot.Router do
  use GenServer

  defmodule State do
    defstruct foo: nil
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
    {:noreply, state}
  end
end
