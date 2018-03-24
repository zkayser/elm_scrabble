module Logic.Validator exposing (..)

import Data.GameContext exposing (Context)
import Data.Grid as Grid exposing (Cell, Multiplier(..), Tile)
import Data.Move exposing (Move)
import Data.ScrabblePlay as ScrabblePlay exposing (Play)


type ValidatorState
    = NoMoveDetected
    | PossibleMoveFound (List Tile)
    | MoveDetected (List Tile)
    | Validated (List Play)
    | Invalidated


validate : Grid.Dimension -> Context -> ValidatorState
validate dimension context =
    if context.firstPlay && not (List.member ( 8, 8 ) (List.map (\move -> move.position) context.movesMade)) then
        Invalidated
    else if not context.firstPlay && List.length context.movesMade == 1 then
        case List.head context.movesMade of
            Just move ->
                if hasNeighbor move.position context.grid then
                    case handleValidate context.movesMade (Grid.get context.grid dimension) of
                        Validated [ play ] ->
                            if String.length play.word == 1 then
                                -- Only the secondary plays may be valid now
                                let
                                    secondaryPlays =
                                        validateSecondary context (List.map (\move -> Grid.Column <| Tuple.second move.position) context.movesMade)
                                in
                                case List.length secondaryPlays of
                                    0 ->
                                        Invalidated

                                    -- If there are 0 secondary plays, then the play is invalid
                                    _ ->
                                        Validated secondaryPlays
                            else
                                let
                                    secondaryPlays =
                                        validateSecondary context (List.map (\move -> Grid.Column <| Tuple.second move.position) context.movesMade)
                                in
                                Validated <| play :: secondaryPlays

                        _ ->
                            Invalidated
                else
                    Invalidated

            Nothing ->
                Invalidated
    else
        case dimension of
            Grid.Invalid ->
                Invalidated

            Grid.Row _ ->
                case handleValidate context.movesMade (Grid.get context.grid dimension) of
                    Validated play ->
                        let
                            secondaryPlays =
                                validateSecondary context (List.map (\move -> Grid.Column <| Tuple.second move.position) context.movesMade)
                        in
                        Validated <| play ++ secondaryPlays

                    _ ->
                        Invalidated

            Grid.Column _ ->
                case handleValidate context.movesMade (Grid.get context.grid dimension) of
                    Validated play ->
                        let
                            secondaryPlays =
                                validateSecondary context (List.map (\move -> Grid.Row <| Tuple.first move.position) context.movesMade)
                        in
                        Validated <| play ++ secondaryPlays

                    _ ->
                        Invalidated


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
handleValidate : List Move -> List Cell -> ValidatorState
handleValidate moves cells =
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
                        Validated <| [ ScrabblePlay.tilesToPlay tiles ]
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
                Validated [ play ] ->
                    if String.length play.word > 1 then
                        [ play ]
                    else
                        []

                _ ->
                    []

        Grid.Column column ->
            case handleValidate (List.filter (\move -> Tuple.second move.position == column) context.movesMade) (Grid.get context.grid dimension) of
                Validated [ play ] ->
                    if String.length play.word > 1 then
                        [ play ]
                    else
                        []

                _ ->
                    []

        _ ->
            []


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


hasNeighbor : Grid.Position -> Grid.Grid -> Bool
hasNeighbor position grid =
    (List.length <| List.filterMap (hasNeighboringTile position) grid) > 0


hasNeighboringTile : Grid.Position -> Cell -> Maybe Grid.Position
hasNeighboringTile ( row, col ) cell =
    if List.member cell.position [ ( row + 1, col ), ( row - 1, col ), ( row, col + 1 ), ( row, col - 1 ) ] then
        case cell.tile of
            Just tile ->
                Just cell.position

            Nothing ->
                Nothing
    else
        Nothing
