module Data.MultiplierTest exposing (suite)

import Data.Multiplier as Multiplier exposing (Multiplier(..))
import Expect
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import Result
import Test exposing (..)


suite : Test
suite =
    describe "decode" <|
        let
            encode string =
                Encode.string string
        in
        [ test "no multiplier" <|
            \_ ->
                decodeValue Multiplier.decode (encode "no_multiplier")
                    |> Expect.equal (Result.Ok NoMultiplier)
        , test "double word" <|
            \_ ->
                decodeValue Multiplier.decode (encode "double_word")
                    |> Expect.equal (Result.Ok DoubleWord)
        , test "double letter" <|
            \_ ->
                decodeValue Multiplier.decode (encode "double_letter")
                    |> Expect.equal (Result.Ok DoubleLetter)
        , test "triple word" <|
            \_ ->
                decodeValue Multiplier.decode (encode "triple_word")
                    |> Expect.equal (Result.Ok TripleWord)
        , test "triple letter" <|
            \_ ->
                decodeValue Multiplier.decode (encode "triple_letter")
                    |> Expect.equal (Result.Ok TripleLetter)
        , test "invalid multiplier" <|
            \_ ->
                decodeValue Multiplier.decode (encode "asldkja")
                    |> Expect.equal (Result.Ok NoMultiplier)
        ]
