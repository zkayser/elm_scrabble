module Data.Cell exposing (Cell)

import Data.Multiplier exposing (Multiplier)
import Data.Position exposing (Position)
import Data.Tile exposing (Tile)


type alias Cell =
    { position : Position
    , multiplier : Multiplier
    , tile : Maybe Tile
    , isCenter : Bool
    }
