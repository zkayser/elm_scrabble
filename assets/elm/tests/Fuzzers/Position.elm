module Fuzzers.Position exposing (fuzzer, encodeFuzzer)

import Data.Position exposing (Position)
import Fuzz exposing (..)
import Json.Encode as Encode exposing (Value)
import Random


fuzzer : Fuzzer Position
fuzzer =
    Fuzz.tuple ( Fuzz.int, Fuzz.int )

encodeFuzzer : Fuzzer Value
encodeFuzzer =
  Fuzz.map2
    (\col row ->
      Encode.object
        [ col
        , row
        ]
    )
  rowEncoder
  colEncoder


rowEncoder : Fuzzer ( String, Value )
rowEncoder =
  Fuzz.tuple ( Fuzz.constant "row", Fuzz.map Encode.int <| Fuzz.intRange 0 Random.maxInt )

colEncoder : Fuzzer ( String, Value )
colEncoder =
  Fuzz.tuple ( Fuzz.constant "col", Fuzz.map Encode.int <| Fuzz.intRange 0 Random.maxInt )