module GridTest exposing (..)

import Data.Grid as Grid exposing (Tile)
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
        ]
