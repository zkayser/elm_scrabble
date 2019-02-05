port module Phoenix.Push exposing
    ( Push
    , init, withPayload
    , encode
    )

{-| Phoenix.Push exposes a data structure that represents a message being pushed to the server along with
functions for configuring the Push with payloads and callback functions when the message succeeds or fails.


# Definition

@docs Push, Topic, Event


# Helpers

@docs init, withPayload, onOk, onError

-}

import Json.Encode as Json exposing (Value)


{-| Represents a message being pushed to the server
-}
type alias Push msg =
    { topic : String
    , event : String
    , payload : Maybe Value
    , onOk : Maybe (Value -> msg)
    , onError : Maybe (Value -> msg)
    }


{-| Alias for a String representing a channel topic
-}
type alias Topic =
    String


{-| Alias for a String representing an "event" in the context of Phoenix channels
-}
type alias Event =
    String


{-| Initializes a Push message with a topic and event.

    Push.init "room:lobby" "my_push_event"

-}
init : Topic -> Event -> Push msg
init topic event =
    { topic = topic
    , event = event
    , payload = Nothing
    , onOk = Nothing
    , onError = Nothing
    }


{-| Adds a payload to be sent along with the Push message.

    let
        payload =
            Json.Encode.object [ ( "some_param", Json.Encode.string "some value" ) ]
    in
    Push.init "room:lobby" "my_push_event"
        |> Push.withPayload payload

-}
withPayload : Value -> Push msg -> Push msg
withPayload payload push_ =
    { push_ | payload = Just payload }


{-| Registers a callback for when the Push message is successful.

    type MyMsg = PushSuccess Value | ...

    Push.init "room:lobby" "my_push_event"
    |> Push.onOk PushSuccess

-}
onOk : (Value -> msg) -> Push msg -> Push msg
onOk callback push_ =
    { push_ | onOk = Just callback }


{-| Registers a callback for when the Push message encounters an error.

    type MyMsg = PushFailure Value | ...

    Push.init "room:lobby" "my_push_event"
    |> Push.onError PushFailure

-}
onError : (Value -> msg) -> Push msg -> Push msg
onError callback push_ =
    { push_ | onError = Just callback }


{-| Encodes a Push. This can be used to pass the Elm representation of a Push to the JavaScript client via a port.

    let
        payload =
            Json.Encode.object [ ( "my_message", Json.Encode.string "Hello, world" ) ]
    in
    Push.init "room:lobby" "my_push_message"
        |> Push.withPayload payload
        |> Push.encode

-}
encode : Push msg -> Value
encode push_ =
    Json.object
        [ ( "topic", Json.string push_.topic )
        , ( "event", Json.string push_.event )
        , ( "payload", Maybe.withDefault (Json.object []) push_.payload )
        ]
