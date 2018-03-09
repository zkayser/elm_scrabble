module Logic.Validator exposing (..)

import Data.Grid exposing (Tile)


type ValidatorState
    = NoMoveDetected
    | PossibleMoveFound (List Tile)
    | MoveDetected (List Tile)
    | Validated String
    | Invalid
