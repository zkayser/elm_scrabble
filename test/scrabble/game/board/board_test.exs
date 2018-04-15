defmodule BoardTest do
  use ExUnit.Case
  alias Scrabble.Board.Impl, as: Board
  alias Scrabble.{Grid, Position}
  @default_grid_cells 225
  @tile %Scrabble.Tile{letter: "A", id: 1, value: 1, multiplier: :no_multiplier}
  @tile2 %Scrabble.Tile{letter: "B", id: 2, value: 1, multiplier: :no_multiplier}

  describe "new/0" do
    test "Generates a new board setup and board is initially invalid" do
      board = Board.new()
      assert %Board{} = board
      assert board.validity == {:invalid, "You haven't made any moves yet."}
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

  describe "validate/1" do
    test "sets board state to valid + validated word when moves are validated across a row" do
      valid_moves_row = Enum.map(4..8, &Position.make(8, &1))
      positions = for x <- 4..8, do: {8, x}

      tiles_played =
        String.codepoints("facet")
        |> Enum.map(&%Scrabble.Tile{letter: &1})

      tiles_with_position = Enum.zip(tiles_played, positions)
      {:ok, grid} = Grid.setup() |> Grid.place_tiles(tiles_with_position)

      board =
        Board.new()
        |> Map.put(:moves, valid_moves_row)
        |> Map.put(:tile_state, played: tiles_played)
        |> Map.put(:grid, grid)

      assert {:valid, "facet"} = Board.validate(board).validity
    end

    test "sets board state to valid + validated word when moves are validated across a col" do
      valid_moves_col = Enum.map(4..8, &Position.make(&1, 8))
      positions = for x <- 4..8, do: {x, 8}

      tiles_played =
        String.codepoints("facet")
        |> Enum.map(&%Scrabble.Tile{letter: &1})

      tiles_with_position = Enum.zip(tiles_played, positions)
      {:ok, grid} = Grid.setup() |> Grid.place_tiles(tiles_with_position)

      board =
        Board.new()
        |> Map.put(:moves, valid_moves_col)
        |> Map.put(:tile_state, played: tiles_played)
        |> Map.put(:grid, grid)

      assert {:valid, "facet"} = Board.validate(board).validity
    end

    test "captures words that are span longer than current moves made" do
      valid_moves_row = Enum.map(4..8, &Position.make(8, &1))
      positions = for x <- 4..9, do: {8, x}

      tiles =
        String.codepoints("facets")
        |> Enum.map(&%Scrabble.Tile{letter: &1})

      tiles_with_position = Enum.zip(tiles, positions)
      {:ok, grid} = Grid.setup() |> Grid.place_tiles(tiles_with_position)

      board =
        Board.new()
        |> Map.put(:moves, valid_moves_row)
        |> Map.put(:tile_state, played: tiles)
        |> Map.put(:grid, grid)

      assert {:valid, "facets"} = Board.validate(board).validity
    end

    test "captures words that start before the current moves made" do
      valid_moves_row = Enum.map(4..8, &Position.make(8, &1))
      positions = for x <- 3..8, do: {8, x}

      tiles =
        String.codepoints("facets")
        |> Enum.map(&%Scrabble.Tile{letter: &1})

      tiles_with_position = Enum.zip(tiles, positions)
      {:ok, grid} = Grid.setup() |> Grid.place_tiles(tiles_with_position)

      board =
        Board.new()
        |> Map.put(:moves, valid_moves_row)
        |> Map.put(:tile_state, played: tiles)
        |> Map.put(:grid, grid)

      assert {:valid, "facets"} = Board.validate(board).validity
    end

    test "does not validate if there a gaps between the current moves made" do
      moves = [Position.make(8, 8), Position.make(8, 10)]
      positions = [{8, 8}, {8, 10}]

      tiles = [@tile, @tile2]
      tiles_with_position = Enum.zip(tiles, positions)
      {:ok, grid} = Grid.setup() |> Grid.place_tiles(tiles_with_position)

      board =
        Board.new()
        |> Map.put(:moves, moves)
        |> Map.put(:tile_state, played: tiles)
        |> Map.put(:grid, grid)

      assert {:invalid, "Invalid move."} = Board.validate(board).validity
    end

    test "does not validate if the center piece has not been played" do
      moves = [Position.make(1, 1), Position.make(1, 2)]
      positions = [{1, 1}, {1, 2}]

      tiles = [@tile, @tile2]
      tiles_with_position = Enum.zip(tiles, positions)
      {:ok, grid} = Grid.setup() |> Grid.place_tiles(tiles_with_position)

      board =
        Board.new()
        |> Map.put(:moves, moves)
        |> Map.put(:tile_state, played: tiles)
        |> Map.put(:grid, grid)

      assert {:invalid, "You must play a tile on the center piece."} =
               Board.validate(board).validity
    end
  end
end
