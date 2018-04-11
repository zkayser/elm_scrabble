defmodule Scrabble.Board.Impl do
  alias Scrabble.Grid
  alias Scrabble.Tile
  alias Scrabble.TileManager

  @type t :: %__MODULE__{
          grid: Grid.t(),
          tilebag: [Scrabble.Tile.t()],
          current_tiles: [Scrabble.Tile.t()],
          played: [Scrabble.Tile.t()],
          validity: validity()
        }
  @type validity :: :valid | :invalid

  defstruct grid: [],
            tilebag: [],
            current_tiles: [],
            played: [],
            validity: :invalid

  @spec new() :: t()
  def new do
    {current, remainder} = TileManager.generate()

    %__MODULE__{
      grid: Grid.setup(),
      tilebag: remainder,
      current_tiles: current
    }
  end

  @spec play(t(), Tile.t(), {pos_integer(), pos_integer()}) :: t()
  def play(%__MODULE__{current_tiles: tiles, played: played} = board, tile, position) do
    with true <- tile in tiles && tile not in played do
      case Grid.place_tile(board.grid, tile, position) do
        {:ok, new_grid} ->
          process({board, [{:update_grid, new_grid}, {:tile_to_played, tile}]})

        {:error, _} ->
          board
      end
    else
      _ -> board
    end
  end

  def play(board, _, _), do: board

  defp process({board, updates}) when is_list(updates) do
    Enum.reduce(updates, board, &handle_update/2)
  end

  defp handle_update({:update_grid, new_grid}, board) do
    %__MODULE__{board | grid: new_grid}
  end

  defp handle_update({:tile_to_played, tile}, board) do
    board
    |> Map.put(:current_tiles, Enum.reject(board.current_tiles, &(&1 == tile)))
    |> Map.put(:played, [tile | board.played])
  end
end
