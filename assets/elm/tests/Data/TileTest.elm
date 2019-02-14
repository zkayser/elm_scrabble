module Data.TileTest exposing (suite)

import Data.Cell exposing (Cell)
import Data.Tile as Tile exposing (Tile)
import Data.Multiplier exposing (Multiplier(..))
import Expect
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (text, classes)


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
        [ describe "toHtml"
          [ test "renders the tile's letter" <|
            \_ ->
              Tile.toHtml dragNDropConfig tile
              |> Query.fromHtml
              |> Query.has
                [ text tile.letter
                , text <| String.fromInt tile.value
                , classes [ "cell", "tile" ]
                , classes [ "letter" ]
                , classes [ "value" ]
                ]
          ]
        ]

type TestMsg
  = DragStarted Tile
  | DragEnd
  | Dropped Cell
  | DragOver Cell