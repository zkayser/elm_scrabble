defmodule Scrabble.Board.Validator do
  alias Scrabble.Board.Impl, as: Board
  alias Scrabble.{Grid, Tile, Cell, Position}

  @type t() :: %__MODULE__{
          invalidated?: boolean(),
          subgrid: %{},
          dimension: :row | :col,
          selection: [{Position.t(), Cell.t()}],
          lower_bound: Position.t() | :undetermined,
          upper_bound: Position.t() | :undetermined,
          word: String.t() | :empty
        }
  @typep dimension :: :row | :col

  defstruct invalidated?: false,
            subgrid: %{},
            dimension: :row,
            selection: [],
            lower_bound: :undetermined,
            upper_bound: :undetermined,
            word: :empty

  @spec validate(Board.t(), dimension, pos_integer()) :: t()
  def validate(%{moves: moves, tile_state: tiles, grid: grid} = board, dimension, number) do
    Grid.get(grid, {dimension, number})
    |> set_subgrid(dimension)
    |> set_lower_bound(moves)
    |> set_upper_bound(moves)
    |> set_selection()
    |> invalidated?()
    |> set_word()
    |> update_tiles()
  end

  defp set_subgrid(subgrid, dimension) do
    %__MODULE__{subgrid: subgrid, dimension: dimension}
  end

  defp set_lower_bound(%__MODULE__{subgrid: subgrid, dimension: dimension} = validator, [
         position | _
       ]) do
    lower_bound =
      subgrid
      |> Enum.filter(fn {_, cell} ->
        cell.position[dimension] < position[dimension] && cell.tile != :empty
      end)
      |> Enum.sort(fn {position1, _}, {position2, _} ->
        position1[dimension] < position2[dimension]
      end)
      |> take_dimension_with_default(position)

    %__MODULE__{validator | lower_bound: lower_bound}
  end

  defp set_upper_bound(%__MODULE__{subgrid: subgrid, dimension: dimension} = validator, [
         position | _
       ]) do
    upper_bound =
      subgrid
      |> Enum.filter(fn {_, cell} ->
        cell.position[dimension] < position[dimension] && cell.tile != :empty
      end)
      |> Enum.sort(fn {position1, _}, {position2, _} ->
        position1[dimension] > position2[dimension]
      end)
      |> take_dimension_with_default(position)

    %__MODULE__{validator | upper_bound: upper_bound}
  end

  defp set_selection(%__MODULE__{subgrid: subgrid, dimension: dimension} = validator) do
    selection =
      subgrid
      |> Enum.filter(fn {pos, _} ->
        pos[dimension] >= validator.lower_bound && pos[dimension] <= validator.upper_bound
      end)

    %__MODULE__{validator | selection: selection}
  end

  defp invalidated?(%__MODULE__{selection: selection} = validator) do
    case Enum.all?(selection, fn {_, cell} -> cell.tile != :empty end) do
      true -> %__MODULE__{validator | invalidated?: false}
      false -> %__MODULE__{validator | invalidated?: true}
    end
  end

  defp set_word(%__MODULE__{invalidated?: true} = validator), do: validator

  defp set_word(%__MODULE__{selection: selection} = validator) do
    word =
      selection
      |> Enum.sort(fn {pos1, _}, {pos2, _} ->
        pos1[validator.dimension] < pos2[validator.dimension]
      end)
      |> Enum.map(fn {_, %Cell{tile: tile}} -> tile.letter end)

    %__MODULE__{validator | word: word}
  end

  defp update_tiles(%__MODULE__{invalidated?: true} = validator), do: validator

  defp update_tiles(%__MODULE__{subgrid: subgrid} = validator) do
    updated_subgrid =
      for {key, %Cell{tile: tile} = cell} <- subgrid, into: %{} do
        unless cell.tile.multiplier != :empty && cell.tile.multiplier != :wildcard do
          {key, %Cell{cell | tile: %Tile{tile | multiplier: cell.multiplier}}}
        else
          {key, cell}
        end
      end

    %__MODULE__{validator | subgrid: updated_subgrid}
  end

  defp take_dimension_with_default([], position), do: position
  defp take_dimension_with_default([position | _], _), do: position
end
