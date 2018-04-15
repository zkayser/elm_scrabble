defmodule Scrabble.Board.Impl do
  alias Scrabble.{Grid, Tile, TileManager, Moves, Position}
  alias Scrabble.Board.Validator
  alias Scrabble.Board.ApiParams, as: Params

  @type t :: %__MODULE__{
          grid: Grid.t(),
          tile_state: TileManager.t(),
          moves: Moves.t(),
          validity: validity(),
          invalid_at: [Position.t()]
        }
  @type validity :: {:valid, String.t()} | {:invalid, message()}
  @type message :: String.t()

  defstruct grid: Grid.setup(),
            tile_state: TileManager.new(),
            moves: [],
            validity: {:invalid, "You haven't made any moves yet."},
            invalid_at: []

  @spec new() :: t()
  def new do
    %__MODULE__{tile_state: TileManager.new()}
  end

  @spec play(t(), [Params.t()]) :: t()
  def play(%__MODULE__{tile_state: tiles} = board, api_params) do
    converted = Enum.map(api_params, &Params.convert/1)

    case converted
         |> Enum.all?(fn {tile, _} -> tile in tiles.in_play && tile not in tiles.played end) do
      true ->
        Enum.reduce(converted, board, fn {tile, position}, board ->
          play(board, tile, position)
        end)

      false ->
        board
    end
  end

  @spec play(t(), Tile.t(), {pos_integer(), pos_integer()}) :: t()
  def play(%__MODULE__{tile_state: tiles} = board, tile, position) do
    with true <- tile in tiles.in_play && tile not in tiles.played do
      case Grid.place_tile(board.grid, tile, position) do
        {:ok, new_grid} ->
          update_state(
            {board, [{:update_grid, new_grid}, {:tile_played, tile}, {:add_move, position}]}
          )

        {:error, _} ->
          board
      end
    else
      _ -> board
    end
  end

  def play(board, _, _), do: board

  @spec validate(t()) :: t()
  def validate(%__MODULE__{moves: moves, grid: grid} = board) do
    if Grid.is_center_played?(grid) do
      with {dimension, number} <- Moves.validate(moves) do
        case Validator.validate(board, dimension, number) do
          %{invalidated?: true, message: message, invalid_at: invalid} ->
            %__MODULE__{board | validity: {:invalid, message}, invalid_at: invalid}

          %{selection: selection, word: word} ->
            %__MODULE__{
              board
              | grid: Grid.update_subgrid(board.grid, selection),
                validity: {:valid, word}
            }
        end
      else
        _ ->
          %__MODULE__{board | validity: :invalid}
      end
    else
      %__MODULE__{
        board
        | validity: {:invalid, "You must play a tile on the center piece."},
          invalid_at: [Position.make(8, 8)]
      }
    end
  end

  defp update_state({board, updates}) when is_list(updates) do
    Enum.reduce(updates, board, &handle_update/2)
  end

  defp handle_update({:update_grid, new_grid}, board) do
    %__MODULE__{board | grid: new_grid}
  end

  defp handle_update({:tile_played, tile}, board) do
    %__MODULE__{board | tile_state: TileManager.handle_played(board.tile_state, tile)}
  end

  defp handle_update({:add_move, {row, col}}, board) do
    %__MODULE__{board | moves: [Scrabble.Position.make(row, col) | board.moves]}
  end
end
