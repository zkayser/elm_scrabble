defmodule ElmScrabbleWeb.ScrabbleView do
	use ElmScrabbleWeb, :view

	def render("error.json", %{conn: %{assigns: assigns}}) do
		%{status: assigns.status, message: assigns.message}
	end
	def render("success.json", %{conn: %{assigns: assigns}}) do
		%{score: assigns.score}
	end

end