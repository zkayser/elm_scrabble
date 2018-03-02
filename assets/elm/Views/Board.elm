module Views.Board exposing (..)

import Data.Grid as Grid exposing (Grid)
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events


view : { r | grid : Grid, dragDropMsg : subMsg } -> Html msg
view model =
    let
        cellsWithMsg =
            List.map (\cell -> ( model.dragDropMsg, cell )) model.grid
    in
    div [ Attributes.class "board" ] <|
        List.map Grid.cellToHtml cellsWithMsg
