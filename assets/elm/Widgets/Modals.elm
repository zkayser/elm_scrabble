module Widgets.Modals exposing (Modal(..), view)

import Data.Grid exposing (Tile)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)


type Modal msg
    = UserPrompt msg (String -> msg)
    | WildcardPrompt msg (String -> msg)
    | None


view : Modal msg -> Html msg
view modal =
    case modal of
        UserPrompt submitMsg inputMsg ->
            div [ class "prompt" ]
                [ Html.form [ onSubmit submitMsg ]
                    [ input
                        [ onInput (\string -> inputMsg string)
                        , placeholder "Please enter a name"
                        ]
                        []
                    , a [ class "btn medium-btn", onClick submitMsg ] [ text "Start Playing" ]
                    ]
                ]

        WildcardPrompt submitMsg inputMsg ->
            div [ class "prompt" ]
                [ Html.form [ onSubmit submitMsg ]
                    [ input
                        [ onInput (\string -> inputMsg string)
                        , placeholder "Enter a letter"
                        ]
                        []
                    , a [ class "btn medium-btn", onClick submitMsg ] [ text "OK" ]
                    ]
                ]

        None ->
            text ""
