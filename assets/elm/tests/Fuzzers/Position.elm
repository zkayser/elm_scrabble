module Fuzzers.Position exposing (fuzzer)

import Data.Position exposing (Position)
import Fuzz exposing (..)
import Json.Encode as Encode exposing (Value)
import Random


fuzzer : Fuzzer Position
fuzzer =
    Fuzz.tuple ( Fuzz.int, Fuzz.int )