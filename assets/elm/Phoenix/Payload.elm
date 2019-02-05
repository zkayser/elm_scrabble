module Phoenix.Payload exposing
    ( Payload
    , decoder
    )

{-| A Phoenix.Payload represents response data coming from the Phoenix JavaScript library.


# Definition

@docs Payload


# Functions

@docs decode

-}

import Json.Decode as Decode exposing (Decoder, Value)


{-| Represents data coming back from the Phoenix JavaScript library
-}
type alias Payload =
    { topic : String
    , message : String
    , payload : Value
    }


{-| Creates a decoder for a Phoenix payload sent back from JavaScript.

    json =
        Json.Encode.object
            [ ( "topic", Encode.string "room:lobby" )
            , ( "message", Encode.string "ChannelJoined")
            , ( "payload", Encode.object [ ( "user_id", Encode.string "123") ])
            ]

    Json.Decode.decodeValue Payload.decoder json

-}
decoder : Decoder Payload
decoder =
    Decode.map3 Payload
        (Decode.field "topic" Decode.string)
        (Decode.field "message" Decode.string)
        (Decode.field "payload" Decode.value)
