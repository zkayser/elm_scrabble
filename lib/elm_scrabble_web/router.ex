defmodule ElmScrabbleWeb.Router do
  use ElmScrabbleWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ElmScrabbleWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/api", ElmScrabbleWeb do
    pipe_through(:api)

    post("/scrabble", ScrabbleController, :score)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElmScrabbleWeb do
  #   pipe_through :api
  # end
end
