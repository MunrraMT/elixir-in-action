defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process/2" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "to-do operations" do
    {:ok, cache} = Todo.Cache.start()
    alice = Todo.Cache.server_process(cache, "alice")
    task_base = %{date: ~D[2018-12-19], title: "dentista"}
    Todo.Server.add_entry(alice, task_base)
    entries = Todo.Server.entries(alice, ~D[2018-12-19])

    assert [task_base] = entries
  end
end
