defimpl Jason.Encoder, for: Scrabble.Cell do
  alias Jason.Encode

  def encode(value, opts) do
    Encode.map(
      %{tile: value.tile,
        position: encode_position(value.position, opts),
        multiplier: value.multiplier
      },
      opts
    )
  end

  def encode_position(position, opts) do
    {:ok, json} = Jason.encode(position)
    json
  end
end