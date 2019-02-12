defmodule ElmScrabbleWeb.ScrabbleChannel do
  require Logger
  alias Scrabble.Leaderboard
  alias Scrabble.Board.Supervisor, as: BoardSupervisor
  alias Scrabble.Board
  use Phoenix.Channel

  def join("scrabble:lobby", %{"user" => user}, socket) do
    Leaderboard.put(user)
    {:ok, board_name} = BoardSupervisor.create_board(user)

    socket = assign(socket, :user, user)
    socket = assign(socket, :board_name, board_name)
    send(self(), :init)
    {:ok, socket}
  end

  def join(channel, _, _socket) do
    {:error, %{reason: "Channel #{channel} does not exist"}}
  end

  def handle_info(:init, socket) do
    push(socket, "board_init", %{board: Board.state(socket.assigns.board_name)})
    {:noreply, socket}
  end

  def handle_in("submit_play", %{"plays" => _} = plays, socket) do
    case Scrabble.score(plays) do
      {:errors, errors} ->
        for {:error, reason} <- errors do
          if is_binary(reason), do: push(socket, "score_update", %{error: reason})
        end

        {:noreply, socket}

      {:ok, score_increment} ->
        Leaderboard.update(socket.assigns[:user], score_increment)
        push(socket, "score_update", %{score: score_increment})
        broadcast!(socket, "update", %{leaderboard: Leaderboard.top_scorers()})
        {:noreply, socket}
    end
  end
end
