defmodule CiryaBot.Robot.Telegram do
  use Hedwig.Robot, otp_app: :cirya_bot

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
              %{msg|user: %{msg.user| id: msg.user.id <> "@telegram"}}
            id ->
              %{msg|user: %Hedwig.User{id: msg.user <> "@telegram", name: msg.user}}
          end
    IO.inspect(msg)
    {:dispatch, msg, state}
  end

  def handle_in(_msg, state) do
    {:noreply, state}
  end
end
