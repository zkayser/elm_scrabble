defmodule Scrabble.TestData do
  alias Scrabble.{Grid, Position, Tile}
  @type play :: %{word: String.t(), positions: [{pos_integer(), pos_integer()}]}

  def tiles(count \\ 7)

  def tiles(count) when is_integer(count) do
    Enum.reduce(?a..(?a + count), [], fn char, tiles ->
      case char > ?a || char < ?z do
        true -> [%Tile{letter: <<?a + rem(char, ?z)>>, id: :rand.uniform(3000)} | tiles]
        false -> [%Tile{letter: <<char>>, id: :rand.uniform(3000)} | tiles]
      end
    end)
    |> Enum.reverse()
  end

  def tiles(word) when is_binary(word) do
    String.codepoints(word)
    |> Enum.reduce([], fn letter, tiles ->
      [%Tile{letter: letter, id: :rand.uniform(3000)} | tiles]
    end)
    |> Enum.reverse()
  end

  def positions(positions) when is_list(positions) do
    Enum.reduce(positions, [], fn {row, col}, acc -> [Position.make(row, col) | acc] end)
  end

  def positions({row, col}), do: Position.make(row, col)

  @spec setup_grid_with([play]) :: Grid.t()
  def setup_grid_with(plays) when is_list(plays) do
    Enum.reduce(plays, Grid.setup(), fn play, grid -> handle_play(play, grid) end)
  end

  def setup_grid_with(%{word: _, positions: _} = play) do
    handle_play(play, Grid.setup())
  end

  def handle_play(%{word: word, positions: positions}, grid) do
    {:ok, grid} = Grid.place_tiles(grid, Enum.zip(tiles(word), positions))
    grid
  end

  def generate_board_id, do: "Board_#{Base.encode16(:crypto.strong_rand_bytes(8))}"
end
