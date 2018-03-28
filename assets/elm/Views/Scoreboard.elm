module Views.Scoreboard exposing (view)

import Data.Leaderboard exposing (Entry, Leaderboard)
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Types.Messages as Message exposing (Message)


type alias Model r msg =
    { r
        | score : Int
        , messages : List Message
        , leaderboard : Leaderboard
        , discardTilesMsg : msg
        , finishedTurnMsg : msg
    }


view : msg -> Model r msg -> Html msg
view submitMsg model =
    div [ Attributes.class "scoreboard" ]
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
        , div [ Attributes.class "submit-row" ]
            [ a
                [ Attributes.class "btn discard-btn"
                , Events.onClick model.discardTilesMsg
                ]
                [ text "Discard Tiles" ]
            ]
        , div [ Attributes.class "submit-row" ]
            [ a
                [ Attributes.class "btn discard-btn"
                , Events.onClick model.finishedTurnMsg
                ]
                [ text "Quit" ]
            ]
        , viewLeaderboard model
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


viewLeaderboard : Model r msg -> Html msg
viewLeaderboard model =
    let
        leaderboard =
            model.leaderboard
                |> List.sortBy .score
                |> List.reverse
                |> List.indexedMap (,)
    in
    div [ Attributes.class "leaderboard" ]
        [ div [ Attributes.class "leaderboard-header", Attributes.classList [ ( "hidden", List.length leaderboard == 0 ) ] ]
            [ span [ Attributes.class "header rank" ] [ text "RANK" ]
            , span [ Attributes.class "header user" ] [ text "NAME" ]
            , span [ Attributes.class "header score-entry" ] [ text "SCORE" ]
            ]
        , div [ Attributes.class "leaderboard-body" ] <|
            List.map viewEntry leaderboard
        ]


viewEntry : ( Int, Entry ) -> Html msg
viewEntry ( rank, entry ) =
    div [ Attributes.class "leaderboard-entry" ]
        [ span [ Attributes.class "rank" ]
            [ text <| toString (rank + 1) ]
        , span [ Attributes.class "user" ]
            [ text entry.user ]
        , span [ Attributes.class "score-entry" ]
            [ text <| toString entry.score ]
        ]
