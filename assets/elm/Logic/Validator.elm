module Logic.Validator exposing (ValidatorState(..), validate)

import Data.Cell exposing (Cell)
import Data.GameContext exposing (Context)
import Data.Grid as Grid
import Data.Move exposing (Move)
import Data.ScrabblePlay as ScrabblePlay exposing (Play)
import Data.Tile exposing (Tile)


type ValidatorState
    = NoMoveDetected
    | PossibleMoveFound (List Tile)
    | MoveDetected (List Tile)
    | Validated (List Play)
    | Invalidated


validate : Grid.Dimension -> Context -> ValidatorState
validate dimension context =
    case dimension of
        Grid.Invalid ->
            Invalidated

        _ ->
            case handleValidate context.movesMade (Grid.get context.grid dimension) of
                Validated play ->
                    let
                        secondaryPlays =
                            validateSecondary context <| getSecondaryDimensionsFor dimension context.movesMade
                    in
                    Validated <| play ++ secondaryPlays

                _ ->
                    Invalidated



-- INTERNAL


{-| Loop over the cells in a row or column
to validate a play attempted by a user.
The function reduces the list of cells
(the row or column) and builds a `ValidatorState`
that will hold an intermediate representation of
possible moves in the list of tiles carried around
by the `PossibleMoveFound` and `MoveDetected` values.
If a move is validated, the tiles are mapped into a
`Play` record representing the data structure that
will be sent to the server. If the move is not
validated, the accumulator value remains `Invalidated`.
If there is no move detected by the end of the fold,
`Invalidated` is returned.
-}
handleValidate : List Move -> List Cell -> ValidatorState
handleValidate moves cells =
    let
        playedTiles =
            List.map (\move -> move.tile) moves
    in
    List.foldr (updateState playedTiles) NoMoveDetected cells
        |> finalizeState playedTiles


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
                        Validated <| handleValidationForPlay tiles cell

                    else
                        Invalidated

        Validated word ->
            Validated word

        Invalidated ->
            Invalidated


validateSecondary : Context -> List Grid.Dimension -> List Play
validateSecondary context dimensions =
    List.foldr (\dimension scrabblePlays -> List.append scrabblePlays (secondaryFor context dimension)) [] dimensions


secondaryFor : Context -> Grid.Dimension -> List Play
secondaryFor context dimension =
    case dimension of
        Grid.Row row ->
            case handleValidate (List.filter (\move -> Tuple.first move.position == row) context.movesMade) (Grid.get context.grid dimension) of
                Validated plays ->
                    List.filter (\play -> String.length play.word > 1) plays

                _ ->
                    []

        Grid.Column column ->
            case handleValidate (List.filter (\move -> Tuple.second move.position == column) context.movesMade) (Grid.get context.grid dimension) of
                Validated plays ->
                    List.filter (\play -> String.length play.word > 1) plays

                _ ->
                    []

        _ ->
            []


finalizeState : List Tile -> ValidatorState -> ValidatorState
finalizeState playedTiles state =
    case state of
        NoMoveDetected ->
            Invalidated

        MoveDetected tiles ->
            if List.all (\tile -> List.member tile.id (idsFor tiles)) playedTiles then
                Validated <| List.filter (\play -> String.length play.word > 1) [ ScrabblePlay.tilesToPlay tiles ]

            else
                Invalidated

        _ ->
            state


idsFor : List Tile -> List Int
idsFor tiles =
    List.map .id tiles


handleValidationForPlay : List Tile -> Cell -> List Play
handleValidationForPlay tiles cell =
    case tiles of
        [ tile ] ->
            if cell.position == ( 8, 7 ) then
                -- We're folding from right, so (8, 7) is right after the center piece
                -- The center is the only place where an isolated, one-off tile can be
                -- played legally, so we form a play for it here:
                [ ScrabblePlay.tilesToPlay tiles ]

            else
                -- If there was only one tile, on the main handleValidation
                -- loop, it is not valid so return an empty list of plays:
                []

        _ ->
            [ ScrabblePlay.tilesToPlay tiles ]


getSecondaryDimensionsFor : Grid.Dimension -> List Move -> List Grid.Dimension
getSecondaryDimensionsFor dimension moves =
    -- validateSecondary context (getSecondaryDimensionsFor dimension context.movesMade)
    -- (List.map (\move -> Grid.Column <| Tuple.second move.position) context.movesMade)
    case dimension of
        Grid.Column _ ->
            List.map (\move -> Grid.Row <| Tuple.first move.position) moves

        Grid.Row _ ->
            List.map (\move -> Grid.Column <| Tuple.second move.position) moves

        _ ->
            List.map (\move -> Grid.Invalid) moves
