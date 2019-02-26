module Data.Board exposing (Board, TileState, decode, discardTiles, encode, init)

import Data.Grid as Grid exposing (Grid)
import Data.Position as Position exposing (Position)
import Data.Tile as Tile exposing (Tile)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Phoenix.Push as Push exposing (Push)


type alias Board =
    { grid : Grid
    , invalidAt : List Position
    , moves : List Position
    , tileState : TileState
    }


type alias TileState =
    { inPlay : List Tile
    , played : List Tile
    }


init : Board
init =
    { grid = Grid.init
    , invalidAt = []
    , moves = []
    , tileState = { inPlay = [], played = [] }
    }


{-| Triggers a Cmd to discard inPlay tiles
-}
discardTiles : Board -> ( Board, Push msg )
discardTiles board =
    let
        push =
            Push.init "scrabble:lobby" "discard_tiles"
    in
    ( board, push )


encode : Board -> Value
encode board =
    Encode.object
        [ ( "grid", Grid.encode board.grid )
        , ( "invalid_at", Encode.list Position.encode board.invalidAt )
        , ( "moves", Encode.list Position.encode board.moves )
        , ( "tile_state", tileStateEncoder board.tileState )
        ]


tileStateEncoder : TileState -> Value
tileStateEncoder tileState =
    Encode.object
        [ ( "in_play", Encode.list Tile.encode tileState.inPlay )
        , ( "played", Encode.list Tile.encode tileState.played )
        ]


decode : Decoder Board
decode =
    Decode.map4 Board
        (Decode.field "grid" Grid.decode)
        (Decode.field "invalid_at" <| Decode.list Position.decode)
        (Decode.field "moves" <| Decode.list Position.decode)
        (Decode.field "tile_state" tileStateDecoder)


tileStateDecoder : Decoder TileState
tileStateDecoder =
    Decode.map2 TileState
        (Decode.field "in_play" <| Decode.list Tile.decode)
        (Decode.field "played" <| Decode.list Tile.decode)
