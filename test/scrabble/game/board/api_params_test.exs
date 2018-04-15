defmodule Scrabble.Board.ApiParamsTest do
  use ExUnit.Case
  alias Scrabble.Tile
  alias Scrabble.Board.ApiParams, as: Params

  describe "convert/1" do
    test "converts the api params to Elixir data types" do
      raw_params = %{
        "tile" => %{"letter" => "A", "id" => 8},
        "position" => %{"row" => 1, "col" => 1}
      }

      assert {%Tile{letter: "A"}, {1, 1}} = Params.convert(raw_params)
    end

    test "leaves Elixir data types as is" do
      elixir_params = {%Tile{letter: "A"}, {1, 1}}
      assert elixir_params == Params.convert(elixir_params)
    end
  end
end
