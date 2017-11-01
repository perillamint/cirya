defmodule Hedwig.Adapters.Telegram do
  @moduledoc false
  use Hedwig.Adapter

  defmodule State do
    defstruct conn: nil,
      opts: nil,
      robot: nil
  end

  def init({robot, opts}) do
    {:ok, %State{opts: opts, robot: robot}}
  end

  def handle_cast({:send, %{text: text} = msg}, state) do
  end

  def handle_info({:message, raw_msg}, state) do
    msgtype = 'groupchat' # TODO: Use raw_msg to get this info
    user = raw_msg.from.username # TODO: Fallback to first_name
    text = raw_msg.text # TODO: Append group title to text

    msg = %Hedwig.Message{
      ref: raw_msg.message_id,
      room: raw_msg.chat.id,
      text: text,
      type: msgtype
    }

    Hedwig.Robot.handle_message(state.robot, msg);
    {:noreply, state}
  end

  def handle_info({:command, cmd}, state) do
    {:noreply, state}
  end
end
