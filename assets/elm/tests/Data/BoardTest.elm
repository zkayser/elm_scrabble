module Data.BoardTest exposing (suite)

import Data.Board as Board
import Expect
import Fuzzers.Board as BoardFuzzer
import Helpers.Serialization as Serialization
import Test exposing (..)


suite : Test
suite =
    describe "Board"
        [ fuzz BoardFuzzer.fuzzer "encoding and decoding a board should result in the same value" <|
            \board ->
                Serialization.expectReversibleDecoder Board.decode Board.encode board
        ]
