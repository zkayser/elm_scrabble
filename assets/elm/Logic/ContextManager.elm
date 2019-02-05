module Logic.ContextManager exposing (discardTiles, handleTileDrop, update, updateContextWith)

import Data.GameContext as Context exposing (Context)
import Data.Grid as Grid exposing (Tile)
import Data.Move as Move
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


handleTileDrop : Tile -> Context -> Context
handleTileDrop tile context =
    case List.member tile context.tiles of
        True ->
            context

        False ->
            let
                newGrid =
                    List.map
                        (\cell ->
                            if cell.tile == Just tile then
                                { cell | tile = Nothing }

                            else
                                cell
                        )
                        context.grid

                newMovesMade =
                    List.filter (\move -> move.tile /= tile) context.movesMade
            in
            { context | tiles = tile :: context.tiles, grid = newGrid, movesMade = newMovesMade }



-- INTERNAL


appendTilesToRetired : List Tile -> List Tile -> List Tile
appendTilesToRetired existing new =
    case new of
        [] ->
            existing

        tile :: tiles ->
            appendTilesToRetired (tile :: existing) tiles
