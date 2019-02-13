module TestData exposing (buildMove, buildPlayFor, createMoves, createTile, fakeTileWith, initialTiles, insertGridIntoContext, insertMoveIntoGrid, insertMovesIntoContext, insertMovesIntoGrid, movesMade, tileA, tileB, tileC, tileD)

import Data.Cell exposing (Cell)
import Data.GameContext as Context exposing (Context)
import Data.Grid as Grid exposing (Grid)
import Data.Move exposing (Move)
import Data.Multiplier as Multiplier
import Data.Position exposing (Position)
import Data.ScrabblePlay as Play exposing (Play)
import Data.Tile exposing (Tile)
import Dict


{-| This module exposes some helper functions
for building test data.
-}



-- MOVE BUILDERS --


movesMade : List Move
movesMade =
    [ { tile = tileA, position = ( 8, 8 ) }, { tile = tileB, position = ( 8, 9 ) } ]


createMoves : List String -> List Position -> Int -> List Move
createMoves letters positions idStartInt =
    List.map2 buildMove letters positions
        |> List.indexedMap
            (\int move ->
                let
                    tile =
                        move.tile

                    newTile =
                        { tile | id = idStartInt + int }
                in
                { move | tile = newTile }
            )


buildMove : String -> Position -> Move
buildMove letter position =
    { tile = { letter = letter, id = 1, value = 1, multiplier = Multiplier.NoMultiplier }, position = position }


insertMovesIntoGrid : List Move -> Grid
insertMovesIntoGrid moves =
    List.foldr (\move grid -> insertMoveIntoGrid move grid) Grid.init moves


insertMoveIntoGrid : Move -> Grid -> Grid
insertMoveIntoGrid move grid =
    List.map
        (\cell ->
            if cell.position == move.position then
                { cell | tile = Just move.tile }

            else
                cell
        )
        grid



-- CONTEXT BUILDERS --


insertMovesIntoContext : List Move -> Context
insertMovesIntoContext moves =
    { movesMade = moves, grid = [], tiles = [] }


insertGridIntoContext : Grid -> Context -> Context
insertGridIntoContext newGrid context =
    { context | grid = newGrid }



-- PLAY BUILDERS --


buildPlayFor : String -> Play
buildPlayFor word =
    { word = word, multipliers = Dict.fromList [ ( "DoubleWord", [] ) ] }



-- TILE BUILDERS --


tileA : Tile
tileA =
    { letter = "A", id = 1, value = 1, multiplier = Multiplier.NoMultiplier }


tileB : Tile
tileB =
    { letter = "B", id = 2, value = 2, multiplier = Multiplier.NoMultiplier }


tileC : Tile
tileC =
    { letter = "C", id = 3, value = 3, multiplier = Multiplier.NoMultiplier }


tileD : Tile
tileD =
    { letter = "D", id = 4, value = 4, multiplier = Multiplier.NoMultiplier }


createTile : String -> Tile
createTile letter =
    { letter = letter, id = 1, value = 4, multiplier = Multiplier.NoMultiplier }


initialTiles : List Tile
initialTiles =
    List.map (\( number, letter ) -> { letter = letter, id = number, value = number, multiplier = Multiplier.NoMultiplier })
        [ ( 1, "A" ), ( 2, "B" ), ( 3, "C" ), ( 4, "D" ), ( 5, "E" ), ( 6, "F" ), ( 7, "G" ) ]


fakeTileWith : Int -> String -> Tile
fakeTileWith number letter =
    { letter = letter, id = number, value = number, multiplier = Multiplier.NoMultiplier }
