module Data.PositionTest exposing (suite)

import Data.Position as Position
import Expect
import Fuzz
import Fuzzers.Position as PositionFuzzer
import Json.Decode as Decode exposing (decodeValue)
import Json.Encode as Encode
import Random
import Result
import Test exposing (..)


suite : Test
suite =
    describe "Position"
        [ test "decode" <|
            \_ ->
                let
                    encodedPosition =
                        Encode.object
                            [ ( "col", Encode.int 8 )
                            , ( "row", Encode.int 8 )
                            ]
                in
                decodeValue Position.decode encodedPosition
                    |> Expect.equal (Result.Ok ( 8, 8 ))
        , fuzz2 (Fuzz.intRange 0 Random.maxInt) (Fuzz.intRange 0 Random.maxInt) "decoding is reversible" <|
            \col row ->
                let
                    encoded =
                        Encode.object
                            [ ( "col", Encode.int col )
                            , ( "row", Encode.int row )
                            ]
                    decode = Decode.int
                in
                decodeValue Position.decode encoded
                    |> Expect.all
                        [ ( \position ->
                            case position of
                                Ok pos -> Expect.equal (Tuple.second pos) row
                                _ -> Expect.fail "Expected row to be decoded"
                          )
                        , ( \position ->
                            case position of
                                Ok pos -> Expect.equal (Tuple.first pos) col
                                _ -> Expect.fail "Expected col to be decoded"
                           )
                        ]
        ]
