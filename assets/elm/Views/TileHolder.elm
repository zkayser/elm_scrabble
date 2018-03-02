module Views.TileHolder exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes exposing (class)
import Html.Events as Events exposing (on)
import Html5.DragDrop as DragDrop


type alias DragId =
    Int


view : { r | tiles : List String, dragDropMsg : DragDrop.Msg DragId dropId -> msg } -> Html msg
view model =
    div [ class "tileholder" ]
        [ viewTiles model ]


viewTiles : { r | tiles : List String, dragDropMsg : DragDrop.Msg DragId dropId -> msg } -> Html msg
viewTiles model =
    let
        tilesWithMsg =
            List.map (\tile -> ( model.dragDropMsg, tile )) model.tiles
    in
    div [ class "tiles" ] (List.map viewTile tilesWithMsg)


viewTile : ( DragDrop.Msg DragId dropId -> msg, String ) -> Html msg
viewTile ( dragDropMsg, letter ) =
    div ([ class "tile" ] ++ DragDrop.draggable dragDropMsg 7)
        [ text letter ]
