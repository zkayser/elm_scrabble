module Data.Tile exposing (Tile, disable, view)

import Data.Multiplier exposing (Multiplier(..))
import Html exposing (..)
import Html.Attributes exposing (class)
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
