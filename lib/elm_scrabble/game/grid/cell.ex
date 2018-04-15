defmodule Scrabble.Cell do
  @type t :: %__MODULE__{
          tile: Scrabble.Tile.t(),
          position: Scrabble.Position.t(),
          multiplier: Scrabble.Multiplier.t()
        }

  defstruct tile: :empty,
            position: %Scrabble.Position{row: 1, col: 1},
            multiplier: :no_multiplier
end
