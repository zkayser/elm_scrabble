module Views.Board exposing (..)

import Data.Grid as Grid exposing (Grid)
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events


view : { r | grid : Grid } -> Html msg
view model =
    div [ Attributes.class "board" ] <|
        List.map Grid.cellToHtml model.grid
