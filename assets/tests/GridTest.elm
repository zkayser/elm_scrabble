module GridTest exposing (..)

import Data.Grid as Grid exposing (Dimension(..), Grid, Position, Tile)
import Data.Move exposing (Move)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "Scrabble"
        [ describe "Grid.init"
            [ test "Grid init creates a 15 x 15 board" <|
                \_ ->
                    Expect.equal (15 * 15) (List.length Grid.init)
            ]
        , describe "Grid.get"
            [ test "Get Row 8" <|
                \_ ->
                    Expect.true "Expected to get a list of cells from row 8 only" <|
                        List.all (\cell -> Tuple.first cell.position == 8) (Grid.get (Row 8) Grid.init)
            , test "Get Column 8" <|
                \_ ->
                    Expect.true "Expected to get a list of cells from column 8 only" <|
                        List.all (\cell -> Tuple.second cell.position == 8) (Grid.get (Column 8) Grid.init)
            , test "Get Invalid" <|
                \_ ->
                    Expect.equal (Grid.get Invalid Grid.init) []
            ]
        , describe "Grid.validateWithMoves" <|
            let
                tileA =
                    { letter = "A", id = 1, value = 1 }

                tileB =
                    { letter = "B", id = 2, value = 2 }

                tileC =
                    { letter = "C", id = 3, value = 3 }
            in
            [ test "Moves are valid along and make up all of the tiles on a row" <|
                \_ ->
                    let
                        moves =
                            fakeMovesWith [ tileC, tileA, tileB ] [ ( 8, 7 ), ( 8, 8 ), ( 8, 9 ) ]

                        grid =
                            addMovesToGrid moves
                    in
                    Expect.true "Moves were not valid but should have been"
                        (Grid.get (Row 8) grid
                            |> Grid.validateSubmissible moves
                        )
            ]
        ]


fakeMovesWith : List Tile -> List Position -> List Move
fakeMovesWith tiles positions =
    List.map2 (\tile position -> { tile = tile, position = position }) tiles positions


addMovesToGrid : List Move -> Grid
addMovesToGrid moves =
    List.foldr
        (\move grid ->
            List.map
                (\cell ->
                    if cell.position == move.position then
                        { cell | tile = Just move.tile }
                    else
                        cell
                )
        )
        Grid.init
        moves
