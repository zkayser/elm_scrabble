module Data.Leaderboard exposing (Entry, Leaderboard, decoder, entryDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias Leaderboard =
    List Entry


type alias Entry =
    { user : String, score : Int }


entryDecoder : Decoder Entry
entryDecoder =
    Decode.map2 Entry
        (Decode.field "user" Decode.string)
        (Decode.field "score" Decode.int)


decoder : Decoder Leaderboard
decoder =
    Decode.field "leaderboard" (Decode.list entryDecoder)
