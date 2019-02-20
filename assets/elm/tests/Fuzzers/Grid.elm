module Fuzzers.Grid exposing (fuzzer)

import Data.Cell exposing (Cell)
import Data.Grid as Grid exposing (Grid)
import Fuzz exposing (..)
import Fuzzers.Cell as Cell


fuzzer : Fuzzer Grid
fuzzer =
    Fuzz.map
        Grid.setup
        (Fuzz.list Cell.fuzzer)
