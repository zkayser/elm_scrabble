defmodule Scrabble.Multiplier do
  alias Scrabble.Position

  @type t ::
          :no_multiplier
          | :triple_word
          | :double_word
          | :triple_letter
          | :double_letter
          | :wildcard

  @spec multiplier_for(Position.t()) :: __MODULE__.t()
  def multiplier_for(%Position{row: 1, col: col}) when col in [1, 8, 15], do: :triple_word
  def multiplier_for(%Position{row: 8, col: col}) when col in [1, 15], do: :triple_word
  def multiplier_for(%Position{row: 15, col: col}) when col in [1, 8, 15], do: :triple_word

  def multiplier_for(%Position{row: row, col: col}) when row in 2..5 and row == col,
    do: :double_word

  def multiplier_for(%Position{row: row, col: col}) when row in 11..14 and row == col,
    do: :double_word

  def multiplier_for(%Position{row: 8, col: 8}), do: :double_word
  def multiplier_for(%Position{row: 2, col: 14}), do: :double_word
  def multiplier_for(%Position{row: 3, col: 13}), do: :double_word
  def multiplier_for(%Position{row: 4, col: 12}), do: :double_word
  def multiplier_for(%Position{row: 5, col: 11}), do: :double_word
  def multiplier_for(%Position{row: 11, col: 5}), do: :double_word
  def multiplier_for(%Position{row: 12, col: 4}), do: :double_word
  def multiplier_for(%Position{row: 13, col: 3}), do: :double_word
  def multiplier_for(%Position{row: 14, col: 2}), do: :double_word
  def multiplier_for(%Position{row: row, col: 6}) when row in [2, 6, 10, 14], do: :triple_letter
  def multiplier_for(%Position{row: row, col: 10}) when row in [2, 6, 10, 14], do: :triple_letter
  def multiplier_for(%Position{row: row, col: 2}) when row in [6, 10], do: :triple_letter
  def multiplier_for(%Position{row: row, col: 14}) when row in [6, 10], do: :triple_letter
  def multiplier_for(%Position{row: 1, col: col}) when col in [4, 12], do: :double_letter
  def multiplier_for(%Position{row: 3, col: col}) when col in [7, 9], do: :double_letter
  def multiplier_for(%Position{row: 4, col: col}) when col in [1, 8, 15], do: :double_letter
  def multiplier_for(%Position{row: 7, col: col}) when col in [3, 7, 9, 13], do: :double_letter
  def multiplier_for(%Position{row: 8, col: col}) when col in [4, 12], do: :double_letter
  def multiplier_for(%Position{row: 9, col: col}) when col in [3, 7, 9, 13], do: :double_letter
  def multiplier_for(%Position{row: 12, col: col}) when col in [1, 8, 15], do: :double_letter
  def multiplier_for(%Position{row: 13, col: col}) when col in [7, 9], do: :double_letter
  def multiplier_for(%Position{row: 15, col: col}) when col in [4, 12], do: :double_letter
  def multiplier_for(_), do: :no_multiplier
end
