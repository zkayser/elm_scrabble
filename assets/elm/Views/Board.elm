module Views.Board exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Data.Position exposing (Position)

view : model -> Html msg
view model =
  div [ Attributes.class "board" ]
    <| List.map (viewCell model) positionList

viewCell : model -> Position -> Html msg
viewCell model position =
  let
    displayText =
      case position of
        ( 8, 8 ) -> "★"
        _ -> ""
  in
  div
    [ Attributes.class <| "cell " ++ (toString position)
    , Attributes.classList [ ("double-word", position == (8, 8)) ]
    ]
    [ text displayText ]

positionList : List Position
positionList =
  List.map positionFor (List.range 1 225)

positionFor : Int -> Position
positionFor number =
  let
    row =
      if isMultipleOf15 number then number // 15 else ceiling <| (toFloat number) / 15
    column =
      if isMultipleOf15 number then 15 else rem number 15
  in
  ( row, column )

isMultipleOf15 : Int -> Bool
isMultipleOf15 number =
  (rem number 15) == 0
