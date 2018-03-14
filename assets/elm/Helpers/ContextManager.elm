module Helpers.ContextManager exposing (..)

import Data.Grid as Grid exposing (Tile)
import Data.Move as Move
import Http
import Json.Decode as Decode exposing (Value)
import Logic.GameContext as Context exposing (Context)
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
validateSubmission : (Result Http.Error ScrabbleResponse -> msg) -> Context -> Result String (Cmd msg)
validateSubmission msg context =
    let
        validation =
            Move.validate context.movesMade
                |> Grid.get context.grid
                |> Validator.validate context.movesMade
    in
    case validation of
        Validated play ->
            Ok (Http.send msg (Api.getScore play))

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
