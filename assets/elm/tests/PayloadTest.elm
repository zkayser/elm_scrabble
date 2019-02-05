module PayloadTest exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode
import Json.Encode as Encode
import Phoenix.Payload as Payload
import Test exposing (..)


suite : Test
suite =
    describe "Payload"
        [ describe "Payload.decode"
            [ test "decoding a valid Payload" <|
                \_ ->
                    let
                        encodedPayload =
                            Encode.object
                                [ ( "topic", Encode.string "room:lobby" )
                                , ( "message", Encode.string "ChannelJoined" )
                                , ( "payload", Encode.object [ ( "some_param", Encode.string "some value" ) ] )
                                ]
                    in
                    Decode.decodeValue Payload.decoder encodedPayload
                        |> Expect.equal
                            (Ok
                                { topic = "room:lobby"
                                , message = "ChannelJoined"
                                , payload = Encode.object [ ( "some_param", Encode.string "some value" ) ]
                                }
                            )
            , test "decoding an invalid Payload" <|
                \_ ->
                    Decode.decodeValue Payload.decoder (Encode.object [])
                        |> Expect.err
            ]
        ]
