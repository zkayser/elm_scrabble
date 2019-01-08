port module Phoenix.Socket exposing (Socket, createSocket, encode, init, named, socketCreated, subscriptions, withOnOpen)

import Dict exposing (Dict)
import Json.Decode exposing (Value)
import Json.Encode as Encode
import Phoenix.Channel as Channel exposing (Channel)


type alias Socket msg =
    { endpoint : String
    , channels : Dict String (Channel msg) -- for now
    , events : Dict ( String, String ) (Value -> msg)
    , onOpen : Maybe (Value -> msg)
    , onClose : Maybe (Value -> msg)
    , onError : Maybe (Value -> msg)
    , name : String
    }


init : String -> Socket msg
init endpoint =
    { endpoint = endpoint
    , channels = Dict.empty
    , events = Dict.empty
    , onOpen = Nothing
    , onClose = Nothing
    , onError = Nothing
    , name = "Default"
    }


named : String -> Socket msg -> Socket msg
named name socket =
    { socket | name = name }


withOnOpen : (Value -> msg) -> Socket msg -> Socket msg
withOnOpen onOpenFn socket =
    { socket | onOpen = Just onOpenFn }


withOnClose : (Value -> msg) -> Socket msg -> Socket msg
withOnClose onCloseFn socket =
    { socket | onClose = Just onCloseFn }


withOnError : (Value -> msg) -> Socket msg -> Socket msg
withOnError onErrorFn socket =
    { socket | onError = Just onErrorFn }


subscriptions : Socket msg -> Sub msg
subscriptions socket =
    let
        onOpenSub =
            case socket.onOpen of
                Nothing ->
                    Sub.none

                Just fn ->
                    onOpen fn

        onCloseSub =
            case socket.onClose of
                Nothing ->
                    Sub.none

                Just fn ->
                    onClose fn

        onErrorSub =
            case socket.onError of
                Nothing ->
                    Sub.none

                Just fn ->
                    onError fn
    in
    Sub.batch [ onOpenSub, onCloseSub, onErrorSub ]


encode : Socket msg -> Value
encode socket =
    Encode.object
        [ ( "endpoint", Encode.string socket.endpoint )
        , ( "name", Encode.string socket.name )
        ]


port createSocket : Value -> Cmd msg


port socketCreated : (Value -> msg) -> Sub msg


port onOpen : (Value -> msg) -> Sub msg


port onClose : (Value -> msg) -> Sub msg


port onError : (Value -> msg) -> Sub msg
