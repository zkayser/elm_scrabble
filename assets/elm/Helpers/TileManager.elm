module Helpers.TileManager exposing (generateTileBag, shuffleTileBag)

import Random
import Time exposing (Time)


-- Generate the bag of tiles


generateTileBag : List String
generateTileBag =
    List.foldr doGenerateTiles [] frequencyList


doGenerateTiles : ( Int, List String ) -> List String -> List String
doGenerateTiles ( frequency, list ) accumulator =
    List.map (\string -> List.repeat frequency string) list |> List.concat |> List.append accumulator


frequencyList : List ( Int, List String )
frequencyList =
    [ ( 12, [ "E" ] )
    , ( 9, [ "A", "I" ] )
    , ( 8, [ "O" ] )
    , ( 6, [ "N", "R", "T" ] )
    , ( 4, [ "L", "S", "U", "D" ] )
    , ( 3, [ "G" ] )
    , ( 2, [ "B", "C", "M", "P", "F", "H", "V", "W", "Y", "" ] )
    , ( 1, [ "K", "J", "X", "Q", "Z" ] )
    ]



-- Randomize and sort the generated list of letters


shuffleTileBag : List String -> Time -> List String
shuffleTileBag tiles time =
    let
        timeInMilliSeconds =
            Time.inMilliseconds time |> truncate

        randomizedNumberList =
            Random.step (Random.list (List.length tiles) (Random.int 0 2000)) (Random.initialSeed timeInMilliSeconds) |> Tuple.first

        zippedList =
            List.map2 (,) randomizedNumberList tiles

        sorted =
            List.sortBy Tuple.first zippedList

        result =
            List.map Tuple.second sorted
    in
    result
