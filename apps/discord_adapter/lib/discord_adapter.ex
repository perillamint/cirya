defmodule Hedwig.Adapters.Discord do
  @moduledoc false
  use Hedwig.Adapter

  defmodule State do
    defstruct opts: nil,
      robot: nil
  end

  def init({robot, opts}) do
    {:ok, %State{opts: opts, robot: robot}}
  end

  def handle_cast({:send, msg}, state) do
    # TODO: Impl this
    {:noreply, state}
  end

  def handle_cast({:reply, msg = %Hedwig.Message{}}, state) do
    # TODO: Impl this
    {:noreply, state}
  end

  def handle_info({:message, raw_msg}, state) do
    # TODO: Impl this
    {:noreply, state}
  end

  def handle_info({:command, cmd}, state) do
    {:noreply, state}
  end
end
