module Main exposing (..)

import Data.Grid as Grid exposing (Grid, Tile)
import Helpers.TileManager as TileManager exposing (generateTileBag, shuffleTileBag)
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Json
import Task
import Time exposing (Time)
import Views.Board as Board
import Views.TileHolder as TileHolder


type alias Model =
    { grid : Grid
    , tiles : List Tile
    , tileBag : List Tile
    }


type Msg
    = CurrentTime Time


init : ( Model, Cmd Msg )
init =
    ( { grid = Grid.init
      , tileBag = generateTileBag
      , tiles = []
      }
    , Task.perform CurrentTime Time.now
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CurrentTime time ->
            let
                shuffledTiles =
                    shuffleTileBag model.tileBag time

                playerTiles =
                    List.take 7 shuffledTiles
            in
            ( { model | tileBag = shuffledTiles, tiles = playerTiles }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ Attributes.class "container" ]
        [ Board.view model
        , TileHolder.view model
        ]


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
