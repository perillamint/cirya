defmodule Hedwig.Adapters.Telegram do
  @moduledoc false
  use Hedwig.Adapter

  defmodule State do
    defstruct conn: nil
  end

  def init({robot, opts}) do
    {:ok, %State{}}
  end
end
