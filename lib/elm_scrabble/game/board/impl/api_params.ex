defmodule Scrabble.Board.ApiParams do
  alias Scrabble.Tile

  @type t() :: %{required(String.t()) => api_tile() | api_position()} | converted()
  @type api_tile :: %{required(String.t()) => String.t() | pos_integer()}
  @type api_position :: %{required(String.t()) => pos_integer()}
  @type converted :: {Tile.t(), {pos_integer(), pos_integer()}}

  @spec convert(t()) :: converted()
  def convert(%{"tile" => tile, "position" => position}) do
    {%Tile{
       letter: tile["letter"],
       id: tile["id"],
       value: tile["value"],
       multiplier: tile["multiplier"]
     }, {position["row"], position["col"]}}
  end

  def convert({%Tile{} = tile, {row, col}}) do
    {tile, {row, col}}
  end
end
