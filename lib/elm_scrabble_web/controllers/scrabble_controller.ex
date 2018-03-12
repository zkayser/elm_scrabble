defmodule ElmScrabbleWeb.ScrabbleController do
	use ElmScrabbleWeb, :controller
	@error_message "Your request has been invalidated due to tampering"

	def score(conn, %{"word" => word, "multipliers" => multipliers}) do
		case MultiplierParser.parse(multipliers) do
			{:ok, multipliers} ->
				conn
				|> assign(:score, Scrabble.score(%{"word" => word, "multipliers" => multipliers}))
				|> put_status(:ok)
				|> render(ElmScrabbleWeb.ScrabbleView, "success.json")
			{:error, _} ->
				conn
				|> put_status(:ok)
				|> render(ElmScrabbleWeb.ScrabbleView, "error.json", %{status: "error", message: @error_message})
		end
	end

	def score(conn, _params) do
		conn
		|> put_status(:bad_request)
		|> render(ElmScrabbleWeb.ErrorView, "400.json", %{error: "Bad request"})
	end
end