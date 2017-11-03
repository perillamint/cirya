defmodule CiryaBot.Robot.Console do
  use Hedwig.Robot, otp_app: :cirya_bot
  use CiryaBot.RegisterBot

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
    msg = case msg.user do
            user = %Hedwig.User{} ->
              %{msg|user: %{msg.user| id: user.id <> "@telegram"}}
            id ->
              %{msg|user: %Hedwig.User{id: id <> "@telegram", name: msg.user}}
          end

    GenServer.cast(CiryaBot.Router, {:message, msg})
    {:dispatch, msg, state}
  end

  def handle_in(_msg, state) do
    {:noreply, state}
  end
end
