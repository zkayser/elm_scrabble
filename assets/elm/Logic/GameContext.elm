module Logic.GameContext exposing (..)

import Data.Grid as Grid exposing (Grid, Position, Tile)


type alias Context =
    { grid : Grid
    , movesMade : List Move
    , tiles : List Tile
    }


type alias Move =
    { tile : Tile
    , position : Position
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
            let
                newGrid =
                    case moveIsNotOverLapping context move of
                        True ->
                            List.map
                                (\cell ->
                                    if cell.position == move.position then
                                        { cell | tile = Just move.tile }
                                    else
                                        cell
                                )
                                context.grid

                        False ->
                            context.grid
            in
            { grid = newGrid, movesMade = move.tile :: context.movesMade, tiles = context.tiles }

        StartedTurn ->
            { grid = context.grid, movesMade = [], tiles = context.tiles }

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
