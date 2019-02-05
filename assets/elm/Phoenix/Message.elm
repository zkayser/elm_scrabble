module Phoenix.Message exposing
    ( Message(..), Data
    , createSocket, createChannel, createPush, disconnect, leaveChannel
    , subscribe
    , Event(..), PhoenixCommand(..), send
    )

{-| Phoenix.Message defines a set of messages that can be passed between external Phoenix socket/channel data sources and Elm.


# Definition

@docs Message, Data


# Phoenix Commands

@docs createSocket, createChannel, createPush, disconnect, leaveChannel


# External Communication

@docs sendCommand, subscribe

-}

-- TODO: Remove this file and move everything to the base Phoenix module

import Dict
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Payload as Payload exposing (Payload)
import Phoenix.Push as Push exposing (Push)
import Phoenix.Socket as Socket exposing (Socket)


type Message msg
    = Incoming Event
    | Outgoing (PhoenixCommand msg)


type Event
    = SocketClosed
    | SocketErrored Payload
    | SocketOpened
    | ChannelJoined Payload
    | ChannelJoinError Payload
    | ChannelJoinTimeout Payload
    | ChannelMessageReceived Payload
    | ChannelLeft Payload
    | ChannelLeaveError Payload
    | PushOk Payload
    | PushError Payload


type PhoenixCommand msg
    = CreateSocket (Socket msg)
    | CreateChannel (Channel msg)
    | CreatePush (Push msg)
    | Disconnect
    | LeaveChannel (Channel msg)


type alias Data =
    { tag : String, data : Value }


{-| Creates a PhoenixCommand describing a request to instantiate a socket based on the
socket record passed in.

    Socket.init "/my_socket_endpoint"
        |> Phoenix.createSocket

-}
createSocket : Socket msg -> Message msg
createSocket socket =
    Outgoing <| CreateSocket socket


{-| Creates a Message that describes a request to disconnect a socket connection.
-}
disconnect : Message msg
disconnect =
    Outgoing Disconnect


{-| Creates a Message that describes a request to connect to a channel based on the
channel record passed in.
-}
createChannel : Channel msg -> Message msg
createChannel channel =
    Outgoing <| CreateChannel channel


{-| Creates a Message that describes a request to leave the given channel.

    myModel.channel
        |> Phoenix.leaveChannel

-}
leaveChannel : Channel msg -> Message msg
leaveChannel channel =
    Outgoing <| LeaveChannel channel


{-| Creates a Message that describes a request to push a message from the
client to the server.

    Push.init "room:lobby" "my_event"
        |> Phoenix.createPush

-}
createPush : Push msg -> Message msg
createPush push =
    Outgoing <| CreatePush push


{-| Takes a user provided outgoing port function along with a PhoenixCommand and returns
a Cmd msg that calling apps can listen for and respond to appropriately.

    let
        phoenixCommand =
            Socket.init "/my_web_socket_endpoint"
                |> Phoenix.createSocket
    in
    Phoenix.send myOutgoingPort phoenixCommand

-}
send : (Data -> Cmd msg) -> Message msg -> Cmd msg
send externalAppOutgoingPortFn command =
    case command of
        Outgoing cmd ->
            case cmd of
                CreateSocket socket ->
                    externalAppOutgoingPortFn { tag = "CreateSocket", data = Socket.encode socket }

                CreateChannel channel ->
                    externalAppOutgoingPortFn { tag = "CreateChannel", data = Channel.encode channel }

                CreatePush push ->
                    externalAppOutgoingPortFn { tag = "CreatePush", data = Push.encode push }

                Disconnect ->
                    externalAppOutgoingPortFn { tag = "Disconnect", data = Encode.null }

                LeaveChannel channel ->
                    externalAppOutgoingPortFn { tag = "LeaveChannel", data = Channel.encode channel }

        _ ->
            Cmd.none


{-| Takes a user provided incoming port function along with a Phoenix Event, a tagging function, and an
error handling function. This function can be called in your Main module's subscriptions function
to subscribe to events coming in from the JavaScript Phoenix library.

    -- Main.elm
    type Msg = MyPhoenixTagger Phoenix.Event | PhoenixError String | ...

    subscriptions : Model -> Sub Msg
    subscriptions model =
        Sub.batch [ model.someOtherSubscription, Phoenix.subscribe myIncomingPort MyPhoenixTagger PhoenixError  ]

-}
subscribe : ((Data -> msg) -> Sub msg) -> (Event -> msg) -> (String -> msg) -> Sub msg
subscribe externalAppIncomingPortFn tagger onError =
    externalAppIncomingPortFn <|
        \external ->
            let
                tagWithPayload =
                    decodeWith external tagger onError
            in
            case external.tag of
                "SocketClosed" ->
                    tagger <| SocketClosed

                "SocketErrored" ->
                    tagWithPayload SocketErrored

                "SocketOpened" ->
                    tagger <| SocketOpened

                "ChannelMessageReceived" ->
                    tagWithPayload ChannelMessageReceived

                "ChannelJoined" ->
                    tagWithPayload ChannelJoined

                "ChannelJoinError" ->
                    tagWithPayload ChannelJoinError

                "ChannelJoinTimeout" ->
                    tagWithPayload ChannelJoinTimeout

                "ChannelLeft" ->
                    tagWithPayload ChannelLeft

                "ChannelLeaveError" ->
                    tagWithPayload ChannelLeaveError

                "PushOk" ->
                    tagWithPayload PushOk

                "PushError" ->
                    tagWithPayload PushError

                _ ->
                    onError <| "Received on unexpected message from an external source: " ++ Debug.toString external


decodeWith : Data -> (Event -> msg) -> (String -> msg) -> (Payload -> Event) -> msg
decodeWith external tagger onError event =
    case Decode.decodeValue Payload.decoder external.data of
        Ok payload ->
            tagger <| event payload

        Err error ->
            onError <| Decode.errorToString error
