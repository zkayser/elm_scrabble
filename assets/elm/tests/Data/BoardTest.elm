module Data.BoardTest exposing (suite)

import Data.Board as Board
import Data.Grid as Grid
import Expect
import Fuzzers.Board as BoardFuzzer
import Helpers.Serialization as Serialization
import Phoenix.Push
import Task
import Test exposing (..)
import TestData exposing (tileA)


suite : Test
suite =
    describe "Board"
        [ fuzz BoardFuzzer.fuzzer "encoding and decoding a board should result in the same value" <|
            \board ->
                Serialization.expectReversibleDecoder Board.decode Board.encode board
        , describe "discardTiles"
            [ test "is a no-op on the board and returns a discard tiles push message" <|
                \_ ->
                    let
                        board =
                            { grid = Grid.init
                            , invalidAt = []
                            , moves = []
                            , tileState = { inPlay = [ tileA ], played = [] }
                            }
                    in
                    Board.discardTiles board
                        |> Expect.all
                            [ \( update, _ ) -> Expect.equal board update
                            , \( _, push ) -> Expect.equal "discard_tiles" push.event
                            ]
            ]
        ]
