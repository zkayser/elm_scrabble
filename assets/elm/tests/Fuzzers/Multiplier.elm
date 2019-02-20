module Fuzzers.Multiplier exposing (..)

import Data.Multiplier exposing (Multiplier(..))
import Fuzz exposing (..)

fuzzer : Fuzzer Multiplier
fuzzer =
  Fuzz.frequency
    [ ( 50, Fuzz.constant NoMultiplier )
    , ( 25, Fuzz.constant DoubleLetter )
    , ( 15, Fuzz.constant TripleLetter )
    , ( 7, Fuzz.constant DoubleWord )
    , ( 3, Fuzz.constant TripleWord )
    ]