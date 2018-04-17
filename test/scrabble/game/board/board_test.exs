defmodule BoardTest do
  use ExUnit.Case
  alias Scrabble.Board.Impl, as: Board
  alias Scrabble.{Grid, Position, TestData}
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
      moves = for x <- 4..8, do: {8, x}
      grid = TestData.setup_grid_with(%{word: "facet", positions: moves})

      board =
        Board.new()
        |> Map.put(:moves, TestData.positions(moves))
        |> Map.put(:grid, grid)

      assert {:valid, [{:row, 8, 4..8}]} = Board.validate(board).validity
    end

    test "sets board state to valid + validated word when moves are validated across a col" do
      moves = for x <- 4..8, do: {x, 8}
      grid = TestData.setup_grid_with(%{word: "facet", positions: moves})

      board =
        Board.new()
        |> Map.put(:moves, TestData.positions(moves))
        |> Map.put(:grid, grid)

      assert {:valid, [{:col, 8, 4..8}]} = Board.validate(board).validity
    end

    test "captures words that are span longer than current moves made" do
      moves = for x <- 4..8, do: {8, x}
      positions = moves ++ [{8, 9}]
      grid = TestData.setup_grid_with(%{word: "facets", positions: positions})

      board =
        Board.new()
        |> Map.put(:moves, TestData.positions(moves))
        |> Map.put(:grid, grid)

      assert {:valid, [{:row, 8, 4..9}]} = Board.validate(board).validity
    end

    test "captures words that start before the current moves made" do
      moves = for x <- 4..8, do: {8, x}
      positions = [{8, 3} | moves]

      grid = TestData.setup_grid_with(%{word: "facets", positions: positions})

      board =
        Board.new()
        |> Map.put(:moves, TestData.positions(moves))
        |> Map.put(:grid, grid)

      assert {:valid, [{:row, 8, 3..8}]} = Board.validate(board).validity
    end

    test "does not validate if there a gaps between the current moves made" do
      positions = [{8, 8}, {8, 10}]

      tiles = [@tile, @tile2]
      tiles_with_position = Enum.zip(tiles, positions)
      {:ok, grid} = Grid.setup() |> Grid.place_tiles(tiles_with_position)

      board =
        Board.new()
        |> Map.put(:moves, TestData.positions(positions))
        |> Map.put(:grid, grid)

      validated = Board.validate(board)
      assert {:invalid, "Invalid move."} = validated.validity
      assert [Position.make(8, 9)] == validated.invalid_at
    end

    test "does not validate if the center piece has not been played" do
      positions = [{1, 1}, {1, 2}]
      grid = TestData.setup_grid_with(%{word: "ab", positions: positions})

      board =
        Board.new()
        |> Map.put(:moves, TestData.positions(positions))
        |> Map.put(:grid, grid)

      validated = Board.validate(board)
      assert {:invalid, "You must play a tile on the center piece."} = validated.validity
      assert [Position.make(8, 8)] == validated.invalid_at
    end

    test "validates secondary moves" do
      # NOTE: A `secondary move` is a move that lies on an axis perpendicular
      # to the move made by a player. For example, say there is an existing word
      # `cat` that goes from row 1, col 3 to row 3, col 3. If a player then makes
      # a move using the `a` and `t` in that move by playing `hat` from row 2, col 2
      # to row 4, col 2, the player should be credited for the move `hat` as well as the
      # words `ha` and `at` resulting from the combination of letters played in the
      # current turn with the adjacent letters from the existing word.
      hat_positions = [{7, 8}, {8, 8}, {9, 8}]
      play = %{word: "cat", positions: [{8, 7}, {9, 7}, {10, 7}]}
      play2 = %{word: "hat", positions: hat_positions}

      board =
        Board.new()
        |> Map.put(:moves, TestData.positions(hat_positions))
        |> Map.put(:tile_state, played: TestData.tiles("cat"))
        |> Map.put(:grid, TestData.setup_grid_with([play, play2]))

      %{validity: validity} = Board.validate(board)
      assert {:valid, [{:col, 8, 7..9}, {:row, 8, 7..8}, {:row, 9, 7..8}]} = validity
    end
  end
end
