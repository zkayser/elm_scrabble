module Main exposing (..)

import Data.Grid as Grid exposing (Cell, Grid, Tile)
import Helpers.TileManager as TileManager exposing (generateTileBag, shuffleTileBag)
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Json
import Task
import Time exposing (Time)
import Views.Board as Board
import Views.TileHolder as TileHolder
import Widgets.DragAndDrop as DragAndDrop exposing (Config)


type alias Model =
    { grid : Grid
    , tiles : List Tile
    , tileBag : List Tile
    , dragAndDropConfig : DragAndDrop.Config Msg Tile Cell
    , dragging : Maybe Tile
    , tilesPlayed : List Tile
    }


type Msg
    = CurrentTime Time
    | DragStarted Tile
    | DragEnd
    | Dropped Cell
    | DragOver Cell


init : ( Model, Cmd Msg )
init =
    ( { grid = Grid.init
      , tileBag = generateTileBag
      , tiles = []
      , dragAndDropConfig = dragAndDropConfig
      , dragging = Nothing
      , tilesPlayed = []
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

        DragStarted tile ->
            ( { model | dragging = Just tile }, Cmd.none )

        DragEnd ->
            ( { model | dragging = Nothing }, Cmd.none )

        Dropped cell ->
            let
                newCell =
                    { cell | tile = model.dragging }

                newGrid =
                    List.map
                        (\gridCell ->
                            if gridCell.position == newCell.position then
                                newCell
                            else
                                gridCell
                        )
                        model.grid

                ( newTiles, newTilesPlayed ) =
                    case model.dragging of
                        Nothing ->
                            ( model.tiles, model.tilesPlayed )

                        Just tile ->
                            ( List.filter (\listTile -> listTile /= tile) model.tiles, tile :: model.tilesPlayed )
            in
            ( { model | grid = newGrid, tiles = newTiles, tilesPlayed = newTilesPlayed }, Cmd.none )

        DragOver cell ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ Attributes.class "container" ]
        [ Board.view model
        , TileHolder.view model
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
