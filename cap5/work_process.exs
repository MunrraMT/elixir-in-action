run_query = fn query_def ->
  Process.sleep(2000)
  "#{query_def} result"
end

run_query.("query 1")
|> IO.inspect()

Enum.map(1..5, &run_query.("query #{&1}"))
|> IO.inspect()

async_query = fn query_def ->
  spawn(fn -> IO.puts(run_query.(query_def)) end)
end

async_query.("query 1")

# Passagem de mensagens

send(self(), {:ok, "success"})
send(self(), {:error, "Fail"})

receive do
  {:ok, message} -> IO.inspect("Resultado: #{message}")
  {:error, message} -> IO.inspect("Resultado: #{message}")
after
  5000 -> IO.puts("message not received")
end

Enum.each(1..5, &async_query.("query #{&1}")) |> IO.inspect()

# Envio síncrono

send(self(), {:ok, self(), "Deu certo!"})

receive do
  {:ok, pid, message} -> send(pid, {:ok, self(), "Recebido: #{message}"})
after
  5000 -> IO.puts("message not received")
end

# Coletando resultados da consulta

run_query = fn query_def ->
  Process.sleep(2000)
  "#{query_def} result"
end

async_query = fn query_def ->
  caller = self()

  spawn(fn ->
    send(caller, {:query_result, run_query.(query_def)})
  end)
end

Enum.each(1..100_000, &async_query.("query #{&1}"))

get_result = fn ->
  receive do
    {:query_result, result} -> result
  after
    2000 -> IO.puts("message not received")
  end
end

results = Enum.map(1..100_000, fn _ -> get_result.() end)

# Paralelismo Simples
1..100_000 |> Enum.map(&async_query.("query #{&1}")) |> Enum.map(fn _ -> get_result.() end)
