defmodule MyModule.TodoList do
  alias MyModule.TodoList

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

todo_list = MyModule.TodoList.new()
IO.inspect(todo_list, charlists: false)

todo_list =
  MyModule.TodoList.add_entry(todo_list, %{
    date: ~D[2023-03-13],
    title: "learn elixir",
    active: true
  })

IO.inspect(todo_list, charlists: false)

todo_list =
  MyModule.TodoList.add_entry(todo_list, %{
    date: ~D[2023-03-12],
    title: "read elixir in action",
    active: false
  })

IO.inspect(todo_list, charlists: false)

todo_list =
  MyModule.TodoList.add_entry(todo_list, %{
    date: ~D[2023-03-12],
    title: "Accumulator",
    active: false
  })

IO.inspect(todo_list, charlists: false)

IO.inspect(MyModule.TodoList.entries(todo_list, ~D[2023-03-12]), charlists: false)

IO.inspect(MyModule.TodoList.entries(todo_list, ~D[2023-03-13]), charlists: false)

todo_list =
  MyModule.TodoList.update_entry(
    todo_list,
    1,
    &Map.put(&1, :title, "UPDATED!")
  )

IO.inspect(todo_list, charlists: false)

todo_list = MyModule.TodoList.delete_entry(todo_list, 1)

IO.inspect(todo_list, charlists: false)

todo_list2 =
  MyModule.TodoList.new([
    %{date: ~D[2023-12-19], title: "Dentist"},
    %{date: ~D[2023-12-20], title: "Shopping"},
    %{date: ~D[2023-12-19], title: "Movies"}
  ])

IO.inspect(["todo list2", todo_list2], charlists: false)
