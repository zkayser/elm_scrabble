module GameContextTest exposing (..)

import Data.GameContext as Context exposing (Turn(..))
import Data.Grid as Grid exposing (Multiplier(..), Tile)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)


suite : Test
suite =
    describe "GameContext"
        [ describe "User is Active" <|
            let
                -- This function is curried so that it is always
                -- evaluated with an `Active` Turn parameter for
                -- the remainder of this test block
                update =
                    Context.update Active

                initialContext =
                    Context.init Grid.init initialTiles
            in
            [ test "A tile is transferred from the context's tiles list to the grid when played" <|
                \_ ->
                    let
                        move =
                            { tile = fakeTileWith 1 "A", position = ( 8, 8 ) }

                        expectedGrid =
                            List.map
                                (\cell ->
                                    if cell.position == ( 8, 8 ) then
                                        { cell | tile = Just (fakeTileWith 1 "A") }
                                    else
                                        cell
                                )
                                Grid.init

                        expectedMoves =
                            [ move ]

                        expectedTiles =
                            List.filter (\tile -> tile /= fakeTileWith 1 "A") initialTiles
                    in
                    update initialContext move
                        |> Expect.equal { grid = expectedGrid, movesMade = expectedMoves, tiles = expectedTiles, firstPlay = False }
            , test "A tile cannot be placed on top of another tile on the grid" <|
                \_ ->
                    let
                        tileA =
                            fakeTileWith 1 "A"

                        tileB =
                            fakeTileWith 2 "B"

                        startGrid =
                            List.map
                                (\cell ->
                                    if cell.isCenter then
                                        { cell | tile = Just tileA }
                                    else
                                        cell
                                )
                                initialContext.grid

                        newContext =
                            { grid = startGrid, movesMade = [ { tile = tileA, position = ( 8, 8 ) } ], tiles = List.filter (\tile -> tile /= tileA) initialContext.tiles, firstPlay = False }

                        move =
                            { tile = tileB, position = ( 8, 8 ) }
                    in
                    move
                        |> update newContext
                        |> Expect.equal newContext
            , test "Moving a tile already on the board transfers it from the initial position to the new position" <|
                \_ ->
                    let
                        tileA =
                            fakeTileWith 1 "A"

                        startGrid =
                            List.map
                                (\cell ->
                                    if cell.isCenter then
                                        { cell | tile = Just tileA }
                                    else
                                        cell
                                )
                                Grid.init

                        newTiles =
                            List.filter (\tile -> tile /= tileA) initialContext.tiles

                        newContext =
                            { grid = startGrid, movesMade = [ { tile = tileA, position = ( 8, 8 ) } ], tiles = newTiles, firstPlay = False }

                        move =
                            { tile = tileA, position = ( 7, 7 ) }

                        expectedGrid =
                            List.map
                                (\cell ->
                                    if cell.position == ( 7, 7 ) then
                                        { cell | tile = Just tileA }
                                    else
                                        cell
                                )
                                Grid.init

                        expectedMovesMade =
                            [ move ]

                        expectedContext =
                            { grid = expectedGrid, movesMade = expectedMovesMade, tiles = newTiles, firstPlay = False }
                    in
                    move
                        |> update newContext
                        |> Expect.equal expectedContext
            ]
        ]


initialTiles : List Tile
initialTiles =
    List.map (\( number, letter ) -> { letter = letter, id = number, value = number, multiplier = NoMultiplier })
        [ ( 1, "A" ), ( 2, "B" ), ( 3, "C" ), ( 4, "D" ), ( 5, "E" ), ( 6, "F" ), ( 7, "G" ) ]


fakeTileWith : Int -> String -> Tile
fakeTileWith number letter =
    { letter = letter, id = number, value = number, multiplier = NoMultiplier }
