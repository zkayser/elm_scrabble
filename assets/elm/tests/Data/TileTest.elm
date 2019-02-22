module Data.TileTest exposing (suite)

import Data.Cell exposing (Cell)
import Data.Multiplier exposing (Multiplier(..))
import Data.Tile as Tile exposing (Tile)
import Expect
import Fuzzers.Tile as TileFuzzer
import Helpers.Serialization as Serialization
import Html.Attributes as Attribute
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import Result
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, classes, text)


suite : Test
suite =
    describe "Tile" <|
        let
            dragNDropConfig =
                { dragStartMsg = DragStarted
                , dragEndMsg = DragEnd
                , dropMsg = Dropped
                , dragOverMsg = DragOver
                }

            tile =
                { letter = "A"
                , id = 1
                , value = 4
                , multiplier = NoMultiplier
                }
        in
        [ describe "view"
            [ test "renders the tile's letter" <|
                \_ ->
                    Tile.view dragNDropConfig tile
                        |> Query.fromHtml
                        |> Query.has
                            [ text tile.letter
                            , text <| String.fromInt tile.value
                            , classes [ "cell", "tile" ]
                            , classes [ "letter" ]
                            , classes [ "value" ]
                            , attribute <| Attribute.attribute "draggable" "true"
                            ]
            , test "does not add draggable attribute when the tile is not draggable" <|
                \_ ->
                    Tile.disable tile
                        |> Query.fromHtml
                        |> Expect.all
                            [ Query.hasNot [ attribute <| Attribute.attribute "draggable" "true" ]
                            , Query.has
                                [ text tile.letter
                                , text <| String.fromInt tile.value
                                , classes [ "cell", "tile" ]
                                , classes [ "letter" ]
                                , classes [ "value" ]
                                ]
                            ]
            ]
        , describe "decode" <|
            let
                jsonTileWith multiplierString =
                    Encode.object
                        [ ( "id", Encode.int 1 )
                        , ( "letter", Encode.string "E" )
                        , ( "multiplier", Encode.string multiplierString )
                        , ( "value", Encode.int 4 )
                        ]

                defaultTile =
                    { id = 1
                    , letter = "E"
                    , multiplier = NoMultiplier
                    , value = 4
                    }
            in
            [ test "decodes a json tile into an Elm Tile" <|
                \_ ->
                    let
                        json =
                            jsonTileWith "no_multiplier"
                    in
                    decodeValue Tile.decode json
                        |> Expect.equal (Result.Ok defaultTile)
            , fuzz TileFuzzer.fuzzer "encoding and decoding a tile should result in the same value" <|
                \exTile ->
                    exTile
                        |> Serialization.expectReversibleDecoder Tile.decode Tile.encode
            ]
        ]


type TestMsg
    = DragStarted Tile
    | DragEnd
    | Dropped Cell
    | DragOver Cell
