defmodule GridTest do
  use ExUnit.Case
  alias Scrabble.{Grid, Cell, Tile, Position}
  @tile %Tile{letter: "A"}
  @tile2 %Tile{letter: "B"}

  describe "setup/0" do
    test "creates a 15 X 15 grid" do
      assert Grid.setup() |> Grid.size() == 225
    end

    test "creates cells for each element of the grid" do
      for {_position, cell} <- Grid.setup() do
        assert %Cell{} = cell
      end
    end
  end

  describe "place_tile/3" do
    test "returns an ok tuple with the new grid when successful" do
      assert {:ok, grid} = Grid.place_tile(Grid.setup(), @tile, {1, 1})
      assert grid[%Scrabble.Position{row: 1, col: 1}].tile == @tile
    end

    test "returns an error tuple with the old grid when the position does not exist" do
      assert {:error, Grid.setup()} == Grid.place_tile(Grid.setup(), @tile, {150, 150})
    end

    test "returns an error tuple with the old grid when a tile already exists at the position" do
      {:ok, initial} = Grid.place_tile(Grid.setup(), @tile, {1, 1})
      assert {:error, initial} == Grid.place_tile(initial, @tile, {1, 1})
    end
  end

  describe "place_tiles/2" do
    test "returns an ok tuple with the new grid on success" do
      tiles = [{@tile, {1, 1}}, {@tile2, {1, 2}}]
      assert {:ok, grid} = Grid.place_tiles(Grid.setup(), tiles)
      assert grid[Position.make(1, 1)].tile == @tile
      assert grid[Position.make(1, 2)].tile == @tile2
    end

    test "returns error with the initial grid if any tile placements fail" do
      tiles = [{@tile, {1, 1}}, {%Tile{letter: "C"}, {1, 32}}, {@tile2, {1, 2}}]
      grid = Grid.setup()
      assert {:error, grid} == Grid.place_tiles(grid, tiles)
    end
  end

  describe "is_center_played?/1" do
    test "returns true if there is a tile at row 8, col 8" do
      assert Grid.setup()
             |> Map.put(Position.make(8, 8), %Scrabble.Cell{tile: @tile})
             |> Grid.is_center_played?()
    end

    test "returns false if row 8, col 8 is empty" do
      refute Grid.is_center_played?(Grid.setup())
    end
  end

  describe "get/2" do
    test "returns the subset of the grid for a given row number" do
      # Get all of the keys (of type Position.t()) and assert that
      # the row attribute on each one equals the requested row attribute
      assert Grid.setup()
             |> Grid.get({:row, 2})
             |> Map.keys()
             |> Enum.all?(&(&1.row == 2))
    end

    test "returns the subset of the grid for a given col number" do
      assert Grid.setup()
             |> Grid.get({:col, 2})
             |> Map.keys()
             |> Enum.all?(&(&1.col == 2))
    end

    test "returns the grid if an invalid row or col number is requested" do
      assert Grid.setup() |> Grid.get({:col, 27}) == Grid.setup()
    end
  end

  describe "get_tiles_from_range/3" do
    test "returns a list of tiles from a given range along a row" do
      tiles =
        Grid.setup()
        |> Map.put(Position.make(8, 8), %Scrabble.Cell{tile: @tile})
        |> Map.put(Position.make(8, 9), %Scrabble.Cell{tile: @tile2})
        |> Grid.get_tiles_from_range(8..9, :row)

      assert @tile in tiles
      assert @tile2 in tiles
    end

    test "returns a list of tiles from a given range along a col" do
      tiles =
        Grid.setup()
        |> Map.put(Position.make(8, 8), %Scrabble.Cell{tile: @tile})
        |> Map.put(Position.make(9, 8), %Scrabble.Cell{tile: @tile2})
        |> Grid.get_tiles_from_range(8..9, :col)

      assert @tile in tiles
      assert @tile2 in tiles
    end

    test "returns an empty list if given an invalid range" do
      assert [] = Grid.setup() |> Grid.get_tiles_from_range(0..115, :col)
    end
  end

  describe "update_subgrid/3" do
    test "updates a row with a new row" do
      new_row =
        for col <- 1..15, into: %{} do
          {Scrabble.Position.make(8, col), %Scrabble.Cell{tile: @tile}}
        end

      assert new_row ==
               Grid.setup()
               |> Grid.update_subgrid(new_row)
               |> Grid.get({:row, 8})
    end

    test "updates a col with a new col" do
      new_col =
        for row <- 1..15, into: %{} do
          {Scrabble.Position.make(row, 8), %Scrabble.Cell{tile: @tile}}
        end

      assert new_col ==
               Grid.setup()
               |> Grid.update_subgrid(new_col)
               |> Grid.get({:col, 8})
    end
  end
end
