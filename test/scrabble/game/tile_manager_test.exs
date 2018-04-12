defmodule TileManagerTest do
  alias Scrabble.TileManager
  use ExUnit.Case
  @tiles [%Scrabble.Tile{letter: "A"}, %Scrabble.Tile{letter: "B"}]

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

  describe "replenish/1" do
    test "takes tiles from the tile_bag to refill tiles in play" do
      manager = TileManager.new() |> Map.put(:in_play, [])
      assert Enum.take(manager.tile_bag, 7) == TileManager.replenish(manager).in_play
    end

    test "performs a no-op when :in_play is already at capacity" do
      manager = TileManager.new()
      assert manager == TileManager.replenish(manager)
    end

    test "performs a no-op when tile_bag is empty" do
      manager = TileManager.new() |> Map.put(:tile_bag, [])
      assert manager == TileManager.replenish(manager)
    end

    test "takes the remainder of the tile bag when there are fewer than 7 tiles remaining" do
      manager = TileManager.new() |> Map.put(:in_play, []) |> Map.put(:tile_bag, @tiles)
      assert @tiles == TileManager.replenish(manager).in_play
    end
  end
end
