defimpl Jason.Encoder, for: Scrabble.Board.Impl do
  alias Jason.Encode
  alias Scrabble.{Grid, Tile}

  @spec encode(Scrabble.Board.Impl.t(), Encode.opts()) :: iodata()
  def encode(value, opts) do
    Encode.map(
      %{
        grid: Grid.encode(value.grid),
        tile_state: encode_tile_manager(value.tile_state),
        moves: encode_positions(value.moves),
        validity: encode_validity(value.validity),
        invalid_at: encode_positions(value.invalid_at)
      },
      opts
    )
  end

  defp encode_tile_manager(tile_manager) do
    %{
      in_play: encode_tiles(tile_manager.in_play),
      played: encode_tiles(tile_manager.played)
    }
  end

  defp encode_positions(positions) do
    Enum.reduce(positions, [], fn pos, acc -> [%{row: pos.row, col: pos.col} | acc] end)
  end

  defp encode_tiles(tiles) do
    Enum.reduce(tiles, [], fn tile, acc -> [Tile.encode(tile) | acc] end)
  end

  defp encode_validity({:valid, _plays}), do: %{is_valid: true, message: nil}
  defp encode_validity({:invalid, message}), do: %{is_valid: false, message: message}
  defp encode_validity(:initial), do: %{is_valid: true, message: "Initial play"}
end
