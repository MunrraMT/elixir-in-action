defmodule MyModule.ListLength do
  @doc """
    Returns list length
  """
  def call(list), do: do_list_length(0, list)

  defp do_list_length(count_length, []), do: count_length

  defp do_list_length(count_length, [_hd | tl]) do
    do_list_length(count_length + 1, tl)
  end
end

# 0
IO.puts(MyModule.ListLength.call([]))

# 1
IO.puts(MyModule.ListLength.call([1]))

# 3
IO.puts(MyModule.ListLength.call([1, "foi?", :ok]))

defmodule MyModule.Range do
  @doc """
    Returns a list of all integer numbers in the given range
  """
  def call(from, to) when from >= to do
    {:error, "FROM can't be greater or equal than TO"}
  end

  def call(from, to), do: do_range_to_list([], from, to)

  defp do_range_to_list(list, from, to) when from > to do
    list
  end

  defp do_range_to_list(list, from, to) do
    do_range_to_list([to | list], from, to - 1)
  end
end

# {:error, "FROM can't be greater than TO"}
IO.inspect(MyModule.Range.call(0, 0))

# [0, 1, 2, 3]
IO.inspect(MyModule.Range.call(0, 3))

# [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
#  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41,
#  42, 43, 44, 45, 46, 47, 48, 49, ...]
# IO.inspect(MyModule.Range.call(0, 100_000))

defmodule MyModule.Positive do
  def call(list), do: do_filter_positive_list([], list)

  defp do_filter_positive_list(filteredList, []), do: Enum.reverse(filteredList)

  defp do_filter_positive_list(filteredList, [hd | tl]) when is_integer(hd) and hd > 0 do
    do_filter_positive_list([hd | filteredList], tl)
  end

  defp do_filter_positive_list(filteredList, [_hd | tl]) do
    do_filter_positive_list(filteredList, tl)
  end
end

# [10, 20]
IO.inspect(MyModule.Positive.call(["15", 10, -2, "foi?", 20, "25"]), charlists: false)
