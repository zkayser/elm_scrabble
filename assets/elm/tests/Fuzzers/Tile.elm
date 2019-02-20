module Fuzzers.Tile exposing (fuzzer)

import Data.Tile as Tile exposing (Tile)
import Fuzz exposing (..)
import Fuzzers.Multiplier as Multiplier


fuzzer : Fuzzer Tile
fuzzer =
    Fuzz.map4 Tile
        Fuzz.string
        Fuzz.int
        (Fuzz.intRange 0 600)
        Multiplier.fuzzer
