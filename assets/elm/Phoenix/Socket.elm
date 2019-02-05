module Phoenix.Socket exposing
    ( Socket, init
    , onClose, onError, onOpen
    , encode
    , withDebug
    , close, errored, opened, withParams
    )

{-| Represents a socket for connecting to Phoenix channels. This modules exposes a Socket type and functions for
configuring callbacks on the socket's lifecycle events as well as other helpers for debugging and passing params
to the socket on initialization.


# Definition

@docs Socket, init


# Lifecycle callbacks

@docs onClose, onError, onOpen


# Encoding

@docs encode


# Debugging

@docs withDebug

-}

import Dict exposing (Dict)
import Json.Decode exposing (Value)
import Json.Encode as Encode
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Internal.EntityState exposing (EntityState(..))
import Phoenix.Payload exposing (Payload)
import Phoenix.Push exposing (Push)


{-| Represents a socket for connecting to Phoenix channels.
-}
type alias Socket msg =
    { endpoint : String
    , channels : Dict String (Channel msg)
    , onOpen : Maybe msg
    , onClose : Maybe msg
    , onError : Maybe (Value -> msg)
    , params : Maybe Value
    , pushes : Dict String (Push msg)
    , debug : Bool
    , state : EntityState
    }


{-| Configures initialization of a socket. Once created, it tries to connect to the given endpoint.

    Socket.init "/socket"

-}
init : String -> Socket msg
init endpoint =
    { endpoint = endpoint
    , channels = Dict.empty
    , onOpen = Nothing
    , onClose = Nothing
    , onError = Nothing
    , params = Nothing
    , pushes = Dict.empty
    , debug = False
    , state = Initializing
    }


{-| Puts the socket in a closed state.
-}
close : Socket msg -> Socket msg
close socket =
    { socket | state = Closed }


{-| Puts the socket in an errored state.
-}
errored : Socket msg -> Socket msg
errored socket =
    { socket | state = Errored }


{-| Puts the socket in a connected state.
-}
opened : Socket msg -> Socket msg
opened socket =
    { socket | state = Connected }


{-| Configures the socket to log out all incoming Phoenix messages to the console.
-}
withDebug : Socket msg -> Socket msg
withDebug socket =
    { socket | debug = True }


{-| Configures the socket to run the given callback function when the socket connects successfully.

    type MyMsg = SocketConnect | ....

    Socket.init "/socket"
    |> Socket.onOpen SocketConnect

-}
onOpen : msg -> Socket msg -> Socket msg
onOpen openMsg socket =
    { socket | onOpen = Just openMsg }


{-| Configures the socket to run the given callback function when the socket disconnects.

    type MyMsg = SocketDisconnected | ...

    Socket.init "/socket"
    |> Socket.onClose SocketDisconnected

-}
onClose : msg -> Socket msg -> Socket msg
onClose onCloseFn socket =
    { socket | onClose = Just onCloseFn }


{-| Configures the socket to run the given callback function when there is an error on the socket.

    type MyMsg = SocketErrored | ...

    Socket.init "/socket"
    |> Socket.onError SocketErrored

-}
onError : (Value -> msg) -> Socket msg -> Socket msg
onError onErrorFn socket =
    { socket | onError = Just onErrorFn }


{-| Allows you to pass arbitrary parameters along when connecting to a socket.

    params = Json.Encode.object [ ("user_token", Encode.string "my_user_token_123" ) ]
    Socket.init "/socket"
    |> Socket.withParams params

-}
withParams : Value -> Socket msg -> Socket msg
withParams params socket =
    { socket | params = Just params }


{-| Encodes a Socket. This allows you to pass your Elm representation of a Socket to the JavaScript client via a port.
-}
encode : Socket msg -> Value
encode socket =
    Encode.object
        [ ( "endpoint", Encode.string socket.endpoint )
        , ( "params", Maybe.withDefault (Encode.object []) socket.params )
        , ( "debug", Encode.bool socket.debug )
        ]
