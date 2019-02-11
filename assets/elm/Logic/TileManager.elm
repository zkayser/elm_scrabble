module Logic.TileManager exposing (generateTileBag, handleDrop, shuffleTileBag)

import Data.GameContext exposing (Context)
import Data.Grid as Grid exposing (Tile)
import Data.Multiplier exposing (Multiplier(..))
import Logic.ContextManager as ContextManager
import Random
import Time exposing (Posix)


type alias Model r =
    { r
        | dragging : Maybe Tile
        , context : Context
    }



---- Handle drop update for tile holder


handleDrop : Model r -> Model r
handleDrop model =
    case model.dragging of
        Just tile ->
            { model | context = ContextManager.handleTileDrop tile model.context }

        Nothing ->
            model



-- Randomize and sort the generated list of letters


shuffleTileBag : List Tile -> Posix -> List Tile
shuffleTileBag tiles time =
    let
        timeInMillis =
            Time.posixToMillis time
    in
    Random.step (Random.list (List.length tiles) (Random.int 0 2000)) (Random.initialSeed timeInMillis)
        |> Tuple.first
        |> List.map2 (\number tile -> ( number, tile )) tiles
        |> List.sortBy Tuple.second
        |> List.map Tuple.first



-- Generate the bag of tiles


generateTileBag : List Tile
generateTileBag =
    List.foldr doGenerateTiles [] frequencyList
        |> List.indexedMap (\index letter -> { letter = letter, id = index, value = valueFor letter, multiplier = multiplierFor letter })



-- INTERNAL


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


valueFor : String -> Int
valueFor letter =
    if List.member letter [ "" ] then
        0

    else if List.member letter [ "A", "E", "I", "L", "N", "O", "R", "S", "T", "U" ] then
        1

    else if List.member letter [ "D", "G" ] then
        2

    else if List.member letter [ "B", "C", "M", "P" ] then
        3

    else if List.member letter [ "F", "H", "V", "W", "Y" ] then
        4

    else if List.member letter [ "K" ] then
        5

    else if List.member letter [ "J", "X" ] then
        8

    else
        10


multiplierFor : String -> Multiplier
multiplierFor letter =
    if letter == "" then
        Wildcard

    else
        NoMultiplier
