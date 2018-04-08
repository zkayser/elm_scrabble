defmodule Scrabble.Tile do
  @type t ::
          %__MODULE__{
            letter: String.t(),
            multiplier: Scrabble.Multiplier.t(),
            id: pos_integer(),
            value: pos_integer()
          }
          | :empty

  defstruct letter: "",
            multiplier: :no_multiplier,
            id: 1,
            value: 1
end
