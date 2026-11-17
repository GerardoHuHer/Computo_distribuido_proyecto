defmodule ObservabilityTest do
  use ExUnit.Case
  doctest Observability

  test "greets the world" do
    assert Observability.hello() == :world
  end
end
