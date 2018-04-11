defmodule Scrabble.Board.Impl do
  alias Scrabble.Grid
  alias Scrabble.Tile
  alias Scrabble.TileManager

  @type t :: %__MODULE__{
          grid: Grid.t(),
          tile_state: TileManager.t(),
          validity: validity()
        }
  @type validity :: :valid | :invalid

  defstruct grid: Grid.setup(),
            tile_state: TileManager.new(),
            validity: :invalid

  @spec new() :: t()
  def new do
    %__MODULE__{}
  end

  @spec play(t(), Tile.t(), {pos_integer(), pos_integer()}) :: t()
  def play(%__MODULE__{tile_state: tiles} = board, tile, position) do
    with true <- tile in tiles.in_play && tile not in tiles.played do
      case Grid.place_tile(board.grid, tile, position) do
        {:ok, new_grid} ->
          update_state({board, [{:update_grid, new_grid}, {:tile_played, tile}]})

        {:error, _} ->
          board
      end
    else
      _ -> board
    end
  end

  def play(board, _, _), do: board

  defp update_state({board, updates}) when is_list(updates) do
    Enum.reduce(updates, board, &handle_update/2)
  end

  defp handle_update({:update_grid, new_grid}, board) do
    %__MODULE__{board | grid: new_grid}
  end

  defp handle_update({:tile_played, tile}, board) do
    %__MODULE__{board | tile_state: TileManager.handle_played(board.tile_state, tile)}
  end
end
