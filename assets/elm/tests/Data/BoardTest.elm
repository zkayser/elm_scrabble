module Data.BoardTest exposing (suite)

import Data.Board as Board exposing (Msg(..))
import Data.Grid as Grid
import Expect
import Fuzzers.Board as BoardFuzzer
import Helpers.Serialization as Serialization
import Json.Decode as Decode
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
        , describe "update"
            [ describe "UpdateTileState"
                [ fuzz2 BoardFuzzer.fuzzer BoardFuzzer.tileStateJsonFuzzer "replaces the boards tileState with incoming valid json" <|
                    \board ( json, tileState ) ->
                        Board.update board (UpdateTileState json)
                            |> Expect.all
                                [ \( newBoard, _ ) -> Expect.equal tileState newBoard.tileState
                                , \( _, msg ) -> Expect.equal NoOp msg
                                ]
                ]
            ]
        ]
