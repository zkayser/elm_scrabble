defmodule Scrabble.Board.Validator do
  alias Scrabble.Board.Impl, as: Board
  alias Scrabble.{Grid, Tile, Cell, Position}

  @type t() :: %__MODULE__{
          invalidated?: boolean(),
          subgrid: %{},
          dimension: :row | :col,
          dimension_number: pos_integer(),
          selection: [{Position.t(), Cell.t()}],
          lower_bound: Position.t() | :undetermined,
          upper_bound: Position.t() | :undetermined,
          validated_play: [validated_play()] | :none,
          message: String.t(),
          invalid_at: [Position.t()]
        }
  @typep dimension :: :row | :col
  @typep validated_play :: {dimension, pos_integer(), Range.t()}

  defstruct invalidated?: false,
            subgrid: %{},
            dimension: :row,
            dimension_number: 0,
            selection: [],
            lower_bound: :undetermined,
            upper_bound: :undetermined,
            validated_play: :none,
            message: "",
            invalid_at: []

  @spec validate(Board.t(), dimension, pos_integer()) :: t()
  def validate(%{moves: moves, grid: grid}, dimension, number) do
    Grid.get(grid, {dimension, number})
    |> set_subgrid(dimension)
    |> set_dimension_number(number)
    |> set_lower_bound(moves)
    |> set_upper_bound(Enum.reverse(moves))
    |> set_selection()
    |> invalidated?()
    |> set_validated_play()
    |> update_selection()
  end

  @spec validate_secondary(dimension, [Position.t()], Grid.t()) :: [validated_play]
  def validate_secondary(_, [], _), do: []

  def validate_secondary(dimension, moves, grid) do
    Enum.reduce(moves, [], fn move, acc -> [handle_secondary(dimension, move, grid) | acc] end)
    |> List.flatten()
  end

  defp handle_secondary(dimension, move, grid) do
    subgrid = Grid.get(grid, {dimension, move[dimension]})
    perpendicular = Position.opposite_of(dimension)
    # Enum.drop(1) calls remove the current element from the list.
    # Secondary moves are not valid if they are not connected to
    # adjacent tiles, so removing the current move from both
    # lower and higher lists allows you to look at size to
    # see if there are any adjacent tiles in either direction.

    lower =
      Enum.filter(subgrid, &filter_func(&1).(move, perpendicular, :lower))
      |> Enum.sort(&sort_func(&1, &2).(dimension, :greater))
      |> Enum.take_while(fn {_, cell} -> cell.tile != :empty end)

    higher =
      Enum.filter(subgrid, &filter_func(&1).(move, perpendicular, :upper))
      |> Enum.sort(&sort_func(&1, &2).(dimension, :less_than))
      |> Enum.take_while(fn {_, cell} -> cell.tile != :empty end)

    case {length(lower) > 0, length(higher) > 0} do
      {true, true} ->
        {lower_position, _} = List.last(lower)
        {upper_position, _} = List.last(higher)

        {dimension, move[dimension], lower_position[perpendicular]..upper_position[perpendicular]}

      {true, false} ->
        {lower_position, _} = List.last(lower)
        {dimension, move[dimension], lower_position[perpendicular]..move[perpendicular]}

      {false, true} ->
        {upper_position, _} = List.last(higher)
        {dimension, move[dimension], move[perpendicular]..upper_position[perpendicular]}

      _ ->
        []
    end
  end

  defp set_subgrid(subgrid, dimension) do
    %__MODULE__{subgrid: subgrid, dimension: dimension}
  end

  defp set_dimension_number(validator, number),
    do: %__MODULE__{validator | dimension_number: number}

  defp set_lower_bound(%__MODULE__{subgrid: subgrid, dimension: dimension} = validator, [
         position | _
       ]) do
    dimension = Position.opposite_of(dimension)

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
    dimension = Position.opposite_of(dimension)

    upper_bound =
      subgrid
      |> Enum.filter(fn {_, cell} ->
        cell.position[dimension] > position[dimension] && cell.tile != :empty
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
        dim = Position.opposite_of(dimension)
        pos[dim] >= validator.lower_bound[dim] && pos[dim] <= validator.upper_bound[dim]
      end)

    %__MODULE__{validator | selection: selection}
  end

  defp invalidated?(%__MODULE__{selection: selection} = validator) do
    case Enum.all?(selection, fn {_, cell} -> cell.tile != :empty end) do
      true ->
        %__MODULE__{validator | invalidated?: false}

      false ->
        invalid_positions =
          Enum.filter(selection, fn {_, cell} -> cell.tile == :empty end)
          |> Enum.map(fn {pos, _} -> pos end)

        %__MODULE__{
          validator
          | invalidated?: true,
            message: "Invalid move.",
            invalid_at: invalid_positions
        }
    end
  end

  defp set_validated_play(%__MODULE__{invalidated?: true} = validator), do: validator

  defp set_validated_play(%__MODULE__{} = validator) do
    %{dimension: dim, dimension_number: number, lower_bound: lb, upper_bound: ub} = validator
    range = lb[Position.opposite_of(dim)]..ub[Position.opposite_of(dim)]
    %__MODULE__{validator | validated_play: {dim, number, range}}
  end

  # update_selection/1 transfers cell multipliers to tile structs unless the
  # tile struct already has a :wildcard multiplier value
  defp update_selection(%__MODULE__{invalidated?: true} = validator), do: validator

  defp update_selection(%__MODULE__{selection: selection} = validator) do
    updated_selection =
      for {key, %Cell{tile: tile} = cell} <- selection, into: %{} do
        unless tile == :empty do
          multiplier = if tile.multiplier == :wildcard, do: :wilcard, else: cell.multiplier
          {key, %Cell{cell | tile: %Tile{tile | multiplier: multiplier}}}
        else
          {key, cell}
        end
      end

    %__MODULE__{validator | selection: updated_selection}
  end

  defp take_dimension_with_default([], position), do: position
  defp take_dimension_with_default([{position, _} | _], _), do: position

  defp filter_func({_, cell}) do
    fn position, dimension, bound ->
      case bound do
        :lower -> cell.position[dimension] < position[dimension]
        :upper -> cell.position[dimension] > position[dimension]
      end
    end
  end

  defp sort_func({position1, _}, {position2, _}) do
    fn dimension, bound ->
      case bound do
        :less_than -> position1[dimension] < position2[dimension]
        :greater -> position1[dimension] > position2[dimension]
      end
    end
  end
end
