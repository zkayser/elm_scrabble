defmodule TileManagerTest do
  alias Scrabble.TileManager
  use ExUnit.Case

  describe "generate/0" do
    test "creates a list of 100 unique tiles" do
      assert Enum.uniq(TileManager.generate()) |> length() == 100
    end
  end
end
