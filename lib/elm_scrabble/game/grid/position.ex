defmodule Scrabble.Position do
  @type t :: %__MODULE__{
          row: pos_integer(),
          col: pos_integer()
        }

  defstruct row: 1,
            col: 1

  @behaviour Access

  @doc """
  A convenience function for creating position
  structs
  """
  @spec make(pos_integer(), pos_integer()) :: t()
  def make(row, col) when is_integer(row) and is_integer(col) and row > 0 and col > 0 do
    %__MODULE__{row: row, col: col}
  end

  def make(_, _) do
    raise ArgumentError, message: "Positions must have positive, integer values for row and col"
  end

  # Access callbacks
  def fetch(term, :col) do
    {:ok, term.col}
  end

  def fetch(term, :row) do
    {:ok, term.row}
  end

  def get(term, :col, _) do
    fetch(term, :col)
  end

  def get(term, :row, _) do
    fetch(term, :row)
  end

  def get_and_update(position, _, _), do: position
  def pop(position, _), do: position
end
