defmodule Todo.System do
  use Supervisor

  # client side

  def start_link() do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # server side

  def init(_) do
    Supervisor.init(
      [
        Todo.ProcessRegistry,
        Todo.Database,
        Todo.Cache,
        Todo.Web
        # Todo.Metrics
      ],
      strategy: :one_for_one
    )
  end
end
