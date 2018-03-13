module ContextManagerTest exposing (..)

import Data.Grid as Grid
import Dict
import Expect exposing (Expectation)
import Helpers.ContextManager as Manager
import Http
import Logic.GameContext as Context
import Requests.ScrabbleApi as ScrabbleApi
import Test exposing (..)


suite : Test
suite =
    describe "ContextManager"
        [ describe "updateContext" <|
            let
                tileA =
                    { letter = "A", id = 1, value = 1, multiplier = Grid.NoMultiplier }

                tileB =
                    { letter = "B", id = 2, value = 2, multiplier = Grid.NoMultiplier }

                tileC =
                    { letter = "C", id = 3, value = 3, multiplier = Grid.NoMultiplier }

                tileD =
                    { letter = "D", id = 4, value = 4, multiplier = Grid.NoMultiplier }

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

                movesMade =
                    [ { tile = tileA, position = ( 8, 8 ) }, { tile = tileB, position = ( 8, 9 ) } ]

                invalidMoves =
                    [ { tile = tileA, position = ( 1, 1 ) }, { tile = tileB, position = ( 15, 15 ) } ]

                context =
                    { grid = grid, movesMade = movesMade, tiles = [ tileC ] }

                tileBag =
                    [ tileD ]

                expectedCmd =
                    Http.send Fake (ScrabbleApi.getScore { word = "word", multipliers = Dict.empty })
            in
            [ test "Given a valid play" <|
                \_ ->
                    let
                        expectedContext =
                            { grid = context.grid, movesMade = [], tiles = [ tileD, tileC ] }

                        expectedTileBag =
                            []

                        update =
                            Manager.updateContext Fake tileBag context

                        ( updatedContext, updatedTileBag ) =
                            case update of
                                Ok ( newContext, _, newTileBag ) ->
                                    ( newContext, newTileBag )

                                _ ->
                                    ( context, [] )
                    in
                    Expect.equal ( updatedContext, updatedTileBag ) ( expectedContext, expectedTileBag )
            , test "Given an invalid play" <|
                \_ ->
                    let
                        update =
                            Manager.updateContext Fake tileBag { context | movesMade = invalidMoves }

                        message =
                            case update of
                                Err response ->
                                    response

                                _ ->
                                    "This string should not match"
                    in
                    Expect.equal message "Invalid play"
            ]
        ]


type FakeMsg
    = Fake (Result Http.Error Int)
