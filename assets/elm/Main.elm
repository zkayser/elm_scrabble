module Main exposing (Model, Msg(..), dragAndDropConfig, init, main, showModal, subscriptions, update, view)

import Browser
import Channels.LeaderboardChannel as LeaderboardChannel
import Data.GameContext as GameContext exposing (Context, Turn)
import Data.Grid as Grid exposing (Cell, Grid, Tile)
import Data.Leaderboard as Leaderboard exposing (Leaderboard)
import Data.Move as Move
import Html exposing (..)
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode as Json
import Json.Encode as Encode
import Logic.ContextManager as ContextManager
import Logic.SubmissionValidator as SubmissionValidator
import Logic.TileManager as TileManager exposing (generateTileBag, shuffleTileBag)
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Socket as Socket exposing (Socket)
import Requests.ScrabbleApi as ScrabbleApi
import Responses.Scrabble as ScrabbleResponse exposing (ScrabbleResponse)
import Task
import Time exposing (Posix)
import Types.Messages as Message exposing (Message)
import Views.Board as Board
import Views.Scoreboard as Scoreboard
import Views.TileHolder as TileHolder
import Widgets.DragAndDrop as DragAndDrop exposing (Config)
import Widgets.Modals as Modal exposing (Modal)


type alias Model =
    { tileBag : List Tile
    , dragAndDropConfig : DragAndDrop.Config Msg Tile Cell
    , dragging : Maybe Tile
    , leaderboard : Leaderboard
    , channels : List (Channel Msg)
    , turn : Turn
    , context : Context
    , score : Int
    , retiredTiles : List Tile
    , messages : List Message
    , username : String
    , modal : Modal Msg
    , discardTilesMsg : Msg
    , finishedTurnMsg : Msg
    , socket : Socket Msg
    }


type Msg
    = CurrentTime Posix
    | ClearMessages Posix
    | ChannelMsg Json.Value
    | DiscardTiles
    | DragStarted Tile
    | DragEnd
    | Dropped Cell
    | DragOver Cell
    | FinishTurn
    | TileHolderDrop
    | TileHolderDragover
    | JoinedChannel Json.Value
    | SocketCreated Json.Value
    | SocketOpened Json.Value
    | UpdateLeaderboard Json.Value
    | UpdateScore Json.Value
    | SubmitScore
    | SubmitForm
    | SetUsername String
    | SetWildcardLetter Tile String
    | SocketConnect


init : Json.Value -> ( Model, Cmd Msg )
init flags =
    ( { tileBag = generateTileBag
      , dragAndDropConfig = dragAndDropConfig
      , dragging = Nothing
      , leaderboard = []
      , channels = []
      , context = GameContext.init Grid.init []
      , turn = GameContext.Active
      , score = 0
      , retiredTiles = []
      , messages = []
      , username = ""
      , modal = Modal.UserPrompt SubmitForm SetUsername
      , finishedTurnMsg = FinishTurn
      , discardTilesMsg = DiscardTiles
      , socket = Socket.init "/socket" |> Socket.withOnOpen SocketOpened |> Socket.named "scrabbleSocket"
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

                newTileBag =
                    List.drop 7 shuffledTiles

                turn =
                    GameContext.Active

                context =
                    GameContext.init model.context.grid playerTiles
            in
            ( { model | tileBag = newTileBag, turn = turn, context = context }, Cmd.none )

        ClearMessages _ ->
            let
                newMessages =
                    case model.messages of
                        [] ->
                            []

                        message :: messages ->
                            messages
            in
            ( { model | messages = newMessages }, Cmd.none )

        ChannelMsg value ->
            ( model, Channel.command value model.channels )

        DiscardTiles ->
            let
                updates =
                    ContextManager.discardTiles model
            in
            ( { model | context = updates.context, messages = updates.messages, tileBag = updates.tileBag }, Cmd.none )

        DragStarted tile ->
            ( { model | dragging = Just tile }, Cmd.none )

        DragEnd ->
            ( { model | dragging = Nothing }, Cmd.none )

        Dropped cell ->
            case model.dragging of
                Just tile ->
                    let
                        newModal =
                            case tile.multiplier of
                                Grid.Wildcard ->
                                    Modal.WildcardPrompt SubmitForm (SetWildcardLetter tile)

                                _ ->
                                    Modal.None

                        newContext =
                            GameContext.update model.turn model.context { tile = tile, position = cell.position }
                    in
                    ( { model | context = newContext, modal = newModal }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        DragOver cell ->
            ( model, Cmd.none )

        FinishTurn ->
            ( { model | turn = GameContext.Inactive }, Cmd.none )

        TileHolderDrop ->
            case model.dragging of
                Just tile ->
                    let
                        updates =
                            TileManager.handleDrop model
                    in
                    ( { model | context = updates.context }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        TileHolderDragover ->
            ( model, Cmd.none )

        SubmitScore ->
            case SubmissionValidator.validateSubmission UpdateScore model.context of
                Ok cmd ->
                    ( model, cmd )

                Err message ->
                    ( { model | messages = [ ( Message.Error, message ) ] }, Cmd.none )

        SubmitForm ->
            let
                encodedSocket =
                    Socket.encode model.socket
            in
            ( { model | modal = Modal.None }, Socket.createSocket encodedSocket )

        SetUsername string ->
            ( { model | username = string }, Cmd.none )

        SetWildcardLetter tile letter ->
            let
                updatedContext =
                    ContextManager.updateContextWith tile letter model
            in
            ( { model | context = updatedContext }, Cmd.none )

        UpdateLeaderboard payload ->
            case Json.decodeValue Leaderboard.decoder payload of
                Ok result ->
                    ( { model | leaderboard = result }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        UpdateScore payload ->
            case Json.decodeValue ScrabbleResponse.decoder payload of
                Ok response ->
                    let
                        updates =
                            ContextManager.update response model
                    in
                    ( { model | score = updates.score, context = updates.context, tileBag = updates.tileBag, messages = updates.messages, retiredTiles = updates.retiredTiles }, Cmd.none )

                Err _ ->
                    ( { model | messages = ( Message.Error, "Something went wrong" ) :: model.messages }, Cmd.none )

        SocketOpened value ->
            let
                channel =
                    Channel.init model.socket "scrabble:lobby"
                        |> Channel.withPayload (Encode.object [ ( "user", Encode.string model.username ) ])
                        |> Channel.on "update" UpdateLeaderboard
                        |> Channel.on "score_update" UpdateScore
            in
            ( { model | channels = [ channel ] }, Channel.createChannel <| Channel.encode channel )

        SocketConnect ->
            ( model, Cmd.none )

        SocketCreated value ->
            ( model, Cmd.none )

        JoinedChannel _ ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "Elm Scrabble"
    , body =
        [ div [ Attributes.class "scrabble" ]
            [ div [ Attributes.class "container" ]
                [ Board.view model
                , TileHolder.view TileHolderDrop TileHolderDragover model
                ]
            , div [ Attributes.class "scoreboard-container" ]
                [ Scoreboard.view SubmitScore model ]
            , div
                [ Attributes.classList
                    [ ( "modal-container", showModal model )
                    , ( "hidden", not (showModal model) )
                    ]
                ]
                [ Modal.view model.modal ]
            ]
        ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        clearMessages =
            case model.messages of
                [] ->
                    Sub.none

                _ ->
                    Time.every 3000 ClearMessages
    in
    Sub.batch <| [ clearMessages, Socket.subscriptions model.socket ] ++ List.map (Channel.subscriptions ChannelMsg) model.channels


dragAndDropConfig : DragAndDrop.Config Msg Tile Cell
dragAndDropConfig =
    { dragStartMsg = DragStarted
    , dragEndMsg = DragEnd
    , dropMsg = Dropped
    , dragOverMsg = DragOver
    }


showModal : Model -> Bool
showModal model =
    case model.modal of
        Modal.None ->
            False

        _ ->
            True


main : Program Json.Value Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
