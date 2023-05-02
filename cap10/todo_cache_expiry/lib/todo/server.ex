defmodule Todo.Server do
  use GenServer, restart: :temporary

  # client process

  def start_link(list_name) do
    GenServer.start_link(
      Todo.Server,
      list_name,
      name: via_tuple(list_name)
    )
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  defp via_tuple(list_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, list_name})
  end

  # server process

  @expiry_idle_timeout :timer.seconds(10)

  @impl GenServer
  def init(list_name) do
    IO.puts("Starting to-do server for #{list_name}")

    {:ok,
     {
       list_name,
       Todo.Database.get(list_name) || Todo.List.new()
     }, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {list_name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(list_name, new_list)

    {:noreply, {list_name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {list_name, todo_list}) do
    {
      :reply,
      Todo.List.entries(todo_list, date),
      {list_name, todo_list},
      @expiry_idle_timeout
    }
  end

  @impl GenServer
  def handle_info(:timeout, {list_name, todo_list}) do
    IO.puts("Stopping to-do server for #{list_name}")

    {:stop, :normal, {list_name, todo_list}}
  end
end
