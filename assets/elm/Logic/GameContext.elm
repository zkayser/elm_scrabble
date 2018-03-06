module Logic.GameContext exposing (..)

import Data.Grid as Grid exposing (Grid, Position, Tile)
import Types.Playable as Playable exposing (Playable)


type alias Context =
    { grid : Grid
    , tilesPlayed : List Tile
    , playable : List Playable
    }


type alias Move =
    { tile : Tile
    , position : Position
    }


type Turn
    = Ready Context
    | OneTilePlayed Context
    | MultipleTilesPlayed Context


update : Turn -> Move -> Turn
update turn move =
    case turn of
        Ready context ->
            let
                grid =
                    context.grid

                maybeCell =
                    List.filter (\cell -> cell.position == move.position) grid
                        |> List.head

                currentTurnState =
                    Ready context
            in
            case maybeCell of
                Just cell ->
                    case cell.tile of
                        Nothing ->
                            let
                                newCell =
                                    { cell | tile = Just move.tile }

                                newGrid =
                                    List.map
                                        (\gridCell ->
                                            if gridCell.position == move.position then
                                                newCell
                                            else
                                                gridCell
                                        )
                                        grid

                                ( row, column ) =
                                    move.position
                            in
                            OneTilePlayed { grid = newGrid, tilesPlayed = [ move.tile ], playable = [ Playable.Row row, Playable.Column column ] }

                        Just cell ->
                            currentTurnState

                Nothing ->
                    currentTurnState

        OneTilePlayed context ->
            case isMovePlayable context move of
                True ->
                    let
                        newTilesPlayed =
                            move.tile :: context.tilesPlayed

                        updatedGrid =
                            List.map
                                (\cell ->
                                    if cell.position == move.position then
                                        { cell | tile = Just move.tile }
                                    else
                                        cell
                                )
                                context.grid

                        playables =
                            getPlayableForPosition move.position context.playable
                    in
                    MultipleTilesPlayed { context | grid = updatedGrid, tilesPlayed = newTilesPlayed, playable = playables }

                False ->
                    OneTilePlayed context

        MultipleTilesPlayed context ->
            case isMovePlayable context move of
                True ->
                    let
                        newTilesPlayed =
                            move.tile :: context.tilesPlayed

                        updatedGrid =
                            List.map
                                (\cell ->
                                    if cell.position == move.position then
                                        { cell | tile = Just move.tile }
                                    else
                                        cell
                                )
                                context.grid

                        playables =
                            getPlayableForPosition move.position context.playable
                    in
                    MultipleTilesPlayed { grid = updatedGrid, tilesPlayed = newTilesPlayed, playable = playables }

                False ->
                    MultipleTilesPlayed context


isMovePlayable : Context -> Move -> Bool
isMovePlayable context move =
    let
        ( row, column ) =
            move.position
    in
    case context.playable of
        [ Playable.AllValid ] ->
            moveIsNotOverLapping context move

        [ Playable.Row r, Playable.Column c ] ->
            (r == row || c == column) && moveIsNotOverLapping context move

        [ Playable.Row r ] ->
            r == row && moveIsNotOverLapping context move

        [ Playable.Column c ] ->
            c == column && moveIsNotOverLapping context move

        _ ->
            False


moveIsNotOverLapping : Context -> Move -> Bool
moveIsNotOverLapping context move =
    case List.filter (\cell -> cell.position == move.position) context.grid of
        [ cell ] ->
            cell.tile == Nothing

        _ ->
            False


getPlayableForPosition : Position -> List Playable -> List Playable
getPlayableForPosition ( row, column ) playables =
    case playables of
        [ Playable.Row r, Playable.Column c ] ->
            if row == r then
                [ Playable.Row row ]
            else if column == c then
                [ Playable.Column column ]
            else
                playables

        [ Playable.Row r ] ->
            if row == r then
                [ Playable.Row row ]
            else
                playables

        [ Playable.Column c ] ->
            if column == c then
                [ Playable.Column column ]
            else
                playables

        [ Playable.AllValid ] ->
            [ Playable.Row row, Playable.Column column ]

        _ ->
            playables
