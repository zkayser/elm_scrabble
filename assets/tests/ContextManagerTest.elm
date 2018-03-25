module ContextManagerTest exposing (..)

import Data.GameContext as Context
import Data.Grid as Grid exposing (Tile)
import Data.Move as Move exposing (Move)
import Dict
import Expect exposing (Expectation)
import Http
import Json.Encode as Encode exposing (Value)
import Logic.ContextManager as Manager
import Requests.ScrabbleApi as ScrabbleApi
import Responses.Scrabble exposing (ScrabbleResponse)
import Test exposing (..)
import Types.Messages as Message


suite : Test
suite =
    describe "ContextManager"
        [ describe "validateSubmission" <|
            let
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

                invalidMoves =
                    [ { tile = tileA, position = ( 1, 1 ) }, { tile = tileB, position = ( 15, 15 ) } ]

                invalidContext =
                    { grid = grid, movesMade = invalidMoves, tiles = [ tileC ], firstPlay = False }
            in
            [ test "Given an invalid play" <|
                \_ ->
                    let
                        update =
                            Manager.validateSubmission Fake invalidContext

                        message =
                            case update of
                                Err response ->
                                    response

                                _ ->
                                    "This string should not match"
                    in
                    Expect.equal message "Invalid play"
            ]
        , describe "contextUpdate" <|
            let
                successResponse =
                    { score = Just 6, error = Nothing }

                errorMessage =
                    "I'm pretty sure asdasdas is not a real word"

                errorResponse =
                    { score = Nothing, error = Just errorMessage }

                context =
                    { grid = Grid.init, movesMade = movesMade, tiles = [ tileC ], firstPlay = False }

                initialTileBag =
                    [ tileD ]

                expectedContext =
                    { context | movesMade = [], tiles = [ tileD, tileC ], firstPlay = False }

                expectedTileBag =
                    []

                expectedRetired =
                    [ { letter = "B", id = 2, value = 2, multiplier = Grid.NoMultiplier }, { letter = "A", id = 1, value = 1, multiplier = Grid.NoMultiplier } ]

                model =
                    { score = 0, context = context, tileBag = initialTileBag, messages = [], retiredTiles = [] }
            in
            [ test "Given a success response" <|
                \_ ->
                    Manager.update successResponse model
                        |> Expect.equal { model | score = 6, context = expectedContext, tileBag = expectedTileBag, retiredTiles = expectedRetired }
            , test "Given an error response" <|
                \_ ->
                    Manager.update errorResponse model
                        |> Expect.equal { model | messages = [ ( Message.Error, errorMessage ) ] }
            ]
        , describe "discardTiles"
            [ test "With tiles remaining in the tilebag and no moves made" <|
                \_ ->
                    let
                        initialTileBag =
                            List.map createTile [ "T", "U", "V", "W", "X", "Y", "Z" ]

                        context =
                            { grid = Grid.init, movesMade = [], tiles = [ tileA, tileB, tileC, tileD ], firstPlay = False }

                        expectedContext =
                            { context | tiles = initialTileBag }

                        expectedTileBag =
                            []

                        model =
                            { score = 0, context = context, tileBag = initialTileBag, messages = [], retiredTiles = [] }
                    in
                    Manager.discardTiles model
                        |> Expect.equal { model | context = expectedContext, tileBag = [] }
            , test "With moves already made" <|
                \_ ->
                    let
                        context =
                            { grid = Grid.init, movesMade = movesMade, tiles = [], firstPlay = False }

                        model =
                            { score = 0, context = context, tileBag = [], messages = [], retiredTiles = [] }

                        updatedModel =
                            Manager.discardTiles model
                    in
                    Expect.equal 1 (List.length updatedModel.messages)
            , test "With fewer than 7 tiles left in the tileBag" <|
                \_ ->
                    let
                        initialTileBag =
                            List.map createTile [ "W", "X", "Y", "Z" ]

                        context =
                            { grid = Grid.init, movesMade = [], tiles = [ tileA, tileB ], firstPlay = False }

                        expectedContext =
                            { context | tiles = initialTileBag }

                        model =
                            { score = 0, context = context, tileBag = initialTileBag, messages = [], retiredTiles = [] }
                    in
                    Manager.discardTiles model
                        |> Expect.equal { model | tileBag = [], context = expectedContext }
            , test "With no more tiles left in the tileBag" <|
                \_ ->
                    let
                        context =
                            { grid = Grid.init, movesMade = [], tiles = [ tileA, tileB ], firstPlay = False }

                        model =
                            { score = 0, context = context, tileBag = [], messages = [], retiredTiles = [] }

                        updatedModel =
                            Manager.discardTiles model
                    in
                    Expect.equal 1 (List.length updatedModel.messages)
            ]
        ]


tileA : Tile
tileA =
    { letter = "A", id = 1, value = 1, multiplier = Grid.NoMultiplier }


tileB : Tile
tileB =
    { letter = "B", id = 2, value = 2, multiplier = Grid.NoMultiplier }


tileC : Tile
tileC =
    { letter = "C", id = 3, value = 3, multiplier = Grid.NoMultiplier }


tileD : Tile
tileD =
    { letter = "D", id = 4, value = 4, multiplier = Grid.NoMultiplier }


createTile : String -> Tile
createTile letter =
    { letter = letter, id = 1, value = 4, multiplier = Grid.NoMultiplier }


movesMade : List Move
movesMade =
    [ { tile = tileA, position = ( 8, 8 ) }, { tile = tileB, position = ( 8, 9 ) } ]


type FakeMsg
    = Fake Value
