module Data.TileTest exposing (suite)

import Data.Tile as Tile exposing (Tile)
import Expect
import Test exposing (..)


suite : Test
suite =
    describe "Tile"
        [ test "exists" <|
            \_ ->
                Expect.pass
        ]
