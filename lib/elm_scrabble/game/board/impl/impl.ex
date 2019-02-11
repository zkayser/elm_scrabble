defmodule Scrabble.Board.Impl do
  alias __MODULE__, as: Board
  alias Scrabble.{Grid, Tile, TileManager, Position}
  alias Scrabble.Board.{Moves, Validator}
  alias Scrabble.Board.ApiParams, as: Params

  @type t :: %Board{
          grid: Grid.t(),
          tile_state: TileManager.t(),
          moves: Moves.t(),
          validity: validity(),
          invalid_at: [Position.t()]
        }
  @type validity :: {:valid, String.t()} | {:invalid, message()} | :initial
  @type message :: String.t()

  defstruct grid: Grid.setup(),
            tile_state: TileManager.new(),
            moves: [],
            validity: :initial,
            invalid_at: []

  @spec new() :: t()
  def new do
    %Board{tile_state: TileManager.new()}
  end

  @spec play(t(), [Params.t()]) :: t()
  def play(%Board{tile_state: tiles} = board, api_params) do
    with converted <- Enum.map(api_params, &Params.convert/1),
         true <- Enum.all?(converted, &playable_tile?(&1).(tiles)) do
      Enum.reduce(converted, board, fn {tile, position}, board ->
        play(board, tile, position)
      end)
    else
      _ -> board
    end
  end

  @spec play(t(), Tile.t(), {pos_integer(), pos_integer()}) :: t()
  def play(%Board{tile_state: tiles} = board, tile, position) do
    with true <- playable_tile?(tile).(tiles),
         {:ok, new_grid} <- Grid.place_tile(board.grid, tile, position) do
      update_state(
        {board, [{:update_grid, new_grid}, {:tile_played, tile}, {:add_move, position}]}
      )
    else
      _ -> board
    end
  end

  @spec validate(t()) :: t()
  def validate(%Board{} = board) do
    Validator.validate(board)
  end

  defp update_state({board, updates}) when is_list(updates) do
    Enum.reduce(updates, board, &handle_update/2)
  end

  defp handle_update({:update_grid, new_grid}, board) do
    %Board{board | grid: new_grid}
  end

  defp handle_update({:tile_played, tile}, board) do
    %Board{board | tile_state: TileManager.handle_played(board.tile_state, tile)}
  end

  defp handle_update({:add_move, {row, col}}, board) do
    %Board{board | moves: [Scrabble.Position.make(row, col) | board.moves]}
  end

  defp playable_tile?({tile, _}) do
    fn tiles ->
      tile in tiles.in_play && tile not in tiles.played
    end
  end
  defp playable_tile?(tile) do
    fn tiles -> tile in tiles.in_play && tile not in tiles.played end
  end
end
