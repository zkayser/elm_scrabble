module Types.Messages exposing (..)


type MessageType
    = Error
    | Success


type alias Message =
    ( MessageType, String )
