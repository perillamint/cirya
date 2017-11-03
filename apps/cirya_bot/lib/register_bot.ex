defmodule CiryaBot.RegisterBot do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      def child_spec(opts) do
        %{
          id: __MODULE__,
          restart: :permanent,
          shutdown: 5000,
          start: {__MODULE__, :start_link_hook, [opts]},
          type: :worker
        }
      end

      def start_link_hook(opts) do
        res = start_link(opts)
        {:ok, pid} = res
        Process.register(pid, __MODULE__)
        res
      end
    end
  end
end
