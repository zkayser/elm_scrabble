defmodule PositionTest do
  use ExUnit.Case
  alias Scrabble.Position

  describe "make/1" do
    test "is a convenience for creating Position structs" do
      assert %Position{row: 1, col: 1} = Position.make(1, 1)
    end

    test "raises when passed zeros" do
      assert_raise(ArgumentError, fn ->
        Position.make(0, 0)
      end)
    end

    test "raises when passed negative numbers" do
      assert_raise(ArgumentError, fn ->
        Position.make(-1, -1)
      end)
    end

    test "raises when passed floating point numbers" do
      assert_raise(ArgumentError, fn ->
        Position.make(1.5, 2.0)
      end)
    end
  end
end
