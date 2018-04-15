defmodule Scrabble.Grid do
  alias Scrabble.{Cell, Multiplier, Position}
  @type t :: %{required(Position.t()) => Cell.t()}
  @typep result :: {:ok | :error, t()}
  @typep position :: {pos_integer(), pos_integer()}
  @typep dimension :: {:row | :col, pos_integer()}

  defguard is_valid(first, last) when first > 0 and last <= 15

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

  @spec place_tiles(t(), [{Scrabble.Tile.t(), position}]) :: result()
  def place_tiles(grid, tiles) do
    case Enum.reduce(tiles, grid, fn {tile, pos}, new_grid -> place_tile(new_grid, tile, pos) end) do
      {:ok, grid} -> {:ok, grid}
      {:error, _} -> {:error, grid}
    end
  end

  @spec place_tile(t() | result, Scrabble.Tile.t(), position) :: result
  def place_tile(%{} = grid, %Scrabble.Tile{} = tile, {row, col}) do
    do_place_tile(grid, tile, {row, col})
  end

  def place_tile({:ok, %{} = grid}, %Scrabble.Tile{} = tile, {row, col}) do
    do_place_tile(grid, tile, {row, col})
  end

  def place_tile({:error, grid}, _, _), do: {:error, grid}

  @spec is_center_played?(t()) :: boolean()
  def is_center_played?(grid) do
    grid[Position.make(8, 8)].tile != :empty
  end

  @spec get(t(), dimension()) :: t()
  def get(grid, {:row, num}) when num > 0 and num <= 15 do
    Enum.reduce(grid, %{}, fn {%{row: row} = pos, _}, acc ->
      if row == num, do: Map.put(acc, pos, grid[pos]), else: acc
    end)
  end

  def get(grid, {:col, num}) when num > 0 and num <= 15 do
    Enum.reduce(grid, %{}, fn {%{col: col} = pos, _}, acc ->
      if col == num, do: Map.put(acc, pos, grid[pos]), else: acc
    end)
  end

  def get(grid, _), do: grid

  @spec get_tiles_from_range(t(), Range.t(), :row | :col) :: [Scrabble.Tile.t()]
  def get_tiles_from_range(subgrid, %{first: first, last: last}, dim)
      when is_valid(first, last) do
    subgrid
    |> Enum.filter(fn {pos, _} ->
      pos[Position.opposite_of(dim)] >= first && pos[Position.opposite_of(dim)] <= last
    end)
    |> Enum.filter(fn {_, %Cell{tile: tile}} -> tile != :empty end)
    |> Enum.map(fn {_, %Cell{tile: tile}} -> tile end)
    |> maybe_reverse(dim)
  end

  def get_tiles_from_range(_, _, _), do: []

  @spec update_subgrid(t(), [{Position.t(), Cell.t()}]) :: t()
  def update_subgrid(grid, subgrid) do
    Enum.reduce(subgrid, grid, fn {pos, cell}, new_grid -> Map.put(new_grid, pos, cell) end)
  end

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

  defp maybe_reverse(list, :row), do: list
  defp maybe_reverse(list, :col), do: Enum.reverse(list)

  defp row_for(number) do
    (number / 15)
    |> Float.ceil()
    |> trunc()
  end

  defp col_for(number) when rem(number, 15) == 0, do: 15
  defp col_for(number), do: rem(number, 15)
end
