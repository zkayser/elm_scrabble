module Channels.LeaderboardChannel exposing (..)

import Data.ScrabblePlay as Play exposing (Play)
import Json.Encode as Encode
import Phoenix
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Push as Push
import Phoenix.Socket as Socket exposing (Socket)


type alias Config msg =
    { onOpen : msg
    , onJoin : Encode.Value -> msg
    , onUpdate : Encode.Value -> msg
    , onScoreUpdate : Encode.Value -> msg
    }


socketUrl : String
socketUrl =
    "ws://localhost:4000/socket/websocket"


socket : Config msg -> Socket msg
socket config =
    Socket.init socketUrl
        |> Socket.onOpen config.onOpen


channel : { r | username : String } -> Config msg -> Channel msg
channel model config =
    Channel.init "scrabble:lobby"
        |> Channel.withPayload (Encode.object [ ( "user", Encode.string model.username ) ])
        |> Channel.onJoin config.onJoin
        |> Channel.on "update" (\payload -> config.onUpdate payload)
        |> Channel.on "score_update" (\payload -> config.onScoreUpdate payload)


submitPlay : Play -> { r | username : String } -> Cmd msg
submitPlay play model =
    let
        push =
            Push.init "scrabble:lobby" "submit_play"
                |> Push.withPayload (Encode.object [ ( "user", Encode.string model.username ), ( "play", Play.encode play ) ])
    in
    Phoenix.push socketUrl push
