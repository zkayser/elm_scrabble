module Data.Move exposing (..)

import Data.Grid as Grid exposing (Dimension(..), Position, Tile)


type alias Move =
    { tile : Tile
    , position : Position
    }
