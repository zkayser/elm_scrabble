defmodule Scrabble.Grid do
  alias Scrabble.Cell
  alias Scrabble.Multiplier
  alias Scrabble.Position
  @type grid :: [Cell.t()]

  @spec setup() :: grid
  def setup do
    for x <- 1..225 do
      position = %Position{row: row_for(x), col: col_for(x)}
      %Cell{tile: :empty, position: position, multiplier: Multiplier.multiplier_for(position)}
    end
  end

  defp row_for(number) do
    (number / 15)
    |> Float.ceil()
    |> trunc()
  end

  defp col_for(number) when rem(number, 15) == 0, do: 15
  defp col_for(number), do: rem(number, 15)
end
