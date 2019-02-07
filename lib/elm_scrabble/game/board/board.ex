defmodule Scrabble.Board do
  alias Scrabble.Board.{Server, Supervisor}

  @pid &Supervisor.via_tuple_for/1

  def new(name) do
    GenServer.start_link(Server, %{}, name: @pid.(name))
  end

  def stop(name) do
    Supervisor.stop_board(name)
  end

  def play(board, params) when is_list(params) do
    GenServer.call(@pid.(board), {:play, params})
  end

  def play(board, tile, {row, col}) when row < 16 and col < 16 and row > 0 and col > 0 do
    GenServer.call(@pid.(board), {:play, tile, {row, col}})
  end

  # A no-op that returns the same type as above
  def play(board, _, _), do: GenServer.call(@pid.(board), :state)

  def state(board), do: GenServer.call(@pid.(board), :state)
end
