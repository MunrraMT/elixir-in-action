defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  # client process

  def start_link() do
    IO.puts("starting database server!")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(__MODULE__, {:choose_worker, key})
  end

  # server process

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, start_workers()}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _caller, workers) do
    worker_key = :erlang.phash2(key, 4)
    {:reply, Map.get(workers, worker_key), workers}
  end

  defp start_workers() do
    for index <- 1..4, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start_link(@db_folder)
      {index, pid}
    end
  end
end
