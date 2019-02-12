defmodule Scrabble.Board.EncodersTest do
  use ExUnit.Case
  alias Scrabble.Grid

  @grid_length 225

  describe "encode/1 with grid" do
    test "it encodes a grid" do
      assert {:ok, json} = Grid.encode(Grid.setup())
      assert length(json) == @grid_length
    end
  end
end