# defmodule KeyValueStore do
#   use GenServer
# end

# KeyValueStore.__info__(:functions)
# [ child_spec: 1, code_change: 3, handle_call: 3, handle_cast: 2, handle_info: 2, init: 1, terminate: 2 ]

# GenServer.start(KeyValueStore, nil)
# {:ok, #PID<0.116.0>}

defmodule KeyValueStore do
  use GenServer

  # client process

  # def start do
  #   GenServer.start(KeyValueStore, nil)
  # end

  # def put(pid, key, value) do
  #   GenServer.cast(pid, {:put, key, value})
  # end

  # def get(pid, key) do
  #   GenServer.call(pid, {:get, key})
  # end

  # Criando namespace para o processo

  # def start() do
  #   GenServer.start(KeyValueStore, nil, name: KeyValueStore)
  # end

  # def put(key, value) do
  #   GenServer.cast(KeyValueStore, {:put, key, value})
  # end

  # def get(key) do
  #   GenServer.call(KeyValueStore, {:get, key})
  # end

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  # server process

  @impl GenServer
  def init(_) do
    :timer.send_interval(10000, :cleanup)
    {:ok, %{}}
  end

  @impl GenServer
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    IO.puts("performing cleanup...")
    {:noreply, state}
  end
end

# {:ok, pid} = KeyValueStore.start()
# {:ok, #PID<0.115.0>}

# KeyValueStore.put(pid, :some_key, :some_value)
# :ok

# KeyValueStore.get(pid, :some_key)
# :some_value
