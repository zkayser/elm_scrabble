defmodule Scrabble.Position do
  @type t :: %__MODULE__{
          row: pos_integer(),
          col: pos_integer()
        }

  defstruct row: 1,
            col: 1
end
