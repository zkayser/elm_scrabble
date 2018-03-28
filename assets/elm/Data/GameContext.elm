module Data.GameContext exposing (..)

import Data.Grid as Grid exposing (Grid, Position, Tile)
import Data.Move as Move exposing (Move)


type alias Context =
    { grid : Grid
    , movesMade : List Move
    , tiles : List Tile
    }


type Turn
    = Active
    | Inactive
    | FinishedTurn
    | StartedTurn
    | Initializing


init : Grid -> List Tile -> Context
init grid tiles =
    { grid = grid
    , movesMade = []
    , tiles = tiles
    }


update : Turn -> Context -> Move -> Context
update turn context move =
    case turn of
        Active ->
            case moveIsNotOverLapping context move of
                True ->
                    let
                        newGrid =
                            List.map
                                (\cell ->
                                    if cell.position == move.position then
                                        { cell | tile = Just move.tile }
                                    else if cell.tile == Just move.tile then
                                        { cell | tile = Nothing }
                                    else
                                        cell
                                )
                                context.grid

                        tilesPlayed =
                            List.map (\mv -> mv.tile) context.movesMade

                        newMovesMade =
                            if List.member move.tile tilesPlayed then
                                -- Filter out the old move and add the new one
                                -- to the head of the list
                                -- if the tile had already been played
                                move :: List.filter (\mv -> mv.tile /= move.tile) context.movesMade
                            else
                                move :: context.movesMade

                        newTiles =
                            List.filter (\tile -> tile /= move.tile) context.tiles
                    in
                    { grid = newGrid, movesMade = newMovesMade, tiles = newTiles }

                False ->
                    context

        _ ->
            context


isValidSubmission : Turn -> Context -> Bool
isValidSubmission turn context =
    False


moveIsNotOverLapping : Context -> Move -> Bool
moveIsNotOverLapping context move =
    case List.filter (\cell -> cell.position == move.position) context.grid of
        [ cell ] ->
            cell.tile == Nothing

        _ ->
            False
