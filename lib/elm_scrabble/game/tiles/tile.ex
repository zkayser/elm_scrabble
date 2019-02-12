defmodule Scrabble.Tile do
  @type t ::
          %__MODULE__{
            letter: String.t(),
            multiplier: Scrabble.Multiplier.t(),
            id: pos_integer(),
            value: pos_integer()
          }
          | :empty

  @derive Jason.Encoder

  defstruct letter: "",
            multiplier: :no_multiplier,
            id: 1,
            value: 1

  @spec create({String.t(), pos_integer()}) :: t()
  def create({"", id}), do: %__MODULE__{letter: "", multiplier: :wildcard, id: id, value: 0}

  def create({letter, id}) do
    %__MODULE__{letter: letter, multiplier: :no_multiplier, id: id, value: val_for(letter)}
  end

  defp val_for(letter) when letter in ~w(A E I L N O R S T U), do: 1
  defp val_for(letter) when letter in ~w(D G), do: 2
  defp val_for(letter) when letter in ~w(B C M P), do: 3
  defp val_for(letter) when letter in ~w(F H V W Y), do: 4
  defp val_for("K"), do: 5
  defp val_for(letter) when letter in ~w(J X), do: 8
  defp val_for(_), do: 10
end
