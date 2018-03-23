module Validator2Test exposing (..)

-- import Logic.Validator2

import Data.Grid as Grid exposing (Dimension(..), Grid, Position)
import Data.Move as Move exposing (Move)
import Data.ScrabblePlay as Play exposing (Play)
import Dict
import Expect exposing (Expectation)
import Logic.GameContext exposing (Context)
import Logic.Validator as Validator exposing (ValidatorState(..))
import Test exposing (..)


suite : Test
suite =
    describe "Validator"
        [ test "A move is valid if it is the first tile played & on the center piece" <|
            \_ ->
                let
                    moves =
                        createMoves [ "A" ] [ ( 8, 8 ) ] 0
                in
                moves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid moves)
                    |> toggleFirstPlayForContext
                    |> Validator.validateV2 (Row 8)
                    |> Expect.equal (Validated [ buildPlayFor "A" ])
        , test "A move is invalid if it is the first tile played & not on the center piece" <|
            \_ ->
                let
                    moves =
                        createMoves [ "A" ] [ ( 8, 7 ) ] 0
                in
                moves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid moves)
                    |> toggleFirstPlayForContext
                    |> Validator.validateV2 (Row 8)
                    |> Expect.equal Invalidated
        , test "A non-first play move is invalid if it contains only one unconnected tile" <|
            \_ ->
                let
                    existingMoves =
                        createMoves [ "A" ] [ ( 8, 8 ) ] 2

                    playerMoves =
                        createMoves [ "B" ] [ ( 6, 13 ) ] 0
                in
                playerMoves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid (playerMoves ++ existingMoves))
                    |> Validator.validateV2 (Row 6)
                    |> Expect.equal Invalidated
        , test "A move is valid if all tiles played are in the same row with no gaps" <|
            \_ ->
                let
                    moves =
                        createMoves [ "A", "T" ] [ ( 8, 8 ), ( 8, 9 ) ] 0
                in
                moves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid moves)
                    |> Validator.validateV2 (Row 8)
                    |> Expect.equal (Validated [ buildPlayFor "AT" ])
        , test "A move is valid if all tiles played are in same row with existing tiles in between" <|
            \_ ->
                let
                    existingMoves =
                        createMoves [ "S" ] [ ( 8, 8 ) ] 3

                    playerMoves =
                        createMoves [ "A", "H" ] [ ( 8, 7 ), ( 8, 9 ) ] 0
                in
                playerMoves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid (playerMoves ++ existingMoves))
                    |> Validator.validateV2 (Row 8)
                    |> Expect.equal (Validated [ buildPlayFor "ASH" ])
        , test "A move is invalid if there are spaces between the tiles played in a row" <|
            \_ ->
                let
                    moves =
                        createMoves [ "A", "B" ] [ ( 8, 7 ), ( 8, 9 ) ] 0
                in
                moves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid moves)
                    |> Validator.validateV2 (Row 8)
                    |> Expect.equal Invalidated
        , test "A move is valid if all tiles played are in the same column with no gaps" <|
            \_ ->
                let
                    moves =
                        createMoves [ "A", "T" ] [ ( 8, 8 ), ( 9, 8 ) ] 0
                in
                moves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid moves)
                    |> Validator.validateV2 (Column 8)
                    |> Expect.equal (Validated [ buildPlayFor "AT" ])
        , test "A move is valid if all tiles played are in same column with existing tiles between" <|
            \_ ->
                let
                    existingMoves =
                        createMoves [ "S" ] [ ( 8, 8 ) ] 3

                    playerMoves =
                        createMoves [ "A", "H" ] [ ( 7, 8 ), ( 9, 8 ) ] 0
                in
                playerMoves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid (playerMoves ++ existingMoves))
                    |> Validator.validateV2 (Column 8)
                    |> Expect.equal (Validated [ buildPlayFor "ASH" ])
        , test "A move is invalid if there are spaces between the tiles played in a column" <|
            \_ ->
                let
                    moves =
                        createMoves [ "A", "B" ] [ ( 7, 8 ), ( 9, 8 ) ] 0
                in
                moves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid moves)
                    |> Validator.validateV2 (Column 8)
                    |> Expect.equal Invalidated
        , test "A move is invalid if its tiles are played in completely different rows and columns" <|
            \_ ->
                let
                    moves =
                        createMoves [ "A", "S" ] [ ( 8, 8 ), ( 1, 1 ) ] 0
                in
                moves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid moves)
                    |> Validator.validateV2 (Row 8)
                    |> Expect.equal Invalidated
        , test "Valid move along row picks up tangential column moves" <|
            \_ ->
                let
                    existingMoves =
                        createMoves [ "C", "T", "A" ] [ ( 7, 8 ), ( 9, 8 ), ( 7, 9 ) ] 4

                    playerMoves =
                        createMoves [ "S", "A", "T" ] [ ( 8, 7 ), ( 8, 8 ), ( 8, 9 ) ] 0

                    expectedSecondaryPlay1 =
                        { word = "AT", multipliers = Dict.fromList [ ( "DoubleLetter", [ "A" ] ) ] }

                    expectedSecondaryPlay2 =
                        { word = "CAT", multipliers = Dict.fromList [ ( "DoubleWord", [] ) ] }
                in
                playerMoves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid (playerMoves ++ existingMoves))
                    |> Validator.validateV2 (Row 8)
                    |> Expect.equal (Validated [ buildPlayFor "SAT", expectedSecondaryPlay1, expectedSecondaryPlay2 ])
        ]


createMoves : List String -> List Position -> Int -> List Move
createMoves letters positions idStartInt =
    List.map2 buildMove letters positions
        |> List.indexedMap
            (\int move ->
                let
                    tile =
                        move.tile

                    newTile =
                        { tile | id = idStartInt + int }
                in
                { move | tile = newTile }
            )


buildMove : String -> Position -> Move
buildMove letter position =
    { tile = { letter = letter, id = 1, value = 1, multiplier = Grid.NoMultiplier }, position = position }


insertMovesIntoGrid : List Move -> Grid
insertMovesIntoGrid moves =
    List.foldr (\move grid -> insertMoveIntoGrid move grid) Grid.init moves


insertMoveIntoGrid : Move -> Grid -> Grid
insertMoveIntoGrid move grid =
    List.map
        (\cell ->
            if cell.position == move.position then
                { cell | tile = Just move.tile }
            else
                cell
        )
        grid


insertMovesIntoContext : List Move -> Context
insertMovesIntoContext moves =
    { movesMade = moves, grid = [], tiles = [], firstPlay = False }


insertGridIntoContext : Grid -> Context -> Context
insertGridIntoContext newGrid context =
    { context | grid = newGrid }


toggleFirstPlayForContext : Context -> Context
toggleFirstPlayForContext context =
    { context | firstPlay = not context.firstPlay }



-- A helper to create scrabble plays


buildPlayFor : String -> Play
buildPlayFor word =
    { word = word, multipliers = Dict.fromList [ ( "DoubleWord", [] ) ] }
