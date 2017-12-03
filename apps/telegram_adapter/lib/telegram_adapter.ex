defmodule Hedwig.Adapters.Telegram do
  @moduledoc false
  use Hedwig.Adapter
  require Logger

  defmodule State do
    defstruct conn: nil,
      opts: nil,
      robot: nil
  end

  def init({robot, opts}) do
    Hedwig.Adapters.Telegram.TelegramServer.start_link([])
    {:ok, %State{opts: opts, robot: robot}}
  end

  def handle_cast({:send, msg}, state) do
    # Spawn child to handle message dispatch
    # No need for spawn_link. Message will be lost when there is network disruption.
    spawn(fn ->
      Nadia.send_message(msg.room.id, msg.text)
    end)
    {:noreply, state}
  end

  def handle_cast({:reply, msg = %Hedwig.Message{}}, state) do
    # Spawn child to handle message dispatch
    # No need for spawn_link. Message will be lost when there is network disruption.
    spawn(fn ->
      Nadia.send_message(msg.room.id, msg.text, reply_to_message_id: msg.ref)
    end)
    {:noreply, state}
  end

  def handle_info({:message, nil}, state) do
    Logger.warn('Telegram message is nil. Network failure?')
    {:noreply, state}
  end

  def handle_info({:message, raw_msg}, state) do
    msgtype = 'groupchat' # TODO: Use raw_msg to get this info
    user = %Hedwig.User{
      id: raw_msg.from.username,
      name: case raw_msg.from.last_name do
              nil ->
                raw_msg.from.first_name
              last_name ->
                raw_msg.from.first_name <> " " <> raw_msg.from.last_name
            end
    }

    user = case user.id do
             nil ->
               %{user|id: user.name}
             _ ->
               user
           end

    text = case raw_msg.text do
             nil ->
               "[WIP: Media]"
             x ->
               x
           end

    msg = %Hedwig.Message{
      ref: raw_msg.message_id,
      room: %{id: raw_msg.chat.id, title: raw_msg.chat.title},
      robot: state.robot,
      user: user,
      text: text,
      type: msgtype
    }

    Hedwig.Robot.handle_in(state.robot, msg);
    {:noreply, state}
  end

  def handle_info({:command, cmd}, state) do
    {:noreply, state}
  end
end
