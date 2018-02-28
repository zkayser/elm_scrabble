module Main exposing (..)

import Data.Grid as Grid exposing (Grid)
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Views.Board as Board


type alias Model =
    { grid : Grid }


type Msg
    = NoOp


init : ( Model, Cmd Msg )
init =
    ( { grid = Grid.init }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


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
