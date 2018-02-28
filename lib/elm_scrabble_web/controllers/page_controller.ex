defmodule ElmScrabbleWeb.PageController do
  use ElmScrabbleWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
