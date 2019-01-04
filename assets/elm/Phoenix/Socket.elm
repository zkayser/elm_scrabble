port module Phoenix.Socket exposing (Socket, createSocket, encode, init, socketCreated, withOnOpen)

import Dict exposing (Dict)
import Json.Decode exposing (Value)
import Json.Encode as Encode


type alias Socket msg =
    { endpoint : String
    , channels : Dict String String -- for now
    , events : Dict ( String, String ) (Value -> msg)
    , onOpen : Maybe (Value -> msg)
    }


init : String -> Socket msg
init endpoint =
    { endpoint = endpoint
    , channels = Dict.empty
    , events = Dict.empty
    , onOpen = Nothing
    }


withOnOpen : (Value -> msg) -> Socket msg -> Socket msg
withOnOpen onOpenFn socket =
    { socket | onOpen = Just onOpenFn }


encode : Socket msg -> Value
encode socket =
    Encode.object [ ( "endpoint", Encode.string socket.endpoint ) ]


port createSocket : Value -> Cmd msg


port socketCreated : (Value -> msg) -> Sub msg
