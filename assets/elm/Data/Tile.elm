module Data.Tile exposing (Tile)

import Data.Multiplier exposing (Multiplier(..))


type alias Tile =
    { letter : String
    , id : Int
    , value : Int
    , multiplier : Multiplier
    }
