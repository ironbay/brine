defmodule BrineTest do
  use ExUnit.Case
  doctest Brine

  test "greets the world" do
    assert Brine.hello() == :world
  end
end
