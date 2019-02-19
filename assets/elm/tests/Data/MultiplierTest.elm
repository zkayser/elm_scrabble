module Data.MultiplierTest exposing (suite)

import Data.Multiplier as Multiplier exposing (Multiplier(..))
import Expect
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import Result
import Test exposing (..)


suite : Test
suite =
    describe "decode"
        [ test "no multiplier" <|
            \_ ->
                let
                    json =
                        Encode.string "no_multiplier"
                in
                decodeValue Multiplier.decode json
                    |> Expect.equal (Result.Ok NoMultiplier)
        ]
