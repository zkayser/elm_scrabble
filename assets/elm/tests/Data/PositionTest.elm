module Data.PositionTest exposing (suite)

import Data.Position as Position
import Expect
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
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
        ]
