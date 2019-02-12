defmodule Scrabble.Board.ImplTest do
  use ExUnit.Case
  alias Scrabble.Board.Impl, as: Board
  alias Scrabble.Position
  @default_grid_cells 225
  @tile %Scrabble.Tile{letter: "A", id: 1, value: 1, multiplier: :no_multiplier}
  @tile2 %Scrabble.Tile{letter: "B", id: 2, value: 1, multiplier: :no_multiplier}

  describe "new/0" do
    test "Generates a new board setup and board is initially invalid" do
      board = Board.new()
      assert %Board{} = board
      assert board.validity == :initial
      assert length(Map.keys(board.grid)) == @default_grid_cells
    end
  end

  describe "play/3" do
    test "it updates the grid, moves the tile from in_play to played, and adds a move" do
      board =
        Board.new()
        |> Map.put(:tile_state, %Scrabble.TileManager{in_play: [@tile]})
        |> Board.play(@tile, {1, 1})

      assert board.grid[Scrabble.Position.make(1, 1)].tile == @tile
      assert board.moves == [Scrabble.Position.make(1, 1)]
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
        |> Map.put(:tile_state, %Scrabble.TileManager{in_play: [], played: [@tile]})

      update = Board.play(board, @tile, {1, 1})

      assert update == board
    end
  end

  describe "play/2" do
    test "is a convenience wrapper to run play/3 with multiple tiles & positions" do
      board =
        Board.new()
        |> Map.put(:tile_state, %Scrabble.TileManager{in_play: [@tile, @tile2]})
        |> Board.play([{@tile, {1, 1}}, {@tile2, {1, 2}}])

      assert board.grid[Position.make(1, 1)].tile == @tile
      assert board.grid[Position.make(1, 2)].tile == @tile2
      assert @tile in board.tile_state.played
      assert @tile2 in board.tile_state.played
      refute @tile in board.tile_state.in_play
      refute @tile in board.tile_state.in_play
    end
  end

  describe "serialization" do
    test "encodes a Board.Impl struct to a JSON string" do
      assert {:ok, json} = Jason.encode(Board.new())
    end
  end
end
