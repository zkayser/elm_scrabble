module Data.Multiplier exposing (Multiplier(..), decode, toApiString, toString)

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


fromApiString : String -> Multiplier
fromApiString string =
    case string of
        "double_word" ->
            DoubleWord

        "double_letter" ->
            DoubleLetter

        "triple_word" ->
            TripleWord

        "triple_letter" ->
            TripleLetter

        _ ->
            NoMultiplier

toApiString : Multiplier -> String
toApiString multiplier =
    case multiplier of
        DoubleWord -> "double_word"
        DoubleLetter -> "double_letter"
        TripleWord -> "triple_word"
        TripleLetter -> "triple_letter"
        _ -> "no_multiplier"


decode : Decoder Multiplier
decode =
    Decode.map fromApiString Decode.string
