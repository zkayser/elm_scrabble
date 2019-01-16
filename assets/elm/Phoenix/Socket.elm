port module Phoenix.Socket exposing
    ( Socket
    , createSocket
    , encode
    , init
    , socketCreated
    , withDebug
    , withOnClose
    , withOnError
    , withOnOpen
    , withParams
    )

import Dict exposing (Dict)
import Json.Decode exposing (Value)
import Json.Encode as Encode
import Phoenix.Channel as Channel exposing (Channel)


type alias Socket msg =
    { endpoint : String
    , channels : Dict String (Channel msg) -- for now
    , events : Dict ( String, String ) (Value -> msg)
    , onOpen : Maybe msg
    , onClose : Maybe msg
    , onError : Maybe msg
    , params : Maybe Value
    , debug : Bool
    }


init : String -> Socket msg
init endpoint =
    { endpoint = endpoint
    , channels = Dict.empty
    , events = Dict.empty
    , onOpen = Nothing
    , onClose = Nothing
    , onError = Nothing
    , params = Nothing
    , debug = False
    }


withDebug : Socket msg -> Socket msg
withDebug socket =
    { socket | debug = True }


withOnOpen : msg -> Socket msg -> Socket msg
withOnOpen openMsg socket =
    { socket | onOpen = Just openMsg }


withOnClose : msg -> Socket msg -> Socket msg
withOnClose onCloseFn socket =
    { socket | onClose = Just onCloseFn }


withOnError : msg -> Socket msg -> Socket msg
withOnError onErrorFn socket =
    { socket | onError = Just onErrorFn }


withParams : Value -> Socket msg -> Socket msg
withParams params socket =
    { socket | params = Just params }


encode : Socket msg -> Value
encode socket =
    Encode.object
        [ ( "endpoint", Encode.string socket.endpoint )
        , ( "params", Maybe.withDefault (Encode.object []) socket.params )
        , ( "debug", Encode.bool socket.debug )
        ]


port createSocket : Value -> Cmd msg


port socketCreated : (Value -> msg) -> Sub msg


port onOpen : (Value -> msg) -> Sub msg


port onClose : (Value -> msg) -> Sub msg


port onError : (Value -> msg) -> Sub msg
