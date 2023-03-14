defmodule MyModule.Protocols.TodoList do
  alias MyModule.Protocols.TodoList

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

defprotocol MyModule.Protocols.Describe do
  def call(struct)
end

defimpl MyModule.Protocols.Describe, for: MyModule.Protocols.TodoList do
  def call(%MyModule.Protocols.TodoList{} = todo_list) do
    todo_list_length = todo_list.entries |> Enum.to_list() |> length()
    "This is a Todo List, and have #{todo_list_length} entries."
  end
end
