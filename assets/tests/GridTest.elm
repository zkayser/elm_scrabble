module GridTest exposing (..)

import Data.Grid as Grid exposing (Dimension(..), Tile)
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
            ]
        ]
