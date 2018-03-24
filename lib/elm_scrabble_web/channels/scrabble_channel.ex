defmodule ElmScrabbleWeb.ScrabbleChannel do
	require Logger
	use Phoenix.Channel

	def join("scrabble:lobby", %{"user" => user}, socket) do
		Logger.debug "Hello! You are about to join the scrabble lobby. message: #{inspect user}"
		Leaderboard.put(user)
		socket = assign(socket, :user, user)
		{:ok, socket}
	end
	def join(channel, _, socket) do
		{:error, %{reason: "Channel #{channel} does not exist"}}
	end

	def handle_in("submit_play", %{"plays" => _} = plays, socket) do
		case Scrabble.score(plays) do
			{:error, reason} when is_binary(reason) ->
				push(socket, "score_update", %{error: reason})
				{:noreply, socket}
			{:error, _} ->
				push(socket, "score_update", %{error: "An error occurred. We are looking into it."})
				{:noreply, socket}
			{:ok, score_increment} ->
				Leaderboard.update(socket.assigns[:user], score_increment)
				push(socket, "score_update", %{score: score_increment})
				broadcast!(socket, "update", %{leaderboard: Leaderboard.top_scorers()})
				{:noreply, socket}
		end
	end
end