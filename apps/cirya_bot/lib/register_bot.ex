defmodule CiryaBot.RegisterBot do
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
        GenServer.start_link(__MODULE__, {robot, opts}, [{:name, __MODULE__}])
      end
    end
  end
end
