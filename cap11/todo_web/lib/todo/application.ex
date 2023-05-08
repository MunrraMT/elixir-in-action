defmodule Todo.Application do
  use Application

  def start(_type, _args) do
    IO.puts("starting application!")

    Todo.System.start_link()
  end
end
