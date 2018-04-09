defmodule Scrabble.TileManager do
  alias Scrabble.Tile

  @type tile_bag :: [Scrabble.Tile.t()]
  @type tiles_in_play :: [Scrabble.Tile.t()]
  @type tile_state :: {tiles_in_play, tile_bag}
  @frequency_list [
    {12, ~w(E)},
    {9, ~w(A I)},
    {8, ~w(O)},
    {6, ~w(N R T)},
    {4, ~w(L S U D)},
    {3, ~w(G)},
    {2, ~w(B C M P F H V W Y) ++ [""]},
    {1, ~w(K J X Q Z)}
  ]
  @initial_tile_count 7

  @spec generate() :: tile_state()
  def generate do
    Enum.reduce(@frequency_list, [], &expand_letters/2)
    |> Enum.with_index()
    |> Enum.map(&Tile.create/1)
    |> Enum.shuffle()
    |> Enum.split(@initial_tile_count)
  end

  # Add the number of letters into the accumulator,
  # which is a list of one-letter strings.
  defp expand_letters({num, letters}, acc) do
    acc ++ Enum.flat_map(letters, &repeat_letter(&1, num))
  end

  defp repeat_letter(letter, times) do
    for _ <- 1..times, do: letter
  end
end
