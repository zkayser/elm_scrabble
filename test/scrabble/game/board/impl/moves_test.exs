defmodule MovesTest do
  use ExUnit.Case
  alias Scrabble.Position
  alias Scrabble.Board.Moves

  @valid_on_row Enum.map(1..5, &Position.make(1, &1))
  @valid_on_col Enum.map(1..5, &Position.make(&1, 1))
  @invalid [Position.make(1, 1), Position.make(15, 15)]

  describe "validate/1" do
    test "returns :valid if all moves were made along a row" do
      assert {:row, 1} = Moves.validate(@valid_on_row)
    end

    test "returns :valid if all moves were made along a column" do
      assert {:col, 1} = Moves.validate(@valid_on_col)
    end

    test "returns :invalid if moves were made neither along a single col or row" do
      assert :invalid = Moves.validate(@invalid)
    end
  end
end
