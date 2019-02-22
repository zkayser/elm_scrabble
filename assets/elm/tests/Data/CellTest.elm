module Data.CellTest exposing (suite)

import Data.Cell as Cell exposing (Cell)
import Data.Multiplier as Multiplier
import Data.Position exposing (Position)
import Data.Tile as Tile exposing (Tile)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Fuzzers.Cell as CellFuzzer
import Helpers.Serialization as Serialization
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import Result
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (classes, text)
import TestData exposing (dragNDropConfig, tileA)


suite : Test
suite =
    describe "Cell" <|
        let
            defaultCell =
                { position = ( 8, 8 ), multiplier = Multiplier.NoMultiplier, tile = Nothing, isCenter = False }
        in
        [ describe "view" <|
            [ test "gives the cell a class of center-tile if the cell is the center piece" <|
                \_ ->
                    let
                        cell =
                            { defaultCell | isCenter = True }
                    in
                    Cell.view dragNDropConfig cell []
                        |> Query.fromHtml
                        |> Query.has [ classes [ "center-tile" ] ]
            , test "with double word multiplier, renders plain text 2x W if cell is not the center piece" <|
                \_ ->
                    let
                        cell =
                            { defaultCell | position = ( 1, 1 ), multiplier = Multiplier.DoubleWord }
                    in
                    Cell.view dragNDropConfig cell []
                        |> Query.fromHtml
                        |> Query.has [ text "2x W", classes [ "cell", "double-word" ] ]
            , test "with triple word multiplier, renders plain text 3x W" <|
                \_ ->
                    let
                        cell =
                            { defaultCell | multiplier = Multiplier.TripleWord }
                    in
                    Cell.view dragNDropConfig cell []
                        |> Query.fromHtml
                        |> Query.has [ text "3x W", classes [ "cell", "triple-word" ] ]
            , test "with double letter multiplier, renders plain text 2x L" <|
                \_ ->
                    let
                        cell =
                            { defaultCell | multiplier = Multiplier.DoubleLetter }
                    in
                    Cell.view dragNDropConfig cell []
                        |> Query.fromHtml
                        |> Query.has [ text "2x L", classes [ "cell", "double-letter" ] ]
            , test "with triple letter multiplier, renders plain text 3x L" <|
                \_ ->
                    let
                        cell =
                            { defaultCell | multiplier = Multiplier.TripleLetter }
                    in
                    Cell.view dragNDropConfig cell []
                        |> Query.fromHtml
                        |> Query.has [ text "3x L", classes [ "cell", "triple-letter" ] ]
            ]
        , describe "view with tile"
            [ test "renders tile view" <|
                \_ ->
                    let
                        cell =
                            { defaultCell | tile = Just tileA }
                    in
                    Cell.view dragNDropConfig cell []
                        |> Query.fromHtml
                        |> Query.contains [ Tile.view dragNDropConfig tileA ]
            ]
        , describe "decode"
            [ test "handles center cells with no tile" <|
                \_ ->
                    let
                        json =
                            Encode.object
                                [ ( "multiplier", Encode.string "no_multiplier" )
                                , ( "position", Encode.object [ ( "col", Encode.int 8 ), ( "row", Encode.int 8 ) ] )
                                , ( "tile", Encode.string "empty" )
                                ]
                    in
                    decodeValue Cell.decode json
                        |> Expect.equal (Result.Ok { defaultCell | isCenter = True })
            , test "handles cells with tiles" <|
                \_ ->
                    let
                        json =
                            Encode.object
                                [ ( "position", Encode.object [ ( "col", Encode.int 8 ), ( "row", Encode.int 8 ) ] )
                                , ( "multiplier", Encode.string "no_multiplier" )
                                , ( "tile"
                                  , Encode.object
                                        [ ( "letter", Encode.string "A" )
                                        , ( "id", Encode.int 1 )
                                        , ( "value", Encode.int 1 )
                                        , ( "multiplier", Encode.string "no_multiplier" )
                                        ]
                                  )
                                ]
                    in
                    decodeValue Cell.decode json
                        |> Expect.equal (Result.Ok { defaultCell | isCenter = True, tile = Just tileA })
            , test "handles non-center tiles" <|
                \_ ->
                    let
                        json =
                            Encode.object
                                [ ( "position", Encode.object [ ( "col", Encode.int 1 ), ( "row", Encode.int 1 ) ] )
                                , ( "multiplier", Encode.string "double_word" )
                                , ( "tile"
                                  , Encode.object
                                        [ ( "letter", Encode.string "A" )
                                        , ( "id", Encode.int 1 )
                                        , ( "value", Encode.int 1 )
                                        , ( "multiplier", Encode.string "no_multiplier" )
                                        ]
                                  )
                                ]
                    in
                    decodeValue Cell.decode json
                        |> Expect.equal (Result.Ok { position = ( 1, 1 ), multiplier = Multiplier.DoubleWord, isCenter = False, tile = Just tileA })
            , fuzz CellFuzzer.fuzzer "encoding and decoding a cell should yield the same value" <|
                \cell ->
                    cell
                        |> Serialization.expectReversibleDecoder Cell.decode Cell.encode
            ]
        ]
