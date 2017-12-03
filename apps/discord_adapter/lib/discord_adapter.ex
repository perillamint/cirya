defmodule Hedwig.Adapters.Discord do
  @moduledoc false
  use Hedwig.Adapter
  alias Nostrum.Api

  defmodule State do
    defstruct opts: nil,
      robot: nil
  end

  def init({robot, opts}) do
    Hedwig.Adapters.Discord.NostrumHandler.start_link([])
    {:ok, %State{opts: opts, robot: robot}}
  end

  def handle_cast({:send, msg}, state) do
    # No need for spawn_link. Message will be lost when there is network disruption.
    spawn(fn ->
      Api.create_message(msg.room.id, msg.text)
    end)
    {:noreply, state}
  end

  def handle_cast({:reply, msg = %Hedwig.Message{}}, state) do
    # No need for spawn_link. Message will be lost when there is network disruption.
    spawn(fn ->
      # TODO: Reply?
      Api.create_message(msg.room.id, msg.text)
    end)
    {:noreply, state}
  end

  def handle_info({:message, channel, raw_msg}, state) do
    user = %Hedwig.User{
      id: raw_msg.author.username,
      name: raw_msg.author.username <> "#" <> raw_msg.author.discriminator
    }

    msg = %Hedwig.Message{
      ref: raw_msg.id,
      room: channel,
      robot: state.robot,
      user: user,
      text: raw_msg.content,
      type: 'groupchat'
    }

    IO.inspect(msg)
    Hedwig.Robot.handle_in(state.robot, msg);
    {:noreply, state}
  end

  def handle_info({:command, cmd}, state) do
    {:noreply, state}
  end
end
