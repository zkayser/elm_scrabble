defmodule BoardTest do
  use ExUnit.Case
  alias Scrabble.Board.Impl, as: Board
  alias Scrabble.{Position, Grid}
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

  describe "validate/1" do
    test "sets board state to valid + validated word when moves are validated across a row" do
      valid_moves_row = Enum.map(3..8, &Position.make(8, &1))
      positions = for x <- 3..8, do: {8, x}

      tiles_played =
        String.codepoints("facet")
        |> Enum.map(&%Scrabble.Tile{letter: &1})

      tiles_with_position = Enum.zip(tiles_played, positions)
      {:ok, grid} = Grid.place_tiles(Grid.setup(), tiles_with_position)

      board =
        Board.new()
        |> Map.put(:grid, grid)
        |> Map.put(:moves, valid_moves_row)
        |> Map.put(:tile_state, played: tiles_played)

      assert {:valid, "facet"} = Board.validate(board).validity
    end

    test "sets board state to valid + validated word when moves are validated across a col" do
      valid_moves_col = Enum.map(3..8, &Position.make(&1, 8))
      positions = for x <- 3..8, do: {x, 8}

      tiles_played =
        String.codepoints("facet")
        |> Enum.map(&%Scrabble.Tile{letter: &1})

      tiles_with_position = Enum.zip(tiles_played, positions)
      {:ok, grid} = Grid.place_tiles(Grid.setup(), tiles_with_position)

      board =
        Board.new()
        |> Map.put(:grid, grid)
        |> Map.put(:moves, valid_moves_col)
        |> Map.put(:tile_state, played: tiles_played)

      assert {:valid, "facet"} = Board.validate(board).validity
    end

    test "captures words that are span longer than current moves made" do
      moves = Enum.map(3..8, &Position.make(1, &1))
      positions = for x <- 3..9, do: {8, x}

      tiles_played =
        String.codepoints("facets")
        |> Enum.map(&%Scrabble.Tile{letter: &1})

      tiles_with_position = Enum.zip(tiles_played, positions)
      {:ok, grid} = Grid.place_tiles(Grid.setup(), tiles_with_position)

      board =
        Board.new()
        |> Map.put(:grid, grid)
        |> Map.put(:moves, moves)
        |> Map.put(:tile_state, played: tiles_played)

      assert {:valid, "facets"} = Board.validate(board).validity
    end

    test "captures words that are composed of tiles between current moves made" do
      moves = [Position.make(8, 7), Position.make(8, 9)]
      positions = for x <- 7..9, do: {8, x}

      tiles_played = String.codepoints("cat") |> Enum.map(&%Scrabble.Tile{letter: &1})
      tiles_with_position = Enum.zip(tiles_played, positions)
      {:ok, grid} = Grid.place_tiles(Grid.setup(), tiles_with_position)

      board =
        Board.new()
        |> Map.put(:grid, grid)
        |> Map.put(:moves, moves)
        |> Map.put(:tile_state, played: tiles_played)

      assert {:valid, "cat"} = Board.validate(board).validity
    end

    test "does not validate when current moves made are not connected by tiles" do
      moves = [Position.make(1, 1), Position.make(1, 3)]
      positions = [{1, 1}, {1, 3}]

      tiles_played = String.codepoints("as") |> Enum.map(&%Scrabble.Tile{letter: &1})
      tiles_with_position = Enum.zip(tiles_played, positions)
      {:ok, grid} = Grid.place_tiles(Grid.setup(), tiles_with_position)

      board =
        Board.new()
        |> Map.put(:grid, grid)
        |> Map.put(:moves, moves)
        |> Map.put(:tile_state, played: tiles_played)

      assert :invalid = Board.validate(board).validity
    end
  end
end
