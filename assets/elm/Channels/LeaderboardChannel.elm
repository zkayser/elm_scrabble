port module Channels.LeaderboardChannel exposing (submitPlay)

import Data.ScrabblePlay as Play exposing (Play)
import Json.Encode as Encode exposing (Value)
import Phoenix.Message as Message exposing (Data)
import Phoenix.Push as Push
import Phoenix.Socket as Socket exposing (Socket)


submitPlay : (Data -> Cmd msg) -> List Play -> Cmd msg
submitPlay phoenixSendFn plays =
    let
        push =
            Push.init "scrabble:lobby" "submit_play"
                |> Push.withPayload (Play.encodeList plays)
    in
    Message.send phoenixSendFn <| Message.createPush push
