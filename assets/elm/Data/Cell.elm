module Data.Cell exposing (Cell)

import Data.Grid exposing (Position, Tile)
import Data.Multiplier exposing (Multiplier)

type alias Cell =
    { position : Position
    , multiplier : Multiplier
    , tile : Tile
    , isCenter : Bool
    }