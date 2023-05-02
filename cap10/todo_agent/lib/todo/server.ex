defmodule Todo.Server do
  use Agent, restart: :temporary

  # client process

  def start_link(list_name) do
    Agent.start_link(
      fn ->
        IO.puts("Starting to-do agent for #{list_name}!")
        {list_name, Todo.Database.get(list_name) || Todo.List.new()}
      end,
      name: via_tuple(list_name)
    )
  end

  def add_entry(todo_server, new_entry) do
    Agent.cast(todo_server, fn {list_name, todo_list} ->
      new_state = Todo.List.add_entry(todo_list, new_entry)
      Todo.Database.store(list_name, new_state)
      {list_name, new_state}
    end)
  end

  def entries(todo_server, date) do
    Agent.get(todo_server, fn {_name, todo_list} ->
      Todo.List.entries(todo_list, date)
    end)
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
