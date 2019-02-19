module Data.Position exposing (Position, decode)

import Json.Decode as Decode exposing (Decoder)


type alias Position =
    ( Int, Int )


decode : Decoder Position
decode =
    Decode.map2 (\col row -> ( col, row ))
        (Decode.field "col" Decode.int)
        (Decode.field "row" Decode.int)
