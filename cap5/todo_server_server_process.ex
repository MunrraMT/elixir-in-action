defmodule ServerProcess do
  # client process

  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} ->
        response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  # server process

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} =
          callback_module.handle_call(
            request,
            current_state
          )

        send(caller, {:response, response})

        loop(callback_module, new_state)

      {:cast, request} ->
        new_state =
          callback_module.handle_cast(
            request,
            current_state
          )

        loop(callback_module, new_state)
    end
  end
end

defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  # client process

  def start() do
    ServerProcess.start(TodoList)
  end

  # server process

  def init(), do: %TodoList{}

  def handle_cast({:create, %{} = entry}, %TodoList{} = state) do
    entry = Map.put(entry, :id, state.next_id)
    new_entries = Map.put(state.entries, state.next_id, entry)

    %TodoList{state | entries: new_entries, next_id: state.next_id + 1}
  end

  def handle_cast({:create, entries}, %TodoList{} = state) do
    entries
    |> Enum.reverse()
    |> Enum.reduce(state, fn entry, todo_list_accumulator ->
      handle_cast({:create, entry}, todo_list_accumulator)
    end)
  end

  def handle_call({:get, key}, %TodoList{} = state) do
    {Map.get(state.entries, key), state}
  end

  def handle_call({:get_all}, %TodoList{} = state) do
    {state.entries, state}
  end

  def handle_cast({:update, entry_id, updater_fun}, %TodoList{} = state) do
    case Map.fetch(state.entries, entry_id) do
      :error ->
        state

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(state.entries, new_entry.id, new_entry)
        %TodoList{state | entries: new_entries}
    end
  end

  def handle_cast({:delete, entry_id}, %TodoList{} = state) do
    new_entries =
      state.entries
      |> Map.delete(entry_id)

    %TodoList{state | entries: new_entries, next_id: state.next_id - 1}
  end
end

# pid = TodoList.start()

# ServerProcess.cast(pid, {:create, %{date: ~D[2023-08-29], title: "niver"}})

# ServerProcess.call(pid, {:get_all})

# ServerProcess.cast(pid, {:create, [%{date: ~D[1994-04-30], title: "niver Camila"}, %{date: ~D[2022-03-31], title: "niver Maria"}]})

# ServerProcess.cast(pid, {:update, 2, &Map.put(&1, :title, "Niver da minha filha, Maria")})

# ServerProcess.cast(pid, {:delete, 1})
