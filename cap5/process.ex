defmodule CodeMiner.Concurrency do
  def run_query(query) do
    Process.sleep(2000)
    IO.inspect("Query executed: #{query}")
  end
end

# Enum.each(1..5, fn x -> CodeMiner.Concurrency.run_query("query #{x}") end)

defmodule CodeMiner.Messages do
  def start do
    spawn(fn -> respond() end)
  end

  def respond do
    receive do
      {caller, message} ->
        send(caller, {:response, "#{message} ... is it your msg?"})
    end
  end
end
