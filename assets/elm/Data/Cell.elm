module Data.Cell exposing (Cell, view)

import Data.Multiplier as Multiplier exposing (Multiplier)
import Data.Position exposing (Position)
import Data.Tile as Tile exposing (Tile)
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Widgets.DragAndDrop exposing (Config, droppable, draggable)


type alias Cell =
    { position : Position
    , multiplier : Multiplier
    , tile : Maybe Tile
    , isCenter : Bool
    }

view : Config msg Tile Cell -> Cell -> List Tile -> Html msg
view config cell retiredTiles =
    let
        dropConfig =
            droppable (config.dropMsg cell) (config.dragOverMsg cell)
    in
    case cell.tile of
        Just tile ->
            case List.member tile retiredTiles of
                False ->
                    Tile.view config tile

                True ->
                    Tile.disable tile

        _ ->
            case cell.multiplier of
                Multiplier.DoubleWord ->
                    if cell.isCenter then
                        div ([ class "cell double-word center-tile" ] ++ dropConfig)
                            [ img [ class "center-logo", src "images/glogo.png" ] []
                            ]

                    else
                        div ([ class "cell double-word" ] ++ dropConfig) [ text "2x W" ]

                Multiplier.TripleWord ->
                    div ([ class "cell triple-word" ] ++ dropConfig) [ text "3x W" ]

                Multiplier.DoubleLetter ->
                    div ([ class "cell double-letter" ] ++ dropConfig) [ text "2x L" ]

                Multiplier.TripleLetter ->
                    div ([ class "cell triple-letter" ] ++ dropConfig) [ text "3x L" ]

                _ ->
                    div ([ class "cell" ] ++ dropConfig) [ text "" ]