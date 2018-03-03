module Views.TileHolder exposing (..)

import Data.Grid as Grid exposing (Tile)
import Html exposing (..)
import Html.Attributes as Attributes exposing (class)
import Html.Events as Events exposing (on)


view : { r | tiles : List Tile } -> Html msg
view model =
    div [ class "tileholder" ]
        [ viewTiles model ]


viewTiles : { r | tiles : List Tile } -> Html msg
viewTiles model =
    div [ class "tiles" ] (List.map viewTile model.tiles)


viewTile : Tile -> Html msg
viewTile tile =
    div [ class "tile" ]
        [ text tile.letter ]
