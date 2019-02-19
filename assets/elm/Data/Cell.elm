module Data.Cell exposing (Cell, decode, view)

import Data.Multiplier as Multiplier exposing (Multiplier)
import Data.Position as Position exposing (Position)
import Data.Tile as Tile exposing (Tile)
import Html exposing (..)
import Html.Attributes exposing (class, classList, src)
import Json.Decode as Decode exposing (Decoder)
import Widgets.DragAndDrop exposing (Config, draggable, droppable)


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
            div ([ conditionalClassesFor cell ] ++ dropConfig) [ markupFor cell ]



-- View Helpers


conditionalClassesFor : Cell -> Html.Attribute msg
conditionalClassesFor cell =
    classList
        [ ( "cell", True )
        , ( "center-tile", cell.isCenter )
        , ( "double-word", cell.multiplier == Multiplier.DoubleWord )
        , ( "triple-word", cell.multiplier == Multiplier.TripleWord )
        , ( "double-letter", cell.multiplier == Multiplier.DoubleLetter )
        , ( "triple-letter", cell.multiplier == Multiplier.TripleLetter )
        ]


markupFor : Cell -> Html msg
markupFor cell =
    case ( cell.isCenter, cell.multiplier ) of
        ( True, _ ) ->
            img [ class "center-logo", src "images/glogo.png" ] []

        ( _, Multiplier.DoubleWord ) ->
            text "2x W"

        ( _, Multiplier.TripleWord ) ->
            text "3x W"

        ( _, Multiplier.DoubleLetter ) ->
            text "2x L"

        ( _, Multiplier.TripleLetter ) ->
            text "3x L"

        ( _, _ ) ->
            text ""



{- Serialization -}


decode : Decoder Cell
decode =
    Decode.map4 Cell
        (Decode.field "position" Position.decode)
        (Decode.field "multiplier" Multiplier.decode)
        decodeMaybeTile
        decodeIsCenter


decodeMaybeTile : Decoder (Maybe Tile)
decodeMaybeTile =
    Decode.oneOf
        [ Decode.maybe <| Decode.field "tile" Tile.decode
        , Decode.succeed Nothing
        ]


decodeIsCenter : Decoder Bool
decodeIsCenter =
    Decode.field "position" Position.decode
        |> Decode.andThen isCenter


isCenter : Position -> Decoder Bool
isCenter position =
    if position == ( 8, 8 ) then
        Decode.succeed True

    else
        Decode.succeed False
