defmodule Scrabble.Board.Server do
  use GenServer
  alias Scrabble.Board.Impl, as: Board

  def init(_) do
    {:ok, Board.new()}
  end

  def handle_call(:state, _, board), do: {:reply, board, board}

  def handle_call({:play, tile, {row, col} = position}, _from, board) do
    update = Board.play(board, tile, position)
    {:reply, update, update}
  end
end
