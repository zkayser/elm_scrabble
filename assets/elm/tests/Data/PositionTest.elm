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
                    encoded = Position.encode ( col, row )
                    decode = Decode.int
                in
                case decodeValue Position.decode encoded of
                    Ok position ->
                        position
                        |> Expect.all
                            [ Expect.equal row << Tuple.second
                            , Expect.equal col << Tuple.first
                            , Expect.equal encoded << Position.encode
                            , (\pos ->
                                case decodeValue Position.decode (Position.encode pos) of
                                    Ok p -> Expect.equal p pos
                                    _ -> Expect.fail "Expected position decoder to be reversible"
                              )
                            ]
                    _ -> Expect.fail "Expected decoder to succeed"
        ]
