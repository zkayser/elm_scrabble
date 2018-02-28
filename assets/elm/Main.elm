module Main exposing (..)

import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Views.Board as Board


type alias Model =
    { greeting : String }


type Msg
    = ShowGreeting
    | ShowAttitude


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


initialModel : Model
initialModel =
    { greeting = "Hello, I will be your default greeting for this app. How may I help you?" }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ShowGreeting ->
            ( { greeting = "Hello, world!" }, Cmd.none )

        ShowAttitude ->
            ( { greeting = "I'm not saying hi to you!" }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ Attributes.class "container" ]
        [ Board.view model ]

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
