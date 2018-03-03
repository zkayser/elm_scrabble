module Views.TileHolder exposing (..)

import Data.Grid as Grid exposing (Cell, Tile)
import Html exposing (..)
import Html.Attributes as Attributes exposing (class)
import Html.Events as Events exposing (on)
import Widgets.DragAndDrop as DragAndDrop exposing (Config)


type alias DragConfig msg =
    DragAndDrop.Config msg Tile Cell


type alias Model r msg =
    { r
        | tiles : List Tile
        , dragAndDropConfig : DragConfig msg
    }


view : Model r msg -> Html msg
view model =
    div [ class "tileholder" ]
        [ viewTiles model ]


viewTiles : Model r msg -> Html msg
viewTiles model =
    div [ class "tiles" ] (List.map (\tile -> viewTile model.dragAndDropConfig tile) model.tiles)


viewTile : DragConfig msg -> Tile -> Html msg
viewTile config tile =
    div ([ class "tile" ] ++ DragAndDrop.draggable (config.dragStartMsg tile) config.dragEndMsg)
        [ text tile.letter ]
