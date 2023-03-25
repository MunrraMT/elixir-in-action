defmodule Teste do
  def call(index) do
    t0 = System.monotonic_time(:millisecond)

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
        |> return_total(t0)

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
  end

  defp return_total(number, t0) do
    t1 = System.monotonic_time(:millisecond)
    timer = t1 - t0
    %{time: timer, result_sum: number}
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

total =
  Parallel.map(1..1_000, &Teste.call/1, size: 1)
  |> Enum.reduce(
    %{result_sum: 0, time: 0},
    fn current, acc ->
      total_sum = current.result_sum + acc.result_sum
      total_time = current.time + acc.time

      %{result_sum: total_sum, time: total_time}
    end
  )

IO.inspect(total)

# 289726ms 4p
# 252551ms 3p
# 219887ms 2p
# 199219ms 1p
# 554707ms default

# 8153ms
