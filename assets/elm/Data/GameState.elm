module Data.GameState exposing (init, GameState)

import Data.Board as Board exposing (Board)

type alias GameState =
  { board : Board
  , score : Int
  }

init : GameState
init =
  { board = Board.init
  , score = 0
  }