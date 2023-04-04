try_helper = fn fun ->
  try do
    fun.()
    IO.puts("No error.")
  catch
    type, value ->
      IO.puts("Error\n  #{inspect(type)}\n  #{inspect(value)}")
  end
end

try_helper.(fn -> raise("Something went wrong") end)

# Processos independentes

spawn(fn ->
  spawn(fn ->
    Process.sleep(1000)
    IO.puts("Process 2A finished")
  end)

  raise("Something went wrong 1")
end)

# Processos lincados

# Processo pai é quebrado se o processo filho quebra

spawn(fn ->
  spawn_link(fn ->
    Process.sleep(1000)
    IO.puts("Process 2B finished")
  end)

  raise("Something went wrong 2")
end)

# Processo pai intercepta o erro ocorrido pelo processo filho e trata o erro

spawn(fn ->
  Process.flag(:trap_exit, true)

  spawn_link(fn -> raise("Something went wrong 3") end)

  receive do
    msg -> IO.inspect(msg)
  end
end)
