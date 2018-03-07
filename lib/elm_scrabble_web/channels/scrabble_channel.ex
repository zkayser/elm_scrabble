defmodule ElmScrabbleWeb.ScrabbleChannel do
	require Logger
	use Phoenix.Channel

	def join("scrabble:lobby", _message, socket) do
		Logger.debug "Hello! You are about to join the scrabble lobby. Good luck!"
		{:ok, socket}
	end
	def join(channel, _, socket) do
		{:error, %{reason: "Channel #{channel} does not exist"}}
	end


	# Maybe write some code here that does cool stuff
end