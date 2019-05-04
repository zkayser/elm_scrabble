defmodule ElmScrabble.LeaderBoardServer do
  use GenServer

  def init do
    {:ok, %{scores: LeftistMaxHeap.empty(), players: %{}, max: 0}}
  end

  def handle_cast({:new_player, player}, state) do
    {:noreply,
     %{
       state
       | scores: LeftistMaxHeap.insert(0),
         players: %{state.players | player => 0}
     }}
  end

  def handle_call({:update_score, player, score_inc}, state) do
    new_score = state.players[player] + score_inc
    new_heap = LeftistMaxHeap.insert(new_score)

    new_state = %{
      state
      | scores: new_heap,
        players: %{state.players | player => new_score},
        max: LeftistMaxHeap.find_max(new_heap)
    }

    {:reply, new_state.max, new_state}
  end
end
