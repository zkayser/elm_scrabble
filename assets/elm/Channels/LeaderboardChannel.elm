module Channels.LeaderboardChannel exposing (Config, buildSocket, submitPlay)

import Data.ScrabblePlay as Play exposing (Play)
import Json.Encode as Encode exposing (Value)
import Phoenix.Socket as Socket exposing (Socket)



--import Phoenix
--import Phoenix.Channel as Channel exposing (Channel)
--import Phoenix.Push as Push
--import Phoenix.Socket as Socket exposing (Socket)


type alias Config msg =
    { onOpen : Encode.Value -> msg
    , onJoin : Encode.Value -> msg
    , onUpdate : Encode.Value -> msg
    , onScoreUpdate : Encode.Value -> msg
    }


buildSocket : (Value -> msg) -> Socket msg
buildSocket onJoinFn =
    Socket.init "/socket"
        |> Socket.withOnOpen onJoinFn


submitPlay : List Play -> Cmd msg
submitPlay plays =
    Cmd.none



--socketUrl : String
--socketUrl =
--    "ws://localhost:4000/socket/websocket"
--socket : Config msg -> Socket msg
--socket config =
--    Socket.init socketUrl
--        |> Socket.onOpen config.onOpen
--channel : { r | username : String } -> Config msg -> Channel msg
--channel model config =
--    Channel.init "scrabble:lobby"
--        |> Channel.withPayload (Encode.object [ ( "user", Encode.string model.username ) ])
--        |> Channel.onJoin config.onJoin
--        |> Channel.on "update" (\payload -> config.onUpdate payload)
--        |> Channel.on "score_update" (\payload -> config.onScoreUpdate payload)
--submitPlay : List Play -> Cmd msg
--submitPlay plays =
--    let
--        push =
--            Push.init "scrabble:lobby" "submit_play"
--                |> Push.withPayload (Play.encodeList plays)
--    in
--    Phoenix.push socketUrl push
