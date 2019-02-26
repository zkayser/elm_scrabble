module Fuzzers.Board exposing (fuzzer, tileStateFuzzer, tileStateJsonFuzzer)

import Data.Board as Board exposing (Board)
import Data.Tile exposing (Tile)
import Fuzz exposing (Fuzzer)
import Fuzzers.Grid as Grid
import Fuzzers.Position as Position
import Fuzzers.Tile as Tile
import Json.Encode as Encode exposing (Value)


fuzzer : Fuzzer Board
fuzzer =
    Fuzz.map4 Board
        Grid.fuzzer
        (Fuzz.list Position.fuzzer)
        (Fuzz.list Position.fuzzer)
        tileStateFuzzer


tileStateFuzzer : Fuzzer { inPlay : List Tile, played : List Tile }
tileStateFuzzer =
    Fuzz.map2 (\inPlay played -> { inPlay = inPlay, played = played })
        (Fuzz.list Tile.fuzzer)
        (Fuzz.list Tile.fuzzer)


tileStateJsonFuzzer : Fuzzer ( Value, { inPlay : List Tile, played : List Tile } )
tileStateJsonFuzzer =
    Fuzz.map (\tileState -> ( Board.tileStateEncoder tileState, tileState )) tileStateFuzzer
