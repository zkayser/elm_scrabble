defmodule Scrabble.Cell do
  @type t :: %__MODULE__{
          tile: Scrabble.Tile.t(),
          position: Scrabble.Position.t(),
          multiplier: Scrabble.Multiplier.t()
        }

  defstruct tile: :empty,
            position: %{x: 0, y: 0},
            multiplier: :no_multiplier
end
