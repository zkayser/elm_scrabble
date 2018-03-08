module GameContextTest exposing (..)

import Data.Grid as Grid exposing (Tile)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Logic.GameContext as Context exposing (Turn(..))
import Test exposing (..)


suite : Test
suite =
    describe "GameContext"
        [ describe "User is Active" <|
            let
                -- The function is curried so that it is always
                -- evaluated with an `Active` Turn parameter for
                -- the remainder of the test block
                update =
                    Context.update Active

                -- Same thing here
                isValidSubmission =
                    Context.isValidSubmission Active

                initialContext =
                    Context.init Grid.init initialTiles
            in
            [ test "A tile is transferred from the context's tiles list to the grid when played" <|
                \_ ->
                    Expect.equal True False
            , test "A tile cannot be placed on top of another tile on the grid" <|
                \_ ->
                    Expect.equal True False
            , test "All tiles played must be in the same row or column to create a valid submission" <|
                \_ ->
                    Expect.equal True False
            , test "Moving a tile already on the board transfers it from the initial position to the new position" <|
                \_ ->
                    Expect.equal True False
            ]
        ]


initialTiles : List Tile
initialTiles =
    List.map (\( number, letter ) -> { letter = letter, id = number, value = number })
        [ ( 1, "A" ), ( 2, "B" ), ( 3, "C" ), ( 4, "D" ), ( 5, "E" ), ( 6, "F" ), ( 7, "G" ) ]
