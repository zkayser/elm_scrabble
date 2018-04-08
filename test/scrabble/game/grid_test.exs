defmodule GridTest do
  use ExUnit.Case
  alias Scrabble.Grid
  alias Scrabble.Cell

  describe "setup/0" do
    test "creates a 15 X 15 grid" do
      assert length(Grid.setup()) == 225
    end

    test "creates cells for each element of the grid" do
      for cell <- Grid.setup() do
        assert %Cell{} = cell
      end
    end
  end
end
