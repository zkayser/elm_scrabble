module Data.Grid exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, src)


type alias Grid =
    List Cell


type alias Cell =
    { position : Position
    , multiplier : Multiplier
    , tile : Maybe Tile
    , isCenter : Bool
    }


type alias Position =
    ( Int, Int )


type alias Tile =
    { letter : String
    , id : Int
    }


type Multiplier
    = DoubleWord
    | TripleWord
    | DoubleLetter
    | TripleLetter
    | NoMultiplier


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
                rem number 15
    in
    ( row, column )


isMultipleOf15 : Int -> Bool
isMultipleOf15 number =
    rem number 15 == 0


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


cellToHtml : Cell -> Html msg
cellToHtml cell =
    case cell.tile of
        Just tile ->
            tileToHtml tile

        _ ->
            case cell.multiplier of
                DoubleWord ->
                    if cell.isCenter then
                        div [ class <| "cell double-word center-tile" ]
                            [ img [ class <| "center-logo", src "images/glogo.png" ] []
                            ]
                    else
                        div [ class <| "cell double-word" ] [ text "2x W" ]

                TripleWord ->
                    div [ class <| "cell triple-word" ] [ text "3x W" ]

                DoubleLetter ->
                    div [ class <| "cell double-letter" ] [ text "2x L" ]

                TripleLetter ->
                    div [ class <| "cell triple-letter" ] [ text "3x L" ]

                NoMultiplier ->
                    div [ class <| "cell" ] [ text "" ]


tileToHtml : Tile -> Html msg
tileToHtml tile =
    div [ class <| "tile" ] [ text tile.letter ]
