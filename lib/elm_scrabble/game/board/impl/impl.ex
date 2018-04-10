defmodule Scrabble.Board.Impl do
  alias Scrabble.Grid
  alias Scrabble.TileManager

  @type t :: %__MODULE__{
          grid: Grid.t(),
          tilebag: [Scrabble.Tile.t()],
          current_tiles: [Scrabble.Tile.t()],
          validity: validity()
        }
  @type validity :: :valid | :invalid

  defstruct grid: [],
            tilebag: [],
            current_tiles: [],
            validity: :invalid

  def new do
    {current, remainder} = TileManager.generate()

    %__MODULE__{
      grid: Grid.setup(),
      tilebag: remainder,
      current_tiles: current
    }
  end
end
