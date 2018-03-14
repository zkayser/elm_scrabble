module Responses.Scrabble exposing (..)

import Json.Decode as Decode


type alias ScrabbleResponse =
    { score : Maybe Int
    , error : Maybe String
    }


decoder : Decode.Decoder ScrabbleResponse
decoder =
    Decode.map2 ScrabbleResponse
        (Decode.maybe (Decode.field "score" Decode.int))
        (Decode.maybe (Decode.field "error" Decode.string))
