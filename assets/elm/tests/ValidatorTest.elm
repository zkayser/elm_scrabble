module ValidatorTest exposing (suite)

import Data.GameContext exposing (Context)
import Data.Grid as Grid exposing (Dimension(..), Grid)
import Data.Move as Move exposing (Move)
import Data.Position exposing (Position)
import Data.ScrabblePlay as Play exposing (Play)
import Dict
import Expect exposing (Expectation)
import Logic.Validator as Validator exposing (ValidatorState(..))
import Test exposing (..)
import TestData exposing (..)


suite : Test
suite =
    describe "Validator"
        [ test "A move is valid if all tiles played are in the same row with no gaps" <|
            \_ ->
                let
                    moves =
                        createMoves [ "A", "T" ] [ ( 8, 8 ), ( 8, 9 ) ] 0
                in
                moves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid moves)
                    |> Validator.validate (Row 8)
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
                    |> Validator.validate (Row 8)
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
                    |> Validator.validate (Row 8)
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
                    |> Validator.validate (Column 8)
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
                    |> Validator.validate (Column 8)
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
                    |> Validator.validate (Column 8)
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
                    |> Validator.validate (Row 8)
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
                    |> Validator.validate (Row 8)
                    |> Expect.equal (Validated [ buildPlayFor "SAT", expectedSecondaryPlay1, expectedSecondaryPlay2 ])
        , test "A play should be valid with only one move if connected to an existing tile (not firstPlay)" <|
            \_ ->
                let
                    playerMoves =
                        createMoves [ "B" ] [ ( 9, 8 ) ] 0

                    existingMoves =
                        createMoves [ "C", "A", "T" ] [ ( 8, 7 ), ( 8, 8 ), ( 8, 9 ) ] 2
                in
                playerMoves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid (playerMoves ++ existingMoves))
                    |> Validator.validate (Row 9)
                    |> Expect.equal (Validated [ buildPlayFor "AB" ])
        , test "A play should be valid on row 1 if connected to existing tiles" <|
            \_ ->
                let
                    playerMoves =
                        createMoves [ "S", "A" ] [ ( 8, 1 ), ( 8, 2 ) ] 0

                    existingMoves =
                        createMoves [ "A", "T", "Y" ] [ ( 7, 3 ), ( 8, 3 ), ( 8, 8 ) ] 4

                    expectedPlay =
                        { word = "SAT", multipliers = Dict.fromList [ ( "TripleWord", [] ) ] }
                in
                playerMoves
                    |> insertMovesIntoContext
                    |> insertGridIntoContext (insertMovesIntoGrid (playerMoves ++ existingMoves))
                    |> Validator.validate (Row 8)
                    |> Expect.equal (Validated [ expectedPlay ])
        ]
