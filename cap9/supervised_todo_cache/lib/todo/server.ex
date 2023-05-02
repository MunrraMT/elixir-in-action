defmodule Todo.Server do
  use GenServer

  # client process

  def start_link(list_name) do
    IO.puts("Starting to-do server for #{list_name}!")
    GenServer.start_link(__MODULE__, list_name, name: via_tuple(list_name))
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  # server process

  @impl GenServer
  def init(list_name) do
    {:ok, {list_name, Todo.Database.get(list_name) || Todo.List.new()}}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {list_name, state}) do
    new_state = Todo.List.add_entry(state, new_entry)
    Todo.Database.store(list_name, new_state)
    {:noreply, {list_name, new_state}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {list_name, state}) do
    {
      :reply,
      Todo.List.entries(state, date),
      {list_name, state}
    }
  end
end
