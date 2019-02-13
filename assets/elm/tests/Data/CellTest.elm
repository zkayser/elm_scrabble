module Data.CellTest exposing (..)

import Data.Cell as Cell exposing (Cell)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

suite : Test
suite =
  describe "Cell"
    [ test "it exists" <|
        \_ ->
          Expect.pass
    ]