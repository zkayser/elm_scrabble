module Types.Messages exposing (Message, MessageType(..))


type MessageType
    = Error
    | Success


type alias Message =
    ( MessageType, String )
