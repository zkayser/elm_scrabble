module Data.Move exposing (Move, validate)

import Data.Grid as Grid exposing (Dimension(..))
import Data.Position exposing (Position)
import Data.Tile exposing (Tile)


type alias Move =
    { tile : Tile
    , position : Position
    }


{-| Validates whether or not a list of moves
are valid, returning a `Dimension` value
that indicates whether the list is `Invalid`
or is valid for a `Row` or `Column`
-}
validate : List Move -> Grid.Dimension
validate moves =
    case List.map .position moves of
        [] ->
            Invalid

        ( row, column ) :: tail ->
            if List.all (\( r, _ ) -> r == row) tail then
                Row row

            else if List.all (\( _, c ) -> c == column) tail then
                Column column

            else
                Invalid
