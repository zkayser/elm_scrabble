module Data.GridTest exposing (suite)

import Data.Grid as Grid exposing (..)
import Expect
import Fuzzers.Grid as GridFuzzer
import Test exposing (..)


suite : Test
suite =
    describe "Grid"
        [ fuzz GridFuzzer.fuzzer "does not contain duplicate cells" <|
            \grid ->
                grid
                    |> List.any (\cell -> (List.length <| List.filter (\c -> c.position == cell.position) grid) > 1)
                    |> Expect.false "Expected no duplicate cells in grid"
        , fuzz GridFuzzer.fuzzer "does not allow cells with negative number positions" <|
            \grid ->
                grid
                    |> List.filter
                        (\cell ->
                            let
                                ( x, y ) =
                                    cell.position
                            in
                            x < 0 || y < 0
                        )
                    |> List.length
                    |> Expect.equal 0
        , fuzz GridFuzzer.fuzzer "orders cells" <|
            \grid ->
                let
                    gridRunner list listOfBools =
                        case list of
                            cell1 :: cell2 :: rest ->
                                gridRunner ([ cell2 ] ++ rest)
                                    (((Tuple.first cell1.position <= Tuple.first cell2.position)
                                        && ((Tuple.first cell1.position == Tuple.first cell2.position && Tuple.second cell1.position < Tuple.second cell2.position) || Tuple.first cell1.position < Tuple.first cell2.position)
                                     )
                                        :: listOfBools
                                    )

                            cell1 :: [] ->
                                gridRunner [] (True :: listOfBools)

                            [] ->
                                listOfBools
                in
                gridRunner grid []
                    |> List.all (\bool -> bool == True)
                    |> Expect.true "Expected cells to be sorted in ascending order by position"
        ]
