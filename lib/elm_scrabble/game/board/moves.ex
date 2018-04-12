defmodule Scrabble.Moves do
  alias Scrabble.Position

  @type t :: [Position.t()]
  @type dimension :: {:row, pos_integer()} | {:col, pos_integer()} | :invalid

  @spec validate(t()) :: dimension
  def validate([]), do: :invalid
  def validate([position]), do: {:row, position.row}

  def validate([%Position{row: row, col: col} | rest]) do
    cond do
      Enum.all?(rest, &(&1.row == row)) -> {:row, row}
      Enum.all?(rest, &(&1.col == col)) -> {:col, col}
      true -> :invalid
    end
  end
end
