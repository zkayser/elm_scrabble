module Fuzzers.Cell exposing (fuzzer)

import Data.Cell exposing (Cell)
import Fuzz exposing (..)
import Fuzzers.Multiplier as Multiplier
import Fuzzers.Position as Position
import Fuzzers.Tile as Tile


fuzzer : Fuzzer Cell
fuzzer =
    Fuzz.map4 Cell
        Position.fuzzer
        Multiplier.fuzzer
        (Fuzz.maybe Tile.fuzzer)
        Fuzz.bool
