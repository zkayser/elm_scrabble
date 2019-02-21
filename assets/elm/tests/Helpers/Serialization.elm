module Helpers.Serialization exposing (expectReversibleDecoder)

import Expect exposing (Expectation)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Encode as Encode exposing (Value)


expectReversibleDecoder : Decoder a -> (a -> Value) -> a -> Expectation
expectReversibleDecoder decoder encoder initial =
    case decodeValue decoder <| encoder initial of
        Ok value ->
            Expect.equal initial value

        Err _ ->
            Expect.fail "Expected decoder to be reversible"
