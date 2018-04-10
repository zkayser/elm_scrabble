defmodule Scrabble.Grid do
  alias Scrabble.Cell
  alias Scrabble.Multiplier
  alias Scrabble.Position
  @type t :: %{required(Position.t()) => Cell.t()}
  @typep result :: {:ok | :error, t()}
  @typep position :: {pos_integer(), pos_integer()}

  @spec setup() :: t()
  def setup do
    for x <- 1..225 do
      position = %Position{row: row_for(x), col: col_for(x)}

      %{
        position => %Cell{
          tile: :empty,
          position: position,
          multiplier: Multiplier.multiplier_for(position)
        }
      }
    end
    |> Enum.reduce(%{}, &build_grid/2)
  end

  @spec size(t()) :: non_neg_integer()
  def size(%{} = grid) do
    length(Map.keys(grid))
  end

  @spec place_tile(t() | result, Scrabble.Tile.t(), position) :: result
  def place_tile(%{} = grid, %Scrabble.Tile{} = tile, {row, col}) do
    do_place_tile(grid, tile, {row, col})
  end

  def place_tile({:ok, %{} = grid}, %Scrabble.Tile{} = tile, {row, col}) do
    do_place_tile(grid, tile, {row, col})
  end

  def place_tile({:error, grid}, _, _), do: {:error, grid}

  defp do_place_tile(grid, tile, {row, col}) do
    with %Cell{tile: :empty} = cell <- grid[Position.make(row, col)] do
      {:ok, %{grid | Position.make(row, col) => %{cell | tile: tile}}}
    else
      _ -> {:error, grid}
    end
  end

  defp build_grid(key_value, acc) do
    Enum.into(key_value, acc)
  end

  defp row_for(number) do
    (number / 15)
    |> Float.ceil()
    |> trunc()
  end

  defp col_for(number) when rem(number, 15) == 0, do: 15
  defp col_for(number), do: rem(number, 15)
end
