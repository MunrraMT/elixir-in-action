defmodule Todo.Metrics do
  use Task

  def start_link(_arg) do
    IO.puts("starting metrics")
    Task.start_link(&loop/0)
  end

  defp loop() do
    Process.sleep(:timer.seconds(2))

    collect_metrics()
    |> IO.inspect()

    loop()
  end

  defp collect_metrics() do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
