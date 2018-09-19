defmodule DynDnsTest do
  use ExUnit.Case
  doctest DynDns

  test "greets the world" do
    assert DynDns.hello() == :world
  end
end
