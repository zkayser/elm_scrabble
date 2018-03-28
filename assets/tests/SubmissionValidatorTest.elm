module SubmissionValidatorTest exposing (..)

import Data.GameContext as Context
import Data.Grid as Grid exposing (Tile)
import Data.Move exposing (Move)
import Expect exposing (Expectation)
import Json.Decode exposing (Value)
import Logic.SubmissionValidator as Validator
import Test exposing (..)


suite : Test
suite =
    describe "SubmissionValidator"
        [ describe "validateSubmission" <|
            let
                grid =
                    List.map
                        (\cell ->
                            if cell.isCenter then
                                { cell | tile = Just tileA }
                            else if cell.position == ( 8, 9 ) then
                                { cell | tile = Just tileB }
                            else
                                cell
                        )
                        Grid.init

                invalidMoves =
                    [ { tile = tileA, position = ( 1, 1 ) }, { tile = tileB, position = ( 15, 15 ) } ]

                invalidContext =
                    { grid = grid, movesMade = invalidMoves, tiles = [ tileC ] }

                validateSubmission =
                    Validator.validateSubmission Fake
            in
            [ test "Given an invalid play" <|
                \_ ->
                    let
                        update =
                            validateSubmission invalidContext

                        message =
                            case update of
                                Err response ->
                                    response

                                _ ->
                                    "This string should not match"
                    in
                    Expect.equal message "Invalid play"
            , test "Empty center piece is invalid" <|
                \_ ->
                    let
                        context =
                            { grid = Grid.init, movesMade = [], tiles = [ tileA ] }
                    in
                    context
                        |> validateSubmission
                        |> Expect.equal (Err "You must play a tile on the center piece")
            , test "The center has a tile" <|
                \_ ->
                    { grid = grid, movesMade = [ { tile = tileC, position = ( 8, 7 ) } ], tiles = [] }
                        |> validateSubmission
                        |> Expect.notEqual (Err "You must play a tile on the center piece")
            , test "A floating tile is played" <|
                \_ ->
                    { grid = grid, movesMade = [ { tile = tileC, position = ( 5, 5 ) } ], tiles = [] }
                        |> validateSubmission
                        |> Expect.equal (Err "You must place your tiles in sequence")
            ]
        ]


tileA : Tile
tileA =
    { letter = "A", id = 1, value = 1, multiplier = Grid.NoMultiplier }


tileB : Tile
tileB =
    { letter = "B", id = 2, value = 2, multiplier = Grid.NoMultiplier }


tileC : Tile
tileC =
    { letter = "C", id = 3, value = 3, multiplier = Grid.NoMultiplier }


tileD : Tile
tileD =
    { letter = "D", id = 4, value = 4, multiplier = Grid.NoMultiplier }


createTile : String -> Tile
createTile letter =
    { letter = letter, id = 1, value = 4, multiplier = Grid.NoMultiplier }


movesMade : List Move
movesMade =
    [ { tile = tileA, position = ( 8, 8 ) }, { tile = tileB, position = ( 8, 9 ) } ]


type FakeMsg
    = Fake Value
