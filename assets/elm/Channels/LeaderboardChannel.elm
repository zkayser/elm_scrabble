port module Channels.LeaderboardChannel exposing (submitPlay)

import Data.ScrabblePlay as Play exposing (Play)
import ExternalData
import Json.Encode as Encode exposing (Value)
import Phoenix.Push as Push
import Phoenix.Socket as Socket exposing (Socket)


submitPlay : List Play -> Cmd msg
submitPlay plays =
    let
        push =
            Push.init "scrabble:lobby" "submit_play"
                |> Push.withPayload (Play.encodeList plays)
    in
    ExternalData.sendDataOut <| ExternalData.createPush push
