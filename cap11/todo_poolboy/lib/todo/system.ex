defmodule Todo.System do
  use Supervisor

  # client side

  def start_link() do
    Supervisor.start_link(__MODULE__, nil)
  end

  # server side

  def init(_) do
    Supervisor.init(
      [
        Todo.Metrics,
        Todo.ProcessRegistry,
        Todo.Database,
        Todo.Cache
      ],
      strategy: :one_for_one
    )
  end
end
