defmodule Scrabble.Board.EncodersTest do
  use ExUnit.Case
  alias Scrabble.Grid
  alias Scrabble.Board.Impl

  @grid_length 225

  describe "encode/1 with Grid" do
    test "it encodes a grid" do
      assert {:ok, json} = Grid.encode(Grid.setup())
      assert length(json) == @grid_length
    end
  end

  describe "encode/1 with Board.Impl struct" do
    test "it encodes Board.Impl structs" do
      assert {:ok, json} = Jason.encode(Impl.new())
    end
  end
end