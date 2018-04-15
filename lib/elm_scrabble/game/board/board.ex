defmodule Scrabble.Board do
  alias Scrabble.Board.Server

  def new() do
    {:ok, pid} = GenServer.start_link(Server, %{})
    board = GenServer.call(pid, :state)
    {board, pid}
  end

  def play(board, params) when is_list(params) do
    GenServer.call(board, {:play, params})
  end

  def play(board, tile, {row, col}) when row < 16 and col < 16 and row > 0 and col > 0 do
    GenServer.call(board, {:play, tile, {row, col}})
  end

  # A no-op that returns the same type as above
  def play(board, _, _), do: GenServer.call(board, :state)
end
