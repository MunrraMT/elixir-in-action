defmodule EtsKeyValue do
  use GenServer

  # client side

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def put(key, value) do
    :ets.insert(__MODULE__, {key, value})
  end

  def get(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  # server side

  @impl GenServer
  def init(_) do
    :ets.new(__MODULE__, [
      :named_table,
      :public,
      write_concurrency: true
    ])

    {:ok, nil}
  end
end
