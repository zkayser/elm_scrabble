defimpl Jason.Encoder, for: Scrabble.Cell do
  alias Jason.Encode

  def encode(value, opts) do
    Encode.map(
      %{tile: value.tile,
        position: encode_position(value.position),
        multiplier: value.multiplier
      },
      opts
    )
  end

  def encode_position(position) do
    {:ok, json} = Jason.encode(position)
    json
  end
end

defimpl Jason.Encoder, for: Scrabble.Board.Impl do
  alias Jason.Encode
  alias Scrabble.Grid

  def encode(value, opts) do
    Encode.map(
      %{grid: encode_grid(value.grid),
        tile_state: encode_sub_struct(value.tile_state),
        moves: Encode.list(value.moves, opts),
        validity: encode_validity(value.validity),
        invalid_at: Encode.list(value.invalid_at, opts)
        },
        opts
    )
  end

  defp encode_grid(grid) do
    {:ok, grid} = Grid.encode(grid)
    grid
  end

  defp encode_sub_struct(sub_struct) do
    {:ok, encoded_sub_struct} = Jason.encode(sub_struct)
    encoded_sub_struct
  end

  defp encode_validity({:valid, _plays}), do: %{is_valid: true, message: nil}
  defp encode_validity({:invalid, message}), do: %{is_valid: false, message: message}
  defp encode_validity(:initial), do: %{is_valid: true, message: "Initial play"}
end

defimpl Jason.Encoder, for: Scrabble.TileManager do
  alias Jason.Encode
  def encode(value, opts) do
    Encode.map(%{
        in_play: encode_list(value.in_play, opts),
        tile_bag: encode_list(value.tile_bag, opts),
        played: encode_list(value.played, opts)
      }, opts)
  end

  defp encode_list(positions, _opts) do
    for position <- positions do
      {:ok, encoded_position} = Jason.encode(position)
      encoded_position
    end
  end
end