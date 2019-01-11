port module Phoenix.Channel exposing
    ( Channel
    , Payload
    , command
    , createChannel
    , encode
    , init
    , on
    , onMessageReceived
    , payloadDecoder
    , subscriptions
    , withPayload
    )

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Json exposing (Value)
import Task exposing (Task)


type alias Channel msg =
    { topic : String
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
    }


type alias Payload =
    { topic : String
    , message : String
    , payload : Value
    }


init : String -> Channel msg
init topic =
    { topic = topic
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
        [ ( "topic", Json.string channel.topic )
        , ( "payload", Maybe.withDefault (Json.dict identity identity Dict.empty) channel.payload )
        , ( "messages", Json.list Json.string (Dict.keys channel.on) )
        ]


subscriptions : (Value -> msg) -> Channel msg -> Sub msg
subscriptions phoenixMsg channel =
    case Dict.toList channel.on of
        [] ->
            Sub.none

        messages ->
            onMessageReceived phoenixMsg


command : Payload -> List (Channel msg) -> Cmd msg
command fromChannel channels =
    channels
        |> List.map .on
        |> List.map (Dict.get fromChannel.message)
        |> List.map (maybeToCmd fromChannel.payload)
        |> Cmd.batch


maybeToCmd : Value -> Maybe (Value -> msg) -> Cmd msg
maybeToCmd payload maybeFn =
    case maybeFn of
        Just fn ->
            Task.perform fn (Task.succeed payload)

        Nothing ->
            Cmd.none


payloadDecoder : Decoder Payload
payloadDecoder =
    Decode.map3 Payload
        (Decode.field "topic" Decode.string)
        (Decode.field "message" Decode.string)
        (Decode.field "payload" Decode.value)



-- PORTS


port createChannel : Value -> Cmd msg


port onMessageReceived : (Value -> msg) -> Sub msg
