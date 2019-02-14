module Data.Tile exposing (Tile, toHtml)

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


toHtml : Config msg Tile cell -> Tile -> Html msg
toHtml config tile =
  let
      dragConfig =
          draggable (config.dragStartMsg tile) config.dragEndMsg
  in
  div ([ class "cell tile" ] ++ dragConfig)
      [ span [ class "letter" ] [ text tile.letter ]
      , span [ class "value" ] [ text <| String.fromInt tile.value ]
      ]