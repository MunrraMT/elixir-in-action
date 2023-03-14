defmodule MyModule.Fraction do
  defstruct a: nil, b: nil

  def new(a, b) do
    %MyModule.Fraction{a: a, b: b}
  end

  def value(%MyModule.Fraction{a: a, b: b}) do
    a / b
  end

  def add(%MyModule.Fraction{a: a1, b: b1}, %MyModule.Fraction{a: a2, b: b2}) do
    new(
      a1 * b2 + a2 * b1,
      b2 * b1
    )
  end
end
