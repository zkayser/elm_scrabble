port module Phoenix.Push exposing (Push, encode, init, push, withPayload)

import Json.Encode as Json exposing (Value)


type alias Push msg =
    { topic : String
    , event : String
    , payload : Maybe Value
    , onOk : Maybe (Value -> msg)
    , onError : Maybe (Value -> msg)
    }


type alias Topic =
    String


type alias Event =
    String


init : Topic -> Event -> Push msg
init topic event =
    { topic = topic
    , event = event
    , payload = Nothing
    , onOk = Nothing
    , onError = Nothing
    }


withPayload : Value -> Push msg -> Push msg
withPayload payload push_ =
    { push_ | payload = Just payload }


encode : Push msg -> Value
encode push_ =
    Json.object
        [ ( "topic", Json.string push_.topic )
        , ( "event", Json.string push_.event )
        , ( "payload", Maybe.withDefault (Json.object []) push_.payload )
        ]


port push : Value -> Cmd msg
