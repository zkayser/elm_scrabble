module Fuzzers.Cell exposing (fuzzer)

import Data.Cell exposing (Cell)
import Data.Multiplier exposing (Multiplier)
import Data.Position exposing (Position)
import Data.Tile exposing (Tile)
import Fuzz exposing (..)
import Fuzzers.Multiplier as Multiplier
import Fuzzers.Position as Position
import Fuzzers.Tile as Tile


fuzzer : Fuzzer Cell
fuzzer =
    Fuzz.map3 toCell
        Position.fuzzer
        Multiplier.fuzzer
        (Fuzz.maybe Tile.fuzzer)


toCell : Position -> Multiplier -> Maybe Tile -> Cell
toCell position multiplier maybeTile =
    Cell position multiplier maybeTile (position == ( 8, 8 ))
