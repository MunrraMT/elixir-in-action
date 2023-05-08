defmodule Todo.Web do
  def child_spec(_opts) do
    Plug.Cowboy.child_spec(
      scheme: :http,
      options: [port: 3000],
      plug: __MODULE__
    )
  end
end
