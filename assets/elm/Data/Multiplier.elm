module Data.Multiplier exposing (Multiplier(..), toString)


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
