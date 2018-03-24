defmodule ElmScrabbleWeb.ScrabbleView do
	use ElmScrabbleWeb, :view

	def render("error.json", %{conn: %{assigns: assigns}}) do
		%{status: assigns.status, message: assigns.message}
	end
	def render("success.json", %{conn: %{assigns: %{score: {:error, message}}}}) do
		%{error: message}
	end
	def render("success.json", %{conn: %{assigns: assigns}}) do
		{:ok, score} = assigns.score
		%{score: score}
	end

end