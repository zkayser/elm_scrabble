module Main exposing (..)

import Data.Grid as Grid exposing (Cell, Grid, Tile)
import Helpers.TileManager as TileManager exposing (generateTileBag, shuffleTileBag)
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Json
import Logic.GameContext as GameContext exposing (Context, Turn)
import Task
import Time exposing (Time)
import Views.Board as Board
import Views.Scoreboard as Scoreboard
import Views.TileHolder as TileHolder
import Widgets.DragAndDrop as DragAndDrop exposing (Config)


type alias Model =
    { tileBag : List Tile
    , dragAndDropConfig : DragAndDrop.Config Msg Tile Cell
    , dragging : Maybe Tile
    , turn : Turn
    , context : Context
    }


type Msg
    = CurrentTime Time
    | DragStarted Tile
    | DragEnd
    | Dropped Cell
    | DragOver Cell


init : ( Model, Cmd Msg )
init =
    ( { tileBag = generateTileBag
      , dragAndDropConfig = dragAndDropConfig
      , dragging = Nothing
      , context = GameContext.init Grid.init []
      , turn = GameContext.Active
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

                turn =
                    GameContext.Active

                context =
                    GameContext.init model.context.grid playerTiles
            in
            ( { model | tileBag = shuffledTiles, turn = turn, context = context }, Cmd.none )

        DragStarted tile ->
            ( { model | dragging = Just tile }, Cmd.none )

        DragEnd ->
            ( { model | dragging = Nothing }, Cmd.none )

        Dropped cell ->
            case model.dragging of
                Just tile ->
                    let
                        newContext =
                            GameContext.update model.turn model.context { tile = tile, position = cell.position }
                    in
                    ( { model | context = newContext }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        DragOver cell ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ Attributes.class "scrabble" ]
        [ div [ Attributes.class "container" ]
            [ Board.view model
            , TileHolder.view model
            ]
        , div [ Attributes.class "scoreboard-container" ]
            [ Scoreboard.view model ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


dragAndDropConfig : DragAndDrop.Config Msg Tile Cell
dragAndDropConfig =
    { dragStartMsg = DragStarted
    , dragEndMsg = DragEnd
    , dropMsg = Dropped
    , dragOverMsg = DragOver
    }


main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
