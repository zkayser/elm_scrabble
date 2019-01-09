port module Phoenix.Channel exposing (Channel, createChannel, encode, init, on, onMessageReceived, subscriptions, withPayload)

import Dict exposing (Dict)
import Json.Encode as Json exposing (Value)


type alias Channel msg =
    { topic : String
    , socketName : String
    , payload : Maybe Value
    , onRequestJoin : Maybe msg
    , onJoin : Maybe (Value -> msg)
    , onJoinError : Maybe (Value -> msg)
    , onDisconnect : Maybe msg
    , onError : Maybe msg
    , onRejoin : Maybe (Value -> msg)
    , onLeave : Maybe (Value -> msg)
    , onLeaveError : Maybe (Value -> msg)
    , on : Dict String (Value -> msg)

    -- , presence : Maybe (Presence msg) ----- Don't have Presence set up yet
    , debug : Bool
    }


type alias Socket r =
    { r | name : String }


init : Socket r -> String -> Channel msg
init socket topic =
    { topic = topic
    , socketName = socket.name
    , payload = Nothing
    , onRequestJoin = Nothing
    , onJoin = Nothing
    , onJoinError = Nothing
    , onDisconnect = Nothing
    , onError = Nothing
    , onRejoin = Nothing
    , onLeave = Nothing
    , onLeaveError = Nothing
    , on = Dict.empty
    , debug = False
    }


withPayload : Value -> Channel msg -> Channel msg
withPayload payload channel =
    { channel | payload = Just payload }


on : String -> (Value -> msg) -> Channel msg -> Channel msg
on event callback channel =
    { channel | on = Dict.insert event callback channel.on }


encode : Channel msg -> Value
encode channel =
    Json.object
        [ ( "socketName", Json.string channel.socketName )
        , ( "topic", Json.string channel.topic )
        , ( "payload", Maybe.withDefault (Json.dict identity identity Dict.empty) channel.payload )
        , ( "messages", Json.list Json.string (Dict.keys channel.on) )
        ]


subscriptions : Channel msg -> Sub msg
subscriptions channel =
    case Dict.toList channel.on of
        [] ->
            Sub.none

        messages ->
            Sub.batch <| List.map (\( _, fn ) -> onMessageReceived fn) messages



-- PORTS


port createChannel : Value -> Cmd msg


port onMessageReceived : (Value -> msg) -> Sub msg
