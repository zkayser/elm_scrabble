module Data.GameState exposing (GameState, init)

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
