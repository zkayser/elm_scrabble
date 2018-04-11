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

  describe "new/0" do
    test "creates a new TileManager struct" do
      manager = TileManager.new()
      assert (manager.in_play ++ manager.tile_bag) |> Enum.uniq() |> length() == 100
      assert manager.played == []
    end
  end

  describe "handle_played/2" do
    test "moves a tile from in_play to played" do
      manager = TileManager.new()
      [tile | _] = manager.in_play
      assert [] = manager.played
      update = TileManager.handle_played(manager, tile)
      refute tile in update.in_play
      assert tile in update.played
    end
  end
end
