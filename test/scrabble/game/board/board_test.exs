defmodule BoardTest do
  use ExUnit.Case
  alias Scrabble.Board.Impl, as: Board
  @default_grid_cells 225

  describe "new/0" do
    test "Generates a new board setup and board is initially invalid" do
      board = Board.new()
      assert %Board{} = board
      assert board.validity == :invalid
      assert length(Map.keys(board.grid)) == @default_grid_cells
    end
  end
end
