module MoveTest exposing (suite)

import Data.Grid as Grid exposing (Dimension(..))
import Data.Move as Move
import Data.Multiplier as Multiplier
import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    describe "Move"
        [ describe "Validate" <|
            let
                tile =
                    { letter = "A", id = 1, value = 1, multiplier = Multiplier.NoMultiplier }
            in
            [ test "Validate with valid moves along a row" <|
                \_ ->
                    [ { tile = tile, position = ( 8, 4 ) }, { tile = tile, position = ( 8, 6 ) } ]
                        |> Move.validate
                        |> Expect.equal (Row 8)
            , test "Validate with valid moves along a column" <|
                \_ ->
                    [ { tile = tile, position = ( 4, 8 ) }, { tile = tile, position = ( 6, 8 ) } ]
                        |> Move.validate
                        |> Expect.equal (Column 8)
            , test "Validate with invalid moves list" <|
                \_ ->
                    [ { tile = tile, position = ( 5, 2 ) }, { tile = tile, position = ( 9, 14 ) } ]
                        |> Move.validate
                        |> Expect.equal Invalid
            , test "Validate with an empty moves list" <|
                \_ ->
                    Move.validate []
                        |> Expect.equal Invalid
            ]
        ]
