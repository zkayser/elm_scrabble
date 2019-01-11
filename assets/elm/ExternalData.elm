port module ExternalData exposing
    ( IncomingData(..)
    , createChannel
    , createPush
    , createSocket
    , outgoing
    , receiveExternal
    , sendDataOut
    , socketOpened
    )

import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Push as Push exposing (Push)
import Phoenix.Socket as Socket exposing (Socket)


type IncomingData
    = SocketOpened
    | ChannelMessageReceived Channel.Payload


type OutgoingData msg
    = CreateSocket (Socket msg)
    | CreateChannel (Channel msg)
    | CreatePush (Push msg)


type alias ExternalData =
    { tag : String, data : Value }


socketOpened : IncomingData
socketOpened =
    SocketOpened


createSocket : Socket msg -> OutgoingData msg
createSocket socket =
    CreateSocket socket


createChannel : Channel msg -> OutgoingData msg
createChannel channel =
    CreateChannel channel


createPush : Push msg -> OutgoingData msg
createPush push =
    CreatePush push


sendDataOut : OutgoingData msg -> Cmd msg
sendDataOut data =
    case data of
        CreateSocket socket ->
            outgoing { tag = "CreateSocket", data = Socket.encode socket }

        CreateChannel channel ->
            outgoing { tag = "CreateChannel", data = Channel.encode channel }

        CreatePush push ->
            outgoing { tag = "CreatePush", data = Push.encode push }


receiveExternal : (IncomingData -> msg) -> (String -> msg) -> Sub msg
receiveExternal tagger onError =
    incoming <|
        \external ->
            case external.tag of
                "SocketOpened" ->
                    tagger <| SocketOpened

                "ChannelMessageReceived" ->
                    case Decode.decodeValue Channel.payloadDecoder external.data of
                        Ok payload ->
                            tagger <| ChannelMessageReceived payload

                        Err error ->
                            onError <| Decode.errorToString error

                _ ->
                    onError <| "Received on unexpected message from an external source: " ++ Debug.toString external


port outgoing : ExternalData -> Cmd msg


port incoming : (ExternalData -> msg) -> Sub msg
