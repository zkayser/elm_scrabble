module Phoenix.Channel exposing
    ( Channel
    , init, withPayload, on
    , closed, command, encode, errored, joined, leaveErrored, timedOut
    )

{-| A channel declares a topic to be joined, registers event handlers for the topic, and has various callbacks for lifecycle events.


# Definition

@docs Channel


# Helpers

@docs init, withPayload, on, onJoin, onJoinError, onError, onRejoin, onLeave, onLeaveError, withDebug, map

-}

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Json exposing (Value)
import Phoenix.Internal.EntityState exposing (EntityState(..))
import Phoenix.Payload exposing (Payload)
import Task exposing (Task)


{-| Represents a Phoenix channel
-}
type alias Channel msg =
    { topic : String
    , payload : Maybe Value
    , onJoin : Maybe (Value -> msg)
    , onJoinError : Maybe (Value -> msg)
    , onJoinTimeout : Maybe msg
    , onClose : Maybe msg
    , onError : Maybe (Value -> msg)
    , onLeave : Maybe (Value -> msg)
    , onLeaveError : Maybe (Value -> msg)
    , on : Dict String (Value -> msg)
    , state : EntityState
    }


{-| Initializes a channel with the given topic.

    init "room:lobby"

-}
init : String -> Channel msg
init topic =
    { topic = topic
    , payload = Nothing
    , onJoin = Nothing
    , onJoinError = Nothing
    , onJoinTimeout = Nothing
    , onClose = Nothing
    , onError = Nothing
    , onLeave = Nothing
    , onLeaveError = Nothing
    , on = Dict.empty
    , state = Initializing
    }


{-| Sets channel state to connected.
-}
joined : Channel msg -> Channel msg
joined channel =
    { channel | state = Connected }


{-| Sets channel state to errored.
-}
errored : Channel msg -> Channel msg
errored channel =
    { channel | state = Errored }


{-| Sets channel state to closed.
-}
closed : Channel msg -> Channel msg
closed channel =
    { channel | state = Closed }


{-| Sets channel state to TimedOut.
-}
timedOut : Channel msg -> Channel msg
timedOut channel =
    { channel | state = TimedOut }


{-| Sets channel state to LeaveErrored.
-}
leaveErrored : Channel msg -> Channel msg
leaveErrored channel =
    { channel | state = LeaveErrored }


{-| Attaches a payload to the join message. This should be used to submit user IDs, authentication credentials, etc. The payload will
be received as the second argument to the `join/3` callback on the server.

    payload =
        Json.Encode.object [ ( "user_id", "123" ) ]

    init "room:lobby"
    |> withPayload payload

-}
withPayload : Value -> Channel msg -> Channel msg
withPayload payload channel =
    { channel | payload = Just payload }


{-| Sets a callback that will be triggered on successful channel joins.

    type Msg =
        JoinedChannel Json.Encode.Value | ...


    Channel.init "room:lobby"
    |> Channel.onJoin JoinedChannel

-}
onJoin : (Value -> msg) -> Channel msg -> Channel msg
onJoin callback channel =
    { channel | onJoin = Just callback }


{-| Sets a callback that will be triggered when a channel join fails.

    type Msg =
        JoinErrored Json.Encode.Value | ...

    Channel.init "room:lobby"
    |> Channel.onJoinError JoinErrored

-}
onJoinError : (Value -> msg) -> Channel msg -> Channel msg
onJoinError callback channel =
    { channel | onJoinError = Just callback }


{-| Sets a callback to be triggered when the channel connection closes.

    type Msg =
        ChannelClosed | ...

    Channel.init "room:lobby"
    |> Channel.onClose ChannelClosed

-}
onClose : msg -> Channel msg -> Channel msg
onClose callback channel =
    { channel | onClose = Just callback }


{-| Sets a callback to be triggered when the channel connection errors.

    type Msg =
        ChannelErrored Json.Encode.Value | ...

    Channel.init "room:lobby"
    |> Channel.onError ChannelErrored

-}
onError : (Value -> msg) -> Channel msg -> Channel msg
onError callback channel =
    { channel | onError = Just callback }


{-| Sets a callback to be triggered when leaving a channel.

    type Msg =
        ChannelLeft Json.Encode.Value | ...

    Channel.init "room:lobby"
    |> Channel.onLeave ChannelLeft

-}
onLeave : (Value -> msg) -> Channel msg -> Channel msg
onLeave callback channel =
    { channel | onLeave = Just callback }


{-| Sets a callback to be triggered when an error is received when leaving a channel.

    type Msg =
        ChannelLeaveError Json.Encode.Value | ...

    Channel.init "room:lobby"
    |> Channel.onLeaveError ChannelLeaveError

-}
onLeaveError : (Value -> msg) -> Channel msg -> Channel msg
onLeaveError callback channel =
    { channel | onLeaveError = Just callback }


{-| Registers an event handler.

    type Msg = MyChannelEvent Json.Encode.Value | ...

    Channel.init "room:lobby"
    |> Channel.on "my_channel_event" MyChannelEvent

-}
on : String -> (Value -> msg) -> Channel msg -> Channel msg
on event callback channel =
    { channel | on = Dict.insert event callback channel.on }


{-| Encodes a channel. This allows you to pass the Elm representation of your channel to the JavaScript client via a port.

    payload =
        Json.Encode.object [ ( "user_id", "123" ) ]

    type Msg = MyEvent Json.Encode.Value | ChannelJoined Json.Encode.Value | ...

    -- (Elsewhere in your code)
    port myPhoenixOutgoingPort : Json.Encode.Value -> Cmd msg

    channel =
        Channel.init "room:lobby"
        |> Channel.withPayload payload
        |> Channel.onJoin ChannelJoined
        |> Channel.on "my_event" MyEvent
        |> Channel.encode
        |> myPhoenixOutgoingPort

-}
encode : Channel msg -> Value
encode channel =
    Json.object
        [ ( "topic", Json.string channel.topic )
        , ( "payload", Maybe.withDefault (Json.object []) channel.payload )
        , ( "messages", Json.list Json.string (Dict.keys channel.on) )
        ]


command : Payload -> List (Channel msg) -> Cmd msg
command fromChannel channels =
    channels
        |> List.map .on
        |> List.map (Dict.get fromChannel.message)
        |> List.map (maybeToCmd fromChannel.payload)
        |> Cmd.batch


{-| Performs a command to run callbacks on registered event listeners or channel lifecycle hooks.
-}
maybeToCmd : Value -> Maybe (Value -> msg) -> Cmd msg
maybeToCmd payload maybeFn =
    case maybeFn of
        Just fn ->
            Task.perform fn (Task.succeed payload)

        Nothing ->
            Cmd.none
