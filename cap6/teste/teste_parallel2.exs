defmodule Teste do
  def call(index) do
    case File.read("teste.txt") do
      {:ok, content} ->
        content
        |> lower_cased()
        |> without_comma()
        |> splinted()
        |> replaced_map()
        |> removed_number_ten()
        |> multiplied_for_ten(index)
        |> result_sum()

      {:error, reason} ->
        IO.puts(reason)
    end
  end

  defp lower_cased(text), do: String.downcase(text)

  defp without_comma(text), do: String.replace(text, [",", "."], "")

  defp splinted(text), do: String.split(text)

  defp replaced_map(text) do
    text
    |> Enum.map(fn word ->
      cond do
        String.first(word) == "a" -> 1
        String.first(word) == "b" -> 2
        String.first(word) == "c" -> 3
        String.first(word) == "d" -> 4
        String.first(word) == "e" -> 5
        String.first(word) == "f" -> 6
        String.first(word) == "g" -> 7
        String.first(word) == "h" -> 8
        String.first(word) == "i" -> 9
        true -> 10
      end
    end)
  end

  defp removed_number_ten(list) do
    list |> Enum.filter(fn number -> number != 10 end)
  end

  defp multiplied_for_ten(list, index) do
    list |> Enum.map(fn number -> number * index end)
  end

  defp result_sum(list) do
    list
    |> Enum.reduce(0, fn number, accumulator ->
      accumulator + number
    end)

    %{result_sum: list}
  end
end

defmodule Parallel do
  def map(collection, fun, options \\ []) do
    run(collection, fun, options, [], fn item, acc -> [item | acc] end)
  end

  def each(collection, fun, options \\ []) do
    run(collection, fun, options, nil, fn _item, nil -> nil end)
  end

  def any?(collection, fun, options \\ []) do
    run(collection, fun, options, false, fn item, value -> item || value end)
  end

  def all?(collection, fun, options \\ []) do
    run(collection, fun, options, true, fn item, value -> item && value end)
  end

  # Private

  defp run(collection, fun, options, acc, update) do
    state = {pool(fun, options), [], acc, update}
    {_, busy, acc, _} = Enum.reduce(collection, state, &execute/2)
    consume(busy, acc, update)
  end

  defp execute(item, {free = [], busy, acc, update}) do
    receive do
      {ref, from, result} ->
        send(from, {ref, self(), item})
        {free, busy, update.(result, acc), update}
    end
  end

  defp execute(item, {[worker = {ref, pid} | free], busy, acc, update}) do
    send(pid, {ref, self(), item})
    {free, [worker | busy], acc, update}
  end

  defp consume(pool, acc, update) do
    Enum.reduce(pool, acc, fn {ref, pid}, acc ->
      receive do
        {^ref, ^pid, result} -> update.(result, acc)
      end
    end)
  end

  def worker(fun) do
    receive do
      {ref, sender, item} ->
        send(sender, {ref, self(), fun.(item)})
        worker(fun)

      :exit ->
        :ok
    end
  end

  defp pool(fun, options) do
    size = Keyword.get(options, :size) || :erlang.system_info(:schedulers) * 2
    spawn_worker = fn -> {make_ref(), spawn_link(fn -> worker(fun) end)} end
    Stream.repeatedly(spawn_worker) |> Enum.take(size)
  end
end

{time_sql, _result} =
  :timer.tc(fn -> Enum.map(1..50_000, fn number -> Teste.call(number) end) end)

IO.puts("tempo sql: #{time_sql / 1000}ms")
# 320_433ms

{time_1, _result} = :timer.tc(fn -> Parallel.map(1..50_000, &Teste.call/1, size: 1) end)

IO.puts("tempo 1: #{time_1 / 1000}ms")
# 418_211ms

{time_2, _result} = :timer.tc(fn -> Parallel.map(1..50_000, &Teste.call/1, size: 2) end)

IO.puts("tempo 2: #{time_2 / 1000}ms")
# 217_376ms

{time_3, _result} = :timer.tc(fn -> Parallel.map(1..50_000, &Teste.call/1, size: 3) end)

IO.puts("tempo 3: #{time_3 / 1000}ms")
# 166_072ms

{time_4, _result} = :timer.tc(fn -> Parallel.map(1..50_000, &Teste.call/1, size: 4) end)

IO.puts("tempo 4: #{time_4 / 1000}ms")
# 151_457ms

{time_default, _result} = :timer.tc(fn -> Parallel.map(1..50_000, &Teste.call/1) end)

IO.puts("tempo default: #{time_default / 1000}ms")
# 152_915ms
