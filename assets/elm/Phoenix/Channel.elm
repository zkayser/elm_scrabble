port module Phoenix.Channel exposing
    ( Channel
    , init, withPayload, on
    , Payload, command, createChannel, encode, onMessageReceived, payloadDecoder, subscriptions
    )

{-| A channel declares which topic should be joined, registers event handlers and has various callbacks for possible lifecycle events.


# Definition

@docs Channel


# Helpers

@docs init, withPayload, on, off, onJoin, onJoinError, onError, onDisconnect, onRejoin, onLeave, onLeaveError, withDebug, map

-}

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Json exposing (Value)
import Task exposing (Task)


type alias Channel msg =
    { topic : String
    , payload : Maybe Value
    , onJoin : Maybe (Value -> msg)
    , onJoinError : Maybe (Value -> msg)
    , onClose : Maybe msg
    , onDisconnect : Maybe msg
    , onError : Maybe (Value -> msg)
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
    , onJoin = Nothing
    , onJoinError = Nothing
    , onClose = Nothing
    , onDisconnect = Nothing
    , onError = Nothing
    , onLeave = Nothing
    , onLeaveError = Nothing
    , on = Dict.empty
    }


withOnJoin : (Value -> msg) -> Channel msg -> Channel msg
withOnJoin callback channel =
    { channel | onJoin = Just callback }


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
