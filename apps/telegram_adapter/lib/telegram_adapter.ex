defmodule Hedwig.Adapters.Telegram do
  @moduledoc false
  use Hedwig.Adapter

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
    Nadia.send_message(msg.room, msg.text)
    {:noreply, state}
  end

  def handle_cast({:reply, msg = %Hedwig.Message{}}, state) do
    Nadia.send_message(msg.room, msg.text, reply_to_message_id: msg.ref)
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

    text = raw_msg.text # TODO: Append group title to text

    msg = %Hedwig.Message{
      ref: raw_msg.message_id,
      room: raw_msg.chat.id,
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
