defmodule MyModule.TodoList do
  def new, do: MyModule.MultiDict.new()

  def add_entry(todo_list, %{date: date} = entry) do
    entryWithoutDate =
      entry
      |> Map.delete(:date)

    todo_list
    |> MyModule.MultiDict.add(date, entryWithoutDate)
  end

  def entries(todo_list, %{date: date}) do
    todo_list
    |> MyModule.MultiDict.get(date)
  end
end

defmodule MyModule.MultiDict do
  def new, do: %{}

  def add(dict, key, value) do
    dict
    |> Map.update(key, [value], &[value | &1])
  end

  def get(dict, key) do
    dict
    |> Map.get(key, [])
  end
end

todo_list = MyModule.TodoList.new()
IO.inspect(todo_list, charlists: false)

todo_list =
  MyModule.TodoList.add_entry(todo_list, %{
    date: ~D[2023-03-13],
    title: "learn elixir",
    isChecked: false
  })

IO.inspect(todo_list, charlists: false)

todo_list =
  MyModule.TodoList.add_entry(todo_list, %{
    date: ~D[2023-03-13],
    title: "read elixir in action",
    active: false
  })

IO.inspect(todo_list, charlists: false)

IO.inspect(MyModule.TodoList.entries(todo_list, %{date: ~D[2023-03-12]}), charlists: false)

IO.inspect(MyModule.TodoList.entries(todo_list, %{date: ~D[2023-03-13]}), charlists: false)
