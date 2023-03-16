defmodule MyServer do
  def start do
    spawn(fn -> loop() end)
  end

  def send_message(server, message) do
    send(server, {self(), message})

    receive do
      {:response, response} -> response
    end
  end

  defp loop do
    receive do
      {caller, message} ->
        Process.sleep(1000)
        send(caller, {:response, message})

      other ->
        IO.inspect(other)
    after
      5000 -> {:error, :timeout}
    end

    loop()
  end
end

# server = MyServer.start()

# Enum.each(
#   1..5,
#   fn i ->
#     spawn(fn ->
#       IO.puts("Sending msg ##{i}")
#       response = MyServer.send_message(server, i)
#       IO.puts("Response: #{response}")
#     end)
#   end
# )
