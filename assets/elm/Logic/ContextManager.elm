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
        , retiredTiles : List Tile
    }


{-| This function can fail if an invalid play is attempted.
To account for this, a `Result String (Context, Cmd msg, List Tile )`
type is returned so that the caller of the function can react
accordingly.
-}
validateSubmission : (Value -> msg) -> Context -> Result String (Cmd msg)
validateSubmission msg context =
    if not <| isCenterPlayed context then
        Err "You must play a tile on the center piece"
    else if isFloatingTile context then
        Err "You must place your tiles in sequence"
    else
        case Validator.validate (Move.validate context.movesMade) context of
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

                retiredTiles =
                    List.map (\move -> move.tile) model.context.movesMade

                updatedRetiredTiles =
                    appendTilesToRetired model.retiredTiles retiredTiles

                newContext =
                    { context | tiles = newTiles ++ context.tiles, movesMade = [] }
            in
            { model | score = model.score + score, context = newContext, tileBag = newTileBag, retiredTiles = updatedRetiredTiles }

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


discardTiles : Model r -> Model r
discardTiles model =
    case model.context.movesMade of
        [] ->
            case List.length model.tileBag of
                0 ->
                    { model | messages = ( Message.Error, "There are no more tiles left" ) :: model.messages }

                _ ->
                    let
                        context =
                            model.context

                        newContext =
                            { context | tiles = List.take 7 model.tileBag }
                    in
                    { model | context = newContext, tileBag = List.drop 7 model.tileBag }

        _ ->
            { model | messages = ( Message.Error, "You must discard ALL of your current tiles" ) :: model.messages }


appendTilesToRetired : List Tile -> List Tile -> List Tile
appendTilesToRetired existing new =
    case new of
        [] ->
            existing

        tile :: tiles ->
            appendTilesToRetired (tile :: existing) tiles


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
