defmodule GridTest do
  use ExUnit.Case
  alias Scrabble.Grid
  alias Scrabble.Cell
  alias Scrabble.Tile
  @tile %Tile{letter: "A"}

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
end
