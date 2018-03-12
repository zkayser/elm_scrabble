module ValidatorTest exposing (..)

import Data.Grid as Grid exposing (..)
import Data.Move exposing (Move)
import Data.ScrabblePlay exposing (Play)
import Dict
import Expect exposing (Expectation)
import Logic.Validator as Validator exposing (ValidatorState(..))
import Test exposing (..)


suite : Test
suite =
    describe "Validator" <|
        let
            tileA =
                { letter = "A", id = 1, value = 1, multiplier = Grid.NoMultiplier }

            tileB =
                { letter = "B", id = 2, value = 2, multiplier = Grid.TripleWord }

            tileC =
                { letter = "C", id = 3, value = 3, multiplier = Grid.DoubleLetter }

            tileS =
                { letter = "S", id = 4, value = 4, multiplier = Grid.Wildcard }

            validMovesRow =
                fakeMoves [ tileC, tileA, tileB ] [ ( 8, 6 ), ( 8, 7 ), ( 8, 8 ) ]

            validMovesColumn =
                fakeMoves [ tileC, tileA, tileB ] [ ( 6, 8 ), ( 7, 8 ), ( 8, 8 ) ]

            rowWithGap =
                fakeMoves [ tileC, tileB ] [ ( 8, 6 ), ( 8, 8 ) ]

            columnWithGap =
                fakeMoves [ tileC, tileB ] [ ( 6, 8 ), ( 8, 8 ) ]
        in
        [ describe "Simple"
            [ test "Valid along a row" <|
                \_ ->
                    let
                        grid =
                            validMovesRow
                                |> addMovesToGrid
                    in
                    Row 8
                        |> Grid.get grid
                        |> Validator.validate validMovesRow
                        |> Expect.equal (buildPlayFor "CAB")
            , test "Valid along a column" <|
                \_ ->
                    let
                        grid =
                            validMovesColumn
                                |> addMovesToGrid
                    in
                    Column 8
                        |> Grid.get grid
                        |> Validator.validate validMovesColumn
                        |> Expect.equal (buildPlayFor "CAB")
            , test "Valid row with a gap in player moves" <|
                \_ ->
                    let
                        grid =
                            rowWithGap
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 8, 7 ) then
                                            { cell | tile = Just tileA }
                                        else
                                            cell
                                    )
                    in
                    Row 8
                        |> Grid.get grid
                        |> Validator.validate rowWithGap
                        |> Expect.equal (buildPlayFor "CAB")
            , test "Valid column with a gap in player moves" <|
                \_ ->
                    let
                        grid =
                            columnWithGap
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 7, 8 ) then
                                            { cell | tile = Just tileA }
                                        else
                                            cell
                                    )
                    in
                    Column 8
                        |> Grid.get grid
                        |> Validator.validate columnWithGap
                        |> Expect.equal (buildPlayFor "CAB")
            , test "Invalid along a row" <|
                \_ ->
                    let
                        grid =
                            rowWithGap
                                |> addMovesToGrid
                    in
                    Row 8
                        |> Grid.get grid
                        |> Validator.validate rowWithGap
                        |> Expect.equal Invalidated
            , test "Invalid along a column" <|
                \_ ->
                    let
                        grid =
                            columnWithGap
                                |> addMovesToGrid
                    in
                    Column 8
                        |> Grid.get grid
                        |> Validator.validate columnWithGap
                        |> Expect.equal Invalidated
            , test "Empty row (or column) is invalid" <|
                \_ ->
                    Grid.get Grid.init (Row 8)
                        |> Validator.validate validMovesRow
                        |> Expect.equal Invalidated
            ]
        , describe "Complex - Existing tile detected first" <|
            let
                validRowWithGap =
                    let
                        grid =
                            validMovesRow
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 8, 2 ) then
                                            { cell | tile = Just tileS }
                                        else
                                            cell
                                    )
                    in
                    Row 8
                        |> Grid.get grid

                validColumnWithGap =
                    let
                        grid =
                            validMovesColumn
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 2, 8 ) then
                                            { cell | tile = Just tileS }
                                        else
                                            cell
                                    )
                    in
                    Column 8
                        |> Grid.get grid

                validRowNoGap =
                    let
                        grid =
                            validMovesRow
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 8, 5 ) then
                                            { cell | tile = Just tileS }
                                        else
                                            cell
                                    )
                    in
                    Row 8
                        |> Grid.get grid

                validColumnNoGap =
                    let
                        grid =
                            validMovesColumn
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 5, 8 ) then
                                            { cell | tile = Just tileS }
                                        else
                                            cell
                                    )
                    in
                    Column 8
                        |> Grid.get grid

                invalidRowWithGaps =
                    let
                        grid =
                            rowWithGap
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 8, 2 ) then
                                            { cell | tile = Just tileS }
                                        else
                                            cell
                                    )
                    in
                    Row 8
                        |> Grid.get grid

                invalidColumnWithGaps =
                    let
                        grid =
                            columnWithGap
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 2, 8 ) then
                                            { cell | tile = Just tileS }
                                        else
                                            cell
                                    )
                    in
                    Column 8
                        |> Grid.get grid

                invalidRowNoGap =
                    let
                        grid =
                            rowWithGap
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 8, 5 ) then
                                            { cell | tile = Just tileS }
                                        else
                                            cell
                                    )
                    in
                    Row 8
                        |> Grid.get grid

                invalidColumnNoGap =
                    let
                        grid =
                            columnWithGap
                                |> addMovesToGrid
                                |> List.map
                                    (\cell ->
                                        if cell.position == ( 5, 8 ) then
                                            { cell | tile = Just tileS }
                                        else
                                            cell
                                    )
                    in
                    Column 8
                        |> Grid.get grid
            in
            [ test "Row play is valid with existing tiles detected first, with gaps until valid play" <|
                \_ ->
                    validRowWithGap
                        |> Validator.validate validMovesRow
                        |> Expect.equal (buildPlayFor "CAB")
            , test "Column play is valid with existing tiles detected first, with gaps until valid play" <|
                \_ ->
                    validColumnWithGap
                        |> Validator.validate validMovesColumn
                        |> Expect.equal (buildPlayFor "CAB")
            , test "Row play is valid with existing tiles detected first, no gaps until valid play" <|
                \_ ->
                    validRowNoGap
                        |> Validator.validate validMovesRow
                        |> Expect.equal (buildPlayFor "SCAB")
            , test "Column play is valid with existing tiles detected first, no gaps until valid play" <|
                \_ ->
                    validColumnNoGap
                        |> Validator.validate validMovesColumn
                        |> Expect.equal (buildPlayFor "SCAB")
            , test "Row play is invalid with gap between existing tile and first moved tile" <|
                \_ ->
                    invalidRowWithGaps
                        |> Validator.validate rowWithGap
                        |> Expect.equal Invalidated
            , test "Column play is invalid with gap between existing tile and first moved tile" <|
                \_ ->
                    invalidColumnWithGaps
                        |> Validator.validate columnWithGap
                        |> Expect.equal Invalidated
            , test "Row play is invalid with no gap between existing tile and first moved tile" <|
                \_ ->
                    invalidRowNoGap
                        |> Validator.validate rowWithGap
                        |> Expect.equal Invalidated
            , test "Column play is invalid with no gap between existing tile and first moved tile" <|
                \_ ->
                    invalidColumnNoGap
                        |> Validator.validate columnWithGap
                        |> Expect.equal Invalidated
            ]
        ]


fakeMoves : List Tile -> List Position -> List Move
fakeMoves tiles positions =
    List.map2 (\tile position -> { tile = tile, position = position }) tiles positions


addMovesToGrid : List Move -> Grid
addMovesToGrid moves =
    List.foldr
        (\move grid ->
            List.map
                (\cell ->
                    if cell.position == move.position then
                        { cell | tile = Just move.tile }
                    else
                        cell
                )
                grid
        )
        Grid.init
        moves


buildPlayFor : String -> ValidatorState
buildPlayFor word =
    Validated { word = word, multipliers = Dict.fromList [ ( "DoubleWord", [] ) ] }
