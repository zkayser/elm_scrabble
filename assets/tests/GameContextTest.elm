module GameContextTest exposing (..)

import Data.Grid as Grid
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Logic.GameContext as Context
import Test exposing (..)
import Types.Playable as Playable


suite : Test
suite =
    describe "GameContext"
        [ test "First move and the user places a tile on the center piece" <|
            \_ ->
                let
                    grid =
                        Grid.init

                    turnState =
                        Context.Ready { grid = grid, tilesPlayed = [], playable = [ Playable.AllValid ] }

                    tile =
                        { letter = "A", value = 1, id = 1 }

                    move =
                        { tile = tile, position = ( 8, 8 ) }

                    updatedContext =
                        Context.update turnState move

                    expectedGrid =
                        List.map
                            (\cell ->
                                if cell.isCenter then
                                    { cell | tile = Just tile }
                                else
                                    cell
                            )
                            grid
                in
                Expect.equal updatedContext (Context.OneTilePlayed { grid = expectedGrid, tilesPlayed = [ tile ], playable = [ Playable.Row 8, Playable.Column 8 ] })
        , test "First move and the user tries to place a tile where one has already been placed" <|
            \_ ->
                let
                    tile =
                        { letter = "A", value = 1, id = 1 }

                    grid =
                        List.map
                            (\cell ->
                                if cell.isCenter then
                                    { cell | tile = Just tile }
                                else
                                    cell
                            )
                            Grid.init

                    turnState =
                        Context.Ready { grid = grid, tilesPlayed = [], playable = [ Playable.AllValid ] }

                    move =
                        { tile = { letter = "B", value = 2, id = 2 }, position = ( 8, 8 ) }

                    updatedContext =
                        Context.update turnState move
                in
                Expect.equal updatedContext turnState
        , test "Placing a second tile in a playable row" <|
            \_ ->
                let
                    playedTile =
                        { letter = "A", value = 1, id = 1 }

                    grid =
                        List.map
                            (\cell ->
                                if cell.isCenter then
                                    { cell | tile = Just playedTile }
                                else
                                    cell
                            )
                            Grid.init

                    turnState =
                        Context.OneTilePlayed { grid = grid, tilesPlayed = [ playedTile ], playable = [ Playable.Row 8, Playable.Column 8 ] }

                    newTile =
                        { letter = "B", value = 2, id = 2 }

                    move =
                        { tile = newTile, position = ( 8, 9 ) }

                    updatedContext =
                        Context.update turnState move

                    expectedGrid =
                        List.map
                            (\cell ->
                                if cell.position == ( 8, 9 ) then
                                    { cell | tile = Just move.tile }
                                else
                                    cell
                            )
                            grid
                in
                Expect.equal updatedContext (Context.MultipleTilesPlayed { grid = expectedGrid, tilesPlayed = [ newTile, playedTile ], playable = [ Playable.Row 8 ] })
        , test "Placing a second tile in a playable column" <|
            \_ ->
                let
                    playedTile =
                        { letter = "A", value = 1, id = 1 }

                    grid =
                        List.map
                            (\cell ->
                                if cell.isCenter then
                                    { cell | tile = Just playedTile }
                                else
                                    cell
                            )
                            Grid.init

                    turnState =
                        Context.OneTilePlayed { grid = grid, tilesPlayed = [ playedTile ], playable = [ Playable.Row 8, Playable.Column 8 ] }

                    newTile =
                        { letter = "B", value = 2, id = 2 }

                    move =
                        { tile = newTile, position = ( 9, 8 ) }

                    updatedContext =
                        Context.update turnState move

                    expectedGrid =
                        List.map
                            (\cell ->
                                if cell.position == ( 9, 8 ) then
                                    { cell | tile = Just move.tile }
                                else
                                    cell
                            )
                            grid
                in
                Expect.equal updatedContext (Context.MultipleTilesPlayed { grid = expectedGrid, tilesPlayed = [ newTile, playedTile ], playable = [ Playable.Column 8 ] })
        , test "Placing a second tile on an unplayable cell" <|
            \_ ->
                let
                    playedTile =
                        { letter = "A", value = 1, id = 1 }

                    grid =
                        List.map
                            (\cell ->
                                if cell.isCenter then
                                    { cell | tile = Just playedTile }
                                else
                                    cell
                            )
                            Grid.init

                    turnState =
                        Context.OneTilePlayed { grid = grid, tilesPlayed = [ playedTile ], playable = [ Playable.Row 8, Playable.Column 8 ] }

                    newTile =
                        { letter = "B", value = 2, id = 2 }

                    move =
                        { tile = newTile, position = ( 2, 2 ) }

                    -- This is unplayable (row 2, column 2)
                    updatedContext =
                        Context.update turnState move
                in
                Expect.equal updatedContext turnState
        , test "Placing a third tile on a playable cell" <|
            \_ ->
                let
                    tileA =
                        { letter = "A", value = 1, id = 1 }

                    tileB =
                        { letter = "B", value = 2, id = 2 }

                    grid =
                        List.map
                            (\cell ->
                                if cell.isCenter then
                                    { cell | tile = Just tileA }
                                else if cell.position == ( 8, 9 ) then
                                    { cell | tile = Just tileB }
                                else
                                    cell
                            )
                            Grid.init

                    turnState =
                        Context.MultipleTilesPlayed { grid = grid, tilesPlayed = [ tileB, tileA ], playable = [ Playable.Row 8 ] }

                    newTile =
                        { letter = "C", value = 3, id = 3 }

                    move =
                        { tile = newTile, position = ( 8, 10 ) }

                    -- This move is valid - row 8, column 10
                    updatedContext =
                        Context.update turnState move

                    expectedGrid =
                        List.map
                            (\cell ->
                                if cell.position == move.position then
                                    { cell | tile = Just move.tile }
                                else
                                    cell
                            )
                            grid
                in
                Expect.equal updatedContext (Context.MultipleTilesPlayed { grid = expectedGrid, tilesPlayed = [ newTile, tileB, tileA ], playable = [ Playable.Row 8 ] })
        , test "Placing a third tile on an unplayable cell" <|
            \_ ->
                let
                    tileA =
                        { letter = "A", value = 1, id = 1 }

                    tileB =
                        { letter = "B", value = 2, id = 2 }

                    grid =
                        List.map
                            (\cell ->
                                if cell.isCenter then
                                    { cell | tile = Just tileA }
                                else if cell.position == ( 8, 9 ) then
                                    { cell | tile = Just tileB }
                                else
                                    cell
                            )
                            Grid.init

                    turnState =
                        Context.MultipleTilesPlayed { grid = grid, tilesPlayed = [ tileB, tileA ], playable = [ Playable.Row 8 ] }

                    newTile =
                        { letter = "C", value = 3, id = 3 }

                    move =
                        { tile = newTile, position = ( 9, 8 ) }

                    -- This move should be invalid. Only row 8 should be valid at this point
                    updatedContext =
                        Context.update turnState move
                in
                Expect.equal updatedContext turnState
        ]
