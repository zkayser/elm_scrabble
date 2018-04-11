defmodule BoardTest do
  use ExUnit.Case
  alias Scrabble.Board.Impl, as: Board
  @default_grid_cells 225
  @tile %Scrabble.Tile{letter: "A", id: 1, value: 1, multiplier: :no_multiplier}

  describe "new/0" do
    test "Generates a new board setup and board is initially invalid" do
      board = Board.new()
      assert %Board{} = board
      assert board.validity == :invalid
      assert length(Map.keys(board.grid)) == @default_grid_cells
    end
  end

  describe "play/3" do
    test "it updates the grid and moves the tile from in_play to played" do
      board =
        Board.new()
        |> Map.put(:tile_state, %Scrabble.TileManager{in_play: [@tile]})
        |> Board.play(@tile, {1, 1})

      assert board.grid[Scrabble.Position.make(1, 1)].tile == @tile
      assert @tile in board.tile_state.played
      refute @tile in board.tile_state.in_play
    end

    test "does not update if the tile is not in the current tiles" do
      board = Board.new()
      update = Board.play(board, @tile, {1, 1})

      assert update == board
    end

    test "does not update if the tile has already been played" do
      board =
        Board.new()
        |> Map.put(:played, [@tile])

      update = Board.play(board, @tile, {1, 1})

      assert update == board
    end
  end
end
