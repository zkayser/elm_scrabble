defmodule TileManagerTest do
  alias Scrabble.TileManager
  use ExUnit.Case

  describe "generate/0" do
    test "creates a tilebag of unique tiles" do
      {in_play, rest} = TileManager.generate()
      assert (in_play ++ rest) |> Enum.uniq() |> length() == 100
      assert length(in_play) == 7
      assert length(rest) == 93
    end
  end
end
