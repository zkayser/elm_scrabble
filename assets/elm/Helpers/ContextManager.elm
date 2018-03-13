module Helpers.ContextManager exposing (..)

import Data.Grid as Grid exposing (Tile)
import Data.Move as Move
import Http
import Logic.GameContext as Context exposing (Context)
import Logic.Validator as Validator exposing (ValidatorState(..))
import Requests.ScrabbleApi as Api


{-| This function can fail if an invalid play is attempted.
To account for this, a `Result String (Context, Cmd msg, List Tile )`
type is returned so that the caller of the function can react
accordingly.
-}
updateContext : (Result Http.Error Int -> msg) -> List Tile -> Context -> Result String ( Context, Cmd msg, List Tile )
updateContext msg tiles context =
    let
        validation =
            Move.validate context.movesMade
                |> Grid.get context.grid
                |> Validator.validate context.movesMade
    in
    case validation of
        Validated play ->
            let
                tilesNeeded =
                    7 - List.length context.tiles

                newPlayerTiles =
                    List.take tilesNeeded tiles

                newTileBag =
                    List.drop tilesNeeded tiles
            in
            Ok ( { context | movesMade = [], tiles = newPlayerTiles ++ context.tiles }, Http.send msg (Api.getScore play), newTileBag )

        _ ->
            Err "Invalid play"
