module Data.Grid exposing (Dimension(..), Grid, center, doubleLetterPositions, doubleWordPositions, get, init, initialCellForPosition, isMultipleOf15, multiplierFor, positionFor, positionList, tripleLetterPositions, tripleWordPositions)

import Data.Cell exposing (Cell)
import Data.Multiplier exposing (Multiplier(..))
import Data.Position exposing (Position)
import Data.Tile as Tile exposing (Tile)
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Widgets.DragAndDrop exposing (Config, draggable, droppable)


type alias Grid =
    List Cell


type Dimension
    = Row Int
    | Column Int
    | Invalid


init : Grid
init =
    List.map initialCellForPosition <| List.range 1 225


initialCellForPosition : Int -> Cell
initialCellForPosition number =
    let
        position =
            positionFor number

        multiplier =
            multiplierFor position
    in
    { position = position, multiplier = multiplier, tile = Nothing, isCenter = position == center }


positionList : List Position
positionList =
    List.map positionFor (List.range 1 225)


positionFor : Int -> Position
positionFor number =
    let
        row =
            if isMultipleOf15 number then
                number // 15

            else
                ceiling <| toFloat number / 15

        column =
            if isMultipleOf15 number then
                15

            else
                remainderBy 15 number
    in
    ( row, column )


isMultipleOf15 : Int -> Bool
isMultipleOf15 number =
    remainderBy 15 number == 0


multiplierFor : Position -> Multiplier
multiplierFor position =
    if List.member position tripleWordPositions then
        TripleWord

    else if List.member position doubleWordPositions then
        DoubleWord

    else if List.member position tripleLetterPositions then
        TripleLetter

    else if List.member position doubleLetterPositions then
        DoubleLetter

    else
        NoMultiplier


center : Position
center =
    ( 8, 8 )


tripleWordPositions : List Position
tripleWordPositions =
    [ ( 1, 1 ), ( 1, 8 ), ( 1, 15 ), ( 8, 1 ), ( 8, 15 ), ( 15, 1 ), ( 15, 8 ), ( 15, 15 ) ]


doubleWordPositions : List Position
doubleWordPositions =
    [ ( 2, 2 )
    , ( 3, 3 )
    , ( 4, 4 )
    , ( 5, 5 )
    , ( 8, 8 )
    , ( 11, 11 )
    , ( 12, 12 )
    , ( 13, 13 )
    , ( 14, 14 )
    , ( 2, 14 )
    , ( 3, 13 )
    , ( 4, 12 )
    , ( 5, 11 )
    , ( 11, 5 )
    , ( 12, 4 )
    , ( 13, 3 )
    , ( 14, 2 )
    ]


tripleLetterPositions : List Position
tripleLetterPositions =
    [ ( 2, 6 )
    , ( 6, 6 )
    , ( 10, 6 )
    , ( 14, 6 )
    , ( 2, 10 )
    , ( 6, 10 )
    , ( 10, 10 )
    , ( 14, 10 )
    , ( 6, 2 )
    , ( 10, 2 )
    , ( 6, 14 )
    , ( 10, 14 )
    ]


doubleLetterPositions : List Position
doubleLetterPositions =
    [ ( 1, 4 )
    , ( 1, 12 )
    , ( 3, 7 )
    , ( 3, 9 )
    , ( 4, 1 )
    , ( 4, 8 )
    , ( 4, 15 )
    , ( 7, 3 )
    , ( 7, 7 )
    , ( 7, 9 )
    , ( 7, 13 )
    , ( 8, 4 )
    , ( 8, 12 )
    , ( 9, 3 )
    , ( 9, 7 )
    , ( 9, 9 )
    , ( 9, 13 )
    , ( 12, 1 )
    , ( 12, 8 )
    , ( 12, 15 )
    , ( 13, 7 )
    , ( 13, 9 )
    , ( 15, 4 )
    , ( 15, 12 )
    ]


{-| Grabs either a row or a column of the
grid. Returns the entire grid unmodified
if the dimension given is `Invalid`
-}
get : Grid -> Dimension -> List Cell
get grid dimension =
    case dimension of
        Invalid ->
            []

        Row row ->
            List.filter (\cell -> Tuple.first cell.position == row) grid

        Column column ->
            List.filter (\cell -> Tuple.second cell.position == column) grid
