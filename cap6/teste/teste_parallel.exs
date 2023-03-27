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

{time_sql, _result} = :timer.tc(fn -> Teste.call(1) end)

IO.puts("tempo 1x: #{time_sql / 1000}ms")
# 18ms
