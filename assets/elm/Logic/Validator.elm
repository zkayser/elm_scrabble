module Logic.Validator exposing (..)

import Data.Grid exposing (Cell, Multiplier(..), Tile)
import Data.Move exposing (Move)
import Data.ScrabblePlay as ScrabblePlay exposing (Play)


type ValidatorState
    = NoMoveDetected
    | PossibleMoveFound (List Tile)
    | MoveDetected (List Tile)
    | Validated Play
    | Invalidated


{-| Loop over the cells in a row or column
to validate a play attempted by a user.
The function reduces the list of cells
(the row or column) and builds a `ValidatorState`
that will hold an intermediate representation of
possible moves in the list of tiles carried around
by the `PossibleMoveFound` and `MoveDetected` values.
If a move is validated, the tiles are mapped into a
string that represents the word being played. If
the move is not validated, the accumulator value
remains `Invalidated`. If there is no move detected
by the end of the reduction, `Invalidated` is returned.
-}
validate : List Move -> List Cell -> ValidatorState
validate moves cells =
    let
        playedTiles =
            List.map (\move -> move.tile) moves
    in
    List.foldr (\cell state -> updateState playedTiles cell state) NoMoveDetected cells
        |> finalizeState


updateState : List Tile -> Cell -> ValidatorState -> ValidatorState
updateState playedTiles cell currentState =
    case currentState of
        NoMoveDetected ->
            case cell.tile of
                Just tile ->
                    if List.member tile playedTiles then
                        MoveDetected [ { tile | multiplier = cell.multiplier } ]
                    else
                        PossibleMoveFound [ { tile | multiplier = cell.multiplier } ]

                Nothing ->
                    NoMoveDetected

        PossibleMoveFound tiles ->
            case cell.tile of
                Just tile ->
                    if List.member tile playedTiles then
                        MoveDetected <| { tile | multiplier = cell.multiplier } :: tiles
                    else
                        PossibleMoveFound <| { tile | multiplier = cell.multiplier } :: tiles

                Nothing ->
                    NoMoveDetected

        MoveDetected tiles ->
            case cell.tile of
                Just tile ->
                    MoveDetected <| { tile | multiplier = cell.multiplier } :: tiles

                Nothing ->
                    if List.all (\tile -> List.member tile.id (idsFor tiles)) playedTiles then
                        Validated <| ScrabblePlay.tilesToPlay tiles
                    else
                        Invalidated

        Validated word ->
            Validated word

        Invalidated ->
            Invalidated


finalizeState : ValidatorState -> ValidatorState
finalizeState state =
    case state of
        NoMoveDetected ->
            Invalidated

        _ ->
            state


idsFor : List Tile -> List Int
idsFor tiles =
    List.map .id tiles
