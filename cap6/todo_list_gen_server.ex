defmodule TodoServer do
  use GenServer

  # client process

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def create(entry) do
    GenServer.cast(__MODULE__, {:create, entry})
  end

  def read(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

  def read() do
    GenServer.call(__MODULE__, {:get_all})
  end

  def update(id, updater_fun) do
    GenServer.cast(__MODULE__, {:update, id, updater_fun})
  end

  def delete(id) do
    GenServer.cast(__MODULE__, {:delete, id})
  end

  # server process

  @impl GenServer
  def init(_), do: {:ok, TodoList.new()}

  @impl GenServer
  def handle_call({:entries, date}, _, todo_list) do
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    entries
    |> Enum.reverse()
    |> Enum.reduce(%TodoList{}, fn entry, todo_list_accumulator ->
      add_entry(todo_list_accumulator, entry)
    end)
  end

  def add_entry(%TodoList{} = todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)

    %TodoList{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def entries(%TodoList{} = todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(%TodoList{} = todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(%TodoList{} = todo_list, entry_id) do
    todo_list.entries
    |> Map.delete(entry_id)
  end
end

# TodoList.start()
# {:ok, #PID<0.115.0>}

# TodoList.create(%{date: ~D[2023-08-29], title: "niver"})
