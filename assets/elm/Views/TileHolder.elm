module Views.TileHolder exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes exposing (class)
import Html.Events as Events exposing (on)


view : { r | tiles : List String } -> Html msg
view model =
    div [ class "tileholder" ]
        [ viewTiles model ]


viewTiles : { r | tiles : List String } -> Html msg
viewTiles model =
    div [ class "tiles" ] (List.map viewTile model.tiles)


viewTile : String -> Html msg
viewTile letter =
    div [ class "tile" ]
        [ text letter ]
