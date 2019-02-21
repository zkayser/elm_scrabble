module Data.Position exposing (Position, decode, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type alias Position =
    ( Int, Int )


decode : Decoder Position
decode =
    Decode.map2 (\col row -> ( col, row ))
        (Decode.field "col" Decode.int)
        (Decode.field "row" Decode.int)

encode : Position -> Value
encode ( col, row ) =
  Encode.object
    [ ( "col", Encode.int col )
    , ( "row", Encode.int row )
    ]