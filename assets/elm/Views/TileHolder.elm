module Views.TileHolder exposing (DragConfig, Model, view, viewTile, viewTiles)

import Data.GameContext exposing (Context)
import Data.Grid as Grid exposing (Cell, Tile)
import Html exposing (..)
import Html.Attributes as Attributes exposing (class)
import Html.Events as Events exposing (on)
import Widgets.DragAndDrop as DragAndDrop exposing (Config)


type alias DragConfig msg =
    DragAndDrop.Config msg Tile Cell


type alias Model r msg =
    { r
        | context : Context
        , dragAndDropConfig : DragConfig msg
    }


view : msg -> msg -> Model r msg -> Html msg
view dropMsg dragOverMsg model =
    div ([ class "tileholder" ] ++ DragAndDrop.droppable dropMsg dragOverMsg)
        [ viewTiles model ]


viewTiles : Model r msg -> Html msg
viewTiles model =
    div [ class "tiles" ] (List.map (\tile -> viewTile model.dragAndDropConfig tile) model.context.tiles)


viewTile : DragConfig msg -> Tile -> Html msg
viewTile config tile =
    div ([ class "tile" ] ++ DragAndDrop.draggable (config.dragStartMsg tile) config.dragEndMsg)
        [ span [ class "letter" ] [ text tile.letter ]
        , span [ class "value" ] [ text <| String.fromInt tile.value ]
        ]
