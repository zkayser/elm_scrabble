defmodule ElmScrabbleWeb.ScrabbleControllerTest do
	use ElmScrabbleWeb.ConnCase

	test "POST /scrabble with bad params", %{conn: conn} do
		conn = post(conn, "/scrabble", %{"args" => "blah"})
		assert json_response(conn, 400)
	end

	test "POST /scrabble with invalid multipliers", %{conn: conn} do
		conn = post(conn, "/scrabble", %{"word" => "street", "multipliers" => [%{"DoubleWord" => ["a"]}]})
		assert json_response(conn, 200)
		assert conn.resp_body =~ ~r(Your request has been invalidated due to tampering)
	end

	test "POST /scrabble with valid request", %{conn: conn} do
		conn = post(conn, "/scrabble", %{"word" => "street", "multipliers" => []})
		assert json_response(conn, 200)
		assert conn.resp_body == "{\"score\":6}"
	end
end