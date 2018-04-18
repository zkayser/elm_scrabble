defmodule Scrabble.Board.Validator do
  alias Scrabble.Board.Impl, as: Board
  alias Scrabble.{Grid, Tile, Cell, Position, Moves}
  @no_center_tile "You must play a tile on the center piece."
  @invalid_dimension "You must play along a single row or column."
  @gaps "It looks like you have a gap between your tiles."

  @type t() :: %__MODULE__{
          invalidated?: boolean(),
          subgrid: %{},
          dimension: :row | :col,
          dimension_number: pos_integer(),
          selection: [Position.t()],
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

  @spec validate(Board.t()) :: Board.t()
  def validate(%Board{grid: grid, moves: moves} = board) do
    with true <- Grid.is_center_played?(grid),
         {dimension, number} <- Moves.validate(moves),
         %{invalidated?: false, selection: selection, validated_play: play} <-
           validate(board, dimension, number),
         secondary_plays when is_list(secondary_plays) <-
           validate_secondary(Position.opposite_of(dimension), moves, grid) do
      %Board{
        board
        | grid: Grid.update_subgrid(board.grid, selection),
          validity: {:valid, [play | secondary_plays]}
      }
    else
      failure ->
        invalidate_with_message(board, failure)
    end
  end

  @spec validate(Board.t(), dimension, pos_integer()) :: t()
  def validate(%{moves: moves, grid: grid}, dimension, number) do
    Grid.get(grid, {dimension, number})
    |> set_subgrid(dimension)
    |> set_dimension_number(number)
    |> set_lower_bound(moves)
    |> set_upper_bound(Enum.reverse(moves))
    |> set_selection()
    |> is_selection_valid?(moves)
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

    lower = get_adjacent_tiles(subgrid, move, perpendicular, dimension, :lower)

    higher = get_adjacent_tiles(subgrid, move, perpendicular, dimension, :upper)

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

  # This has some mistaken assumptions and can probably be removed
  defp set_lower_bound(validator, []), do: %__MODULE__{validator | invalidated?: true}

  defp set_lower_bound(%__MODULE__{subgrid: subgrid, dimension: dimension} = validator, moves) do
    perpendicular = Position.opposite_of(dimension)
    lowest_move = Enum.min_by(moves, fn move -> move[perpendicular] end)

    lower =
      get_adjacent_tiles(subgrid, lowest_move, perpendicular, perpendicular, :lower)
      |> case do
        [] ->
          lowest_move[perpendicular]

        lower_adjacents ->
          {position, _} = List.last(lower_adjacents)
          position[perpendicular]
      end

    %__MODULE__{validator | lower_bound: lower}
  end

  # This has some mistaken assumptions and can probably be removed
  defp set_upper_bound(validator, []), do: %__MODULE__{validator | invalidated?: true}

  defp set_upper_bound(%__MODULE__{subgrid: subgrid, dimension: dimension} = validator, moves) do
    perpendicular = Position.opposite_of(dimension)
    highest_move = Enum.max_by(moves, fn move -> move[perpendicular] end)

    upper =
      get_adjacent_tiles(subgrid, highest_move, perpendicular, perpendicular, :upper)
      |> case do
        [] ->
          highest_move[perpendicular]

        higher_adjacents ->
          {position, _} = List.last(higher_adjacents)
          position[perpendicular]
      end

    %__MODULE__{validator | upper_bound: upper}
  end

  defp is_selection_valid?(%__MODULE__{invalidated?: true} = validator, _), do: validator

  defp is_selection_valid?(%__MODULE__{selection: selection} = validator, moves) do
    case Enum.all?(moves, &(&1 in selection)) &&
           Enum.all?(selection, fn pos -> validator.subgrid[pos].tile != :empty end) do
      true -> validator
      false -> %__MODULE__{invalidated?: true, message: @gaps}
    end
  end

  defp set_selection(%__MODULE__{invalidated?: true} = validator), do: validator

  defp set_selection(%__MODULE__{} = validator) do
    selection =
      for x <- validator.lower_bound..validator.upper_bound do
        case validator.dimension do
          :row -> Position.make(validator.dimension_number, x)
          :col -> Position.make(x, validator.dimension_number)
        end
      end

    %__MODULE__{validator | selection: selection}
  end

  defp set_validated_play(%__MODULE__{invalidated?: true} = validator), do: validator

  defp set_validated_play(%__MODULE__{} = validator) do
    %{dimension: dim, dimension_number: number, lower_bound: lb, upper_bound: ub} = validator
    %__MODULE__{validator | validated_play: {dim, number, lb..ub}}
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

  # I'm probable trying to get too clever for my own good here.
  # This sets the operators to used in sorting and filtering (should be opposites)
  # based on the upper_or_lower param, which can be only :upper or :lower
  defp get_adjacent_tiles(subgrid, move, filter_dim, sort_dim, upper_or_lower) do
    {filter_op, sort_op} = if upper_or_lower == :upper, do: {:>, :<}, else: {:<, :>}

    Enum.filter(subgrid, &filter_func(&1).(move, filter_dim, filter_op))
    |> Enum.sort(&sort_func(&1, &2).(sort_dim, sort_op))
    |> Enum.take_while(&cell_not_empty(&1))
  end

  defp filter_func({_, cell}) do
    fn position, dimension, operator ->
      apply(Kernel, operator, [cell.position[dimension], position[dimension]])
    end
  end

  defp sort_func({position1, _}, {position2, _}) do
    fn dimension, operator ->
      apply(Kernel, operator, [position1[dimension], position2[dimension]])
    end
  end

  defp cell_not_empty({_, cell}), do: cell.tile != :empty

  defp invalidate_with_message(board, false) do
    %Board{board | validity: {:invalid, @no_center_tile}, invalid_at: [Position.make(8, 8)]}
  end

  defp invalidate_with_message(board, :invalid) do
    %Board{board | validity: {:invalid, @invalid_dimension}}
  end

  defp invalidate_with_message(board, %{invalidated?: true, message: message, invalid_at: invalid}) do
    %Board{board | validity: {:invalid, message}, invalid_at: invalid}
  end
end
