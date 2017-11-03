defmodule CiryaBot.Robot.Console do
  use Hedwig.Robot, otp_app: :cirya_bot
  use CiryaBot.BotHelper

  def handle_connect(%{name: name} = state) do
    if :undefined == :global.whereis_name(name) do
      :yes = :global.register_name(name, self())
    end

    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    {:reconnect, 5000, state}
  end

  def handle_in(%Hedwig.Message{} = msg, state) do
    msg = %{msg|user: appendsvc(msg.user, "console")}
    GenServer.cast(CiryaBot.Router, {:message, msg})
    {:dispatch, msg, state}
  end

  def handle_in(_msg, state) do
    {:noreply, state}
  end
end
