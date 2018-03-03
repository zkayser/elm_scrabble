module Helpers.TileManager exposing (generateTileBag, shuffleTileBag)

import Data.Grid as Grid exposing (Tile)
import Random
import Time exposing (Time)


-- Generate the bag of tiles


generateTileBag : List Tile
generateTileBag =
    List.foldr doGenerateTiles [] frequencyList
        |> List.indexedMap (\index letter -> { letter = letter, id = index })


doGenerateTiles : ( Int, List String ) -> List String -> List String
doGenerateTiles ( frequency, list ) accumulator =
    List.map (\string -> List.repeat frequency string) list
        |> List.concat
        |> List.append accumulator


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


shuffleTileBag : List Tile -> Time -> List Tile
shuffleTileBag tiles time =
    let
        timeInMillis =
            Time.inMilliseconds time |> truncate
    in
    Random.step (Random.list (List.length tiles) (Random.int 0 2000)) (Random.initialSeed timeInMillis)
        |> Tuple.first
        |> List.map2 (,) tiles
        |> List.sortBy Tuple.second
        |> List.map Tuple.first
