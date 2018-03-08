module Views.Board exposing (..)

import Data.Grid as Grid exposing (Cell, Grid, Tile)
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Logic.GameContext exposing (Context)
import Widgets.DragAndDrop exposing (Config)


type alias Model r msg =
    { r
        | context : Context
        , dragAndDropConfig : Config msg Tile Cell
    }


view : Model r msg -> Html msg
view model =
    div [ Attributes.class "board" ] <|
        List.map (\cell -> Grid.cellToHtml model.dragAndDropConfig cell) model.context.grid
