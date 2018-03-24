module Data.ScrabblePlay exposing (..)

import Data.Grid as Grid exposing (Multiplier(..), Tile)
import Dict exposing (Dict)
import Json.Encode as Encode


type alias Multipliers =
    Dict String (List String)


type alias Play =
    { word : String
    , multipliers : Multipliers
    }


tilesToPlay : List Tile -> Play
tilesToPlay tiles =
    let
        word =
            List.map .letter tiles |> String.concat

        multipliers =
            List.foldr (\tile multipliersDict -> insertTile multipliersDict tile) Dict.empty tiles
    in
    { word = word, multipliers = multipliers }


insertTile : Multipliers -> Tile -> Multipliers
insertTile multipliers tile =
    case tile.multiplier of
        NoMultiplier ->
            multipliers

        DoubleWord ->
            Dict.insert (toString DoubleWord) [] multipliers

        TripleWord ->
            Dict.insert (toString TripleWord) [] multipliers

        multiplier ->
            case Dict.get (toString multiplier) multipliers of
                Just letters ->
                    Dict.insert (toString multiplier) (tile.letter :: letters) multipliers

                Nothing ->
                    Dict.insert (toString multiplier) [ tile.letter ] multipliers


encode : Play -> Encode.Value
encode play =
    Encode.object
        [ ( "word", Encode.string play.word )
        , ( "multipliers", encodeMultipliers play.multipliers )
        ]


encodeList : List Play -> Encode.Value
encodeList plays =
    Encode.object
        [ ( "plays", Encode.list <| List.map (\play -> encode play) plays ) ]


encodeMultipliers : Multipliers -> Encode.Value
encodeMultipliers multipliers =
    Dict.toList multipliers
        |> List.map (\( key, value ) -> Encode.object [ ( key, Encode.list (List.map Encode.string value) ) ])
        |> Encode.list
