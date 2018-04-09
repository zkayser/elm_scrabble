defmodule TileTest do
  use ExUnit.Case
  alias Scrabble.Tile

  describe "create/1" do
    test "creates a tile with the given id and letter" do
      assert Tile.create({1, "A"}) == %Tile{
               letter: "A",
               id: 1,
               value: 1,
               multiplier: :no_multiplier
             }
    end

    test "gives wildcards the correct multiplier and value" do
      assert Tile.create({1, ""}) == %Tile{letter: "", id: 1, value: 0, multiplier: :wildcard}
    end
  end
end
