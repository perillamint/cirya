defmodule CiryaBot.BotHelper do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      def child_spec(opts) do
        %{
          id: __MODULE__,
          restart: :permanent,
          shutdown: 5000,
          start: {__MODULE__, :start_link_hook, [__MODULE__, opts]},
          type: :worker
        }
      end

      def start_link_hook(robot, opts) do
        GenServer.start_link(robot, {robot, opts}, [{:name, __MODULE__}])
      end

      def appendsvc(user, svc) do
        case user do
          userobj = %Hedwig.User{} ->
            %{userobj| id: userobj.id <> "@" <> svc}
          id ->
            %Hedwig.User{id: id <> "@" <> svc, name: user}
        end
      end
    end
  end
end
