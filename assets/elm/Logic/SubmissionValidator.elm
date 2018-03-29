module Logic.SubmissionValidator exposing (validateSubmission)

import Channels.LeaderboardChannel as Leaderboard
import Data.GameContext as Context exposing (Context)
import Data.Grid as Grid exposing (Cell, Grid, Position, Tile)
import Data.Move as Move
import Json.Decode exposing (Value)
import Logic.Validator as Validator exposing (ValidatorState(..))


type ContextError
    = CenterNotPlayed
    | FloatingTile
    | NoError


{-| This function can fail if an invalid play is attempted.
To account for this, a `Result String (Context, Cmd msg, List Tile )`
type is returned so that the caller of the function can react
accordingly.
-}
validateSubmission : (Value -> msg) -> Context -> Result String (Cmd msg)
validateSubmission msg context =
    case errors context of
        CenterNotPlayed ->
            Err "You must play a tile on the center piece"

        FloatingTile ->
            Err "You must place your tiles in sequence"

        NoError ->
            case Validator.validate (Move.validate context.movesMade) context of
                Validated play ->
                    Ok (Leaderboard.submitPlay play)

                _ ->
                    Err "Invalid play"



-- INTERNAL


errors : Context -> ContextError
errors context =
    if not <| isCenterPlayed context then
        CenterNotPlayed
    else if isFloatingTile context then
        FloatingTile
    else
        NoError


isCenterPlayed : Context -> Bool
isCenterPlayed context =
    let
        list =
            List.filter (\cell -> cell.isCenter) context.grid
    in
    case list of
        center :: tail ->
            center.tile /= Nothing

        _ ->
            False


isFloatingTile : Context -> Bool
isFloatingTile context =
    if List.length context.movesMade > 1 then
        False
    else
        case List.head context.movesMade of
            Just move ->
                (not <| hasNeighbor move.position context.grid) && (move.position /= ( 8, 8 ))

            _ ->
                False


hasNeighbor : Grid.Position -> Grid.Grid -> Bool
hasNeighbor position grid =
    (List.length <| List.filterMap (hasNeighboringTile position) grid) > 0


hasNeighboringTile : Grid.Position -> Grid.Cell -> Maybe Grid.Position
hasNeighboringTile ( row, col ) cell =
    if List.member cell.position [ ( row + 1, col ), ( row - 1, col ), ( row, col + 1 ), ( row, col - 1 ) ] then
        case cell.tile of
            Just tile ->
                Just cell.position

            Nothing ->
                Nothing
    else
        Nothing
