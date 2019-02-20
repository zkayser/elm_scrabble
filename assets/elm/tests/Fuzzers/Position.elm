module Fuzzers.Position exposing (..)

import Data.Position exposing (Position)
import Fuzz exposing (..)

fuzzer : Fuzzer Position
fuzzer =
  Fuzz.tuple ( Fuzz.int, Fuzz.int )