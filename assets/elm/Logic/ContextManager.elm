module Logic.ContextManager exposing (..)

import Channels.LeaderboardChannel as Leaderboard
import Data.GameContext as Context exposing (Context)
import Data.Grid as Grid exposing (Tile)
import Data.Move as Move
import Http
import Json.Decode as Decode exposing (Value)
import Logic.Validator as Validator exposing (ValidatorState(..))
import Requests.ScrabbleApi as Api
import Responses.Scrabble as ScrabbleResponse exposing (ScrabbleResponse)
import Types.Messages as Message exposing (Message)


type alias Model r =
    { r
        | score : Int
        , context : Context
        , tileBag : List Tile
        , messages : List Message
    }


{-| This function can fail if an invalid play is attempted.
To account for this, a `Result String (Context, Cmd msg, List Tile )`
type is returned so that the caller of the function can react
accordingly.
-}
validateSubmission : (Value -> msg) -> Context -> Result String (Cmd msg)
validateSubmission msg context =
    case Validator.validateV2 (Move.validate context.movesMade) context of
        Validated play ->
            Ok (Leaderboard.submitPlay play)

        _ ->
            Err "Invalid play"


update : ScrabbleResponse -> Model r -> Model r
update scrabbleResponse model =
    case scrabbleResponse.score of
        Just score ->
            let
                tilesNeeded =
                    7 - List.length model.context.tiles

                ( newTiles, newTileBag ) =
                    ( List.take tilesNeeded model.tileBag, List.drop tilesNeeded model.tileBag )

                context =
                    model.context

                newContext =
                    { context | tiles = newTiles ++ context.tiles, movesMade = [] }
            in
            { model | score = model.score + score, context = newContext, tileBag = newTileBag }

        Nothing ->
            case scrabbleResponse.error of
                Just message ->
                    { model | messages = ( Message.Error, message ) :: model.messages }

                _ ->
                    { model | messages = ( Message.Error, "Something went wrong" ) :: model.messages }


updateContextWith : Tile -> String -> { r | context : Context } -> Context
updateContextWith tile letter model =
    let
        context =
            model.context
    in
    case tile.multiplier of
        Grid.Wildcard ->
            let
                formattedLetter =
                    String.reverse letter
                        |> String.slice 0 1
                        |> String.toUpper

                newGrid =
                    List.map
                        (\cell ->
                            if cell.tile == Just tile then
                                { cell | tile = Just { tile | letter = formattedLetter } }
                            else
                                cell
                        )
                        context.grid

                movesMade =
                    List.map
                        (\move ->
                            if move.tile == tile then
                                { move | tile = { tile | letter = formattedLetter } }
                            else
                                move
                        )
                        context.movesMade
            in
            { context | grid = newGrid, movesMade = movesMade }

        _ ->
            context
