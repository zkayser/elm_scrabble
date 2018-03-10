module Views.Scoreboard exposing (view)

import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events


type alias Model r =
    { r
        | score : Int
    }


view : msg -> Model r -> Html msg
view submitMsg model =
    div []
        [ h1 [ Attributes.class "scoreboard-header" ] [ text "Scoreboard" ]
        , div [ Attributes.class "score-display" ]
            [ h1 [ Attributes.class "score" ] [ text <| toString model.score ] ]
        , div [ Attributes.class "submit-row" ]
            [ a
                [ Attributes.class "btn submit-btn"
                , Events.onClick submitMsg
                ]
                [ text "Get Score" ]
            ]
        ]
