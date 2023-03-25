defmodule Teste do
  def call(index) do
    t1 = System.monotonic_time(:millisecond)

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
        |> IO.inspect()

      {:error, reason} ->
        IO.puts(reason)
    end

    t2 = System.monotonic_time(:millisecond)
    t2 - t1
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
    list |> length() |> IO.puts()
    list |> Enum.map(fn number -> number * index end)
  end

  defp result_sum(list) do
    list
    |> Enum.reduce(0, fn number, accumulator ->
      accumulator + number
    end)
  end
end

defmodule TesteServer do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def increase(number) do
    GenServer.cast(__MODULE__, number)
  end

  def result() do
    GenServer.call(__MODULE__, :get)
  end

  @impl GenServer
  def init(_) do
    {:ok, 0}
  end

  @impl GenServer
  def handle_cast(number, state) do
    {:noreply, number + state}
  end

  @impl GenServer
  def handle_call(:get, _, state) do
    {:reply, state, state}
  end
end

defmodule Parallel do
  def pmap(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(&Task.await/1)
  end
end

# Parallel.pmap(1..100, &Teste.call(&1))

TesteServer.start()

1..25_000 |> Enum.each(fn number -> TesteServer.increase(Teste.call(number)) end)

total = TesteServer.result()
IO.puts("Total: #{total}")

# 853ms
