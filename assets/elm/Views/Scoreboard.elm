module Views.Scoreboard exposing (view)

import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Types.Messages as Message exposing (Message)


type alias Model r =
    { r
        | score : Int
        , messages : List Message
    }


view : msg -> Model r -> Html msg
view submitMsg model =
    div []
        [ div [ Attributes.class "message-container" ]
            (viewErrorMessages model.messages)
        , h1 [ Attributes.class "scoreboard-header" ] [ text "Scoreboard" ]
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


viewErrorMessages : List Message -> List (Html msg)
viewErrorMessages messages =
    List.map (\message -> viewError message) messages


viewError : Message -> Html msg
viewError message =
    case message of
        ( Message.Error, messageText ) ->
            div [ Attributes.class "error" ] [ text messageText ]

        _ ->
            text ""
