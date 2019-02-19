module Data.Tile exposing (Tile, decode, disable, view)

import Data.Multiplier as Multiplier exposing (Multiplier(..))
import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode as Decode exposing (Decoder)
import Widgets.DragAndDrop exposing (Config, draggable)


type alias Tile =
    { letter : String
    , id : Int
    , value : Int
    , multiplier : Multiplier
    }


view : Config msg Tile cell -> Tile -> Html msg
view config tile =
    let
        dragConfig =
            draggable (config.dragStartMsg tile) config.dragEndMsg
    in
    div ([ class "cell tile" ] ++ dragConfig)
        [ span [ class "letter" ] [ text tile.letter ]
        , span [ class "value" ] [ text <| String.fromInt tile.value ]
        ]


disable : Tile -> Html msg
disable tile =
    div [ class "cell tile" ]
        [ span [ class "letter" ] [ text tile.letter ]
        , span [ class "value" ] [ text <| String.fromInt tile.value ]
        ]


decode : Decoder Tile
decode =
    Decode.map4 Tile
        (Decode.at [ "letter" ] Decode.string)
        (Decode.at [ "id" ] Decode.int)
        (Decode.at [ "value" ] Decode.int)
        (Decode.at [ "multiplier" ] Multiplier.decode)
