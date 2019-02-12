defmodule ElmScrabbleWeb.BoardView do
  alias Scrabble.Board.Impl, as: Board
  use ElmScrabbleWeb, :view

  def render("board", %Board{} = board) do
    board
  end
end
