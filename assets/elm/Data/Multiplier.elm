module Data.Multiplier exposing (Multiplier(..), decode, toString)

import Json.Decode as Decode exposing (Decoder)


type Multiplier
    = DoubleWord
    | TripleWord
    | DoubleLetter
    | TripleLetter
    | NoMultiplier
    | Wildcard


toString : Multiplier -> String
toString multiplier =
    case multiplier of
        DoubleWord ->
            "DoubleWord"

        TripleWord ->
            "TripleWord"

        DoubleLetter ->
            "DoubleLetter"

        TripleLetter ->
            "TripleLetter"

        NoMultiplier ->
            "NoMultiplier"

        Wildcard ->
            "Wildcard"


fromString : String -> Multiplier
fromString string =
    case string of
        "DoubleWord" ->
            DoubleWord

        "DoubleLetter" ->
            DoubleLetter

        "TripleWord" ->
            TripleWord

        "TripleLetter" ->
            TripleLetter

        _ ->
            NoMultiplier


decode : Decoder Multiplier
decode =
    Decode.map fromString Decode.string
