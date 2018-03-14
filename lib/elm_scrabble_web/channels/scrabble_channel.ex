defmodule ElmScrabbleWeb.ScrabbleChannel do
	require Logger
	use Phoenix.Channel

	def join("scrabble:lobby", %{"user" => user}, socket) do
		Logger.debug "Hello! You are about to join the scrabble lobby. message: #{inspect user}!"
		socket = assign(socket, :user, user)
		{:ok, socket}
	end
	def join(channel, _, socket) do
		{:error, %{reason: "Channel #{channel} does not exist"}}
	end

	def handle_in("submit_play", %{"word" => word, "multipliers" => multipliers}, socket) do
		case MultiplierParser.parse(multipliers) do
			{:ok, multipliers} ->
				handle_scoring(socket.assigns[:user], word, multipliers, socket)
			{:error, _} ->
				{:noreply, socket}
		end
	end

	defp handle_scoring(user, word, multipliers, socket) do
		case Scrabble.score(%{"word" => word, "multipliers" => multipliers}) do
			{:error, reason} when is_binary(reason) ->
				push(socket, "score_update", %{error: reason})
				{:noreply, socket}
			{:error, _} -> {:noreply, socket}
			increment ->
				Leaderboard.update(user, increment)
				push(socket, "score_update", %{score: increment})
				broadcast!(socket, "update", %{leaderboard: Leaderboard.top_scorers()})
				{:noreply, socket}
		end
	end
end