defmodule ElmScrabbleWeb.ScrabbleController do
	use ElmScrabbleWeb, :controller

	def show(conn, %{"word" => word, "multipliers" => multipliers} = params) do
	end

	def show(conn, _) do
		conn
		|> put_status(:bad_request)
		|> render(ElmScrabbleWeb.ErrorView, "400.json", %{error: "Bad request"})
	end
end