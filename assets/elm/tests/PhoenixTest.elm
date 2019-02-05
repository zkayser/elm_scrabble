module PhoenixTest exposing (suite)

import Dict
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode
import Json.Encode as Encode
import Phoenix
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Internal.EntityState exposing (EntityState(..))
import Phoenix.Message exposing (Event(..), Message(..))
import Phoenix.Push as Push
import Phoenix.Socket as Socket
import Task
import Test exposing (..)


suite : Test
suite =
    describe "Phoenix"
        [ describe "addChannel"
            [ test "places a channel in the model's channels field" <|
                \_ ->
                    let
                        model =
                            Phoenix.initialize (Socket.init "/socket") fakeSend

                        channel =
                            Channel.init "room:lobby"

                        newModel =
                            Phoenix.addChannel channel model
                    in
                    Expect.equal (Dict.get channel.topic newModel.channels) (Just channel)
            ]
        , describe "addPush"
            [ test "places a push in the model's pushes field" <|
                \_ ->
                    let
                        model =
                            Phoenix.initialize (Socket.init "/socket") fakeSend

                        push =
                            Push.init "room:lobby" "my_event"

                        newModel =
                            Phoenix.addPush push model
                    in
                    Expect.equal (Dict.get push.topic newModel.pushes) (Just push)
            ]
        , describe "update" <|
            let
                defaultPayload =
                    { topic = "room:lobby", message = "some_message", payload = Encode.object [] }
            in
            [ describe "Incoming" <|
                let
                    initSocket =
                        Socket.init "/socket"

                    initModel =
                        Phoenix.initialize initSocket fakeSend
                in
                [ describe "SocketClosed"
                    [ test "sets socket state to closed" <|
                        \_ ->
                            let
                                ( newModel, _ ) =
                                    Phoenix.update (Incoming SocketClosed) initModel
                            in
                            newModel.socket.state
                                |> Expect.equal Closed
                    ]
                , describe "SocketErrored"
                    [ test "sets socket state to errored" <|
                        \_ ->
                            let
                                payload =
                                    { topic = "", message = "", payload = Encode.object [] }

                                ( model, _ ) =
                                    initModel
                                        |> Phoenix.update (Incoming <| SocketErrored payload)
                            in
                            model.socket.state
                                |> Expect.equal Errored
                    ]
                , describe "SocketOpened"
                    [ test "sets socket state to connected" <|
                        \_ ->
                            let
                                ( model, _ ) =
                                    Phoenix.update (Incoming SocketOpened) initModel
                            in
                            model.socket.state
                                |> Expect.equal Connected
                    ]
                , describe "ChannelJoined"
                    [ test "sets channel state to connected" <|
                        \_ ->
                            let
                                initChannel =
                                    Channel.init "room:lobby"

                                modelWithChannel =
                                    { initModel | channels = Dict.insert "room:lobby" initChannel initModel.channels }

                                ( model, _ ) =
                                    Phoenix.update (Incoming (ChannelJoined defaultPayload)) modelWithChannel

                                channel =
                                    Dict.get defaultPayload.topic model.channels
                            in
                            case channel of
                                Just ch ->
                                    Expect.equal ch.state Connected

                                _ ->
                                    Expect.fail "Expected channel to exist and be connected"
                    ]
                , describe "ChannelJoinErrored"
                    [ test "sets channel state to errored" <|
                        \_ ->
                            let
                                initChannel =
                                    Channel.init "room:lobby"

                                modelWithChannel =
                                    { initModel | channels = Dict.insert "room:lobby" initChannel initModel.channels }

                                ( model, _ ) =
                                    Phoenix.update (Incoming (ChannelJoinError defaultPayload)) modelWithChannel

                                channel =
                                    Dict.get defaultPayload.topic model.channels
                            in
                            case channel of
                                Just ch ->
                                    Expect.equal ch.state Errored

                                _ ->
                                    Expect.fail "Expected channel to exist and have errored out"
                    ]
                , describe "ChannelJoinTimeout"
                    [ test "sets channel state to TimedOut" <|
                        \_ ->
                            let
                                initChannel =
                                    Channel.init "room:lobby"

                                modelWithChannel =
                                    { initModel | channels = Dict.insert "room:lobby" initChannel initModel.channels }

                                ( model, _ ) =
                                    Phoenix.update (Incoming (ChannelJoinTimeout defaultPayload)) modelWithChannel

                                channel =
                                    Dict.get defaultPayload.topic model.channels
                            in
                            case channel of
                                Just ch ->
                                    Expect.equal ch.state TimedOut

                                _ ->
                                    Expect.fail "Expected channel to exist and have timed out"
                    ]
                , describe "ChannelMessageReceive"
                    [ test "is a no-op on the channel" <|
                        \_ ->
                            let
                                initChannel =
                                    Channel.init "room:lobby"

                                modelWithChannel =
                                    { initModel | channels = Dict.insert "room:lobby" initChannel initModel.channels }

                                ( model, _ ) =
                                    Phoenix.update (Incoming (ChannelMessageReceived defaultPayload)) modelWithChannel
                            in
                            Expect.equal modelWithChannel model
                    ]
                , describe "ChannelLeft"
                    [ test "sets the channel state to Closed" <|
                        \_ ->
                            let
                                initChannel =
                                    Channel.init "room:lobby"

                                modelWithChannel =
                                    { initModel | channels = Dict.insert "room:lobby" initChannel initModel.channels }

                                ( model, _ ) =
                                    Phoenix.update (Incoming (ChannelLeft defaultPayload)) modelWithChannel

                                channel =
                                    Dict.get defaultPayload.topic model.channels
                            in
                            case channel of
                                Just ch ->
                                    Expect.equal ch.state Closed

                                _ ->
                                    Expect.fail "Expected channel to exist and be closed"
                    ]
                , describe "ChannelLeaveError"
                    [ test "sets the channel state to LeaveErrored" <|
                        \_ ->
                            let
                                initChannel =
                                    Channel.init "room:lobby"

                                modelWithChannel =
                                    { initModel | channels = Dict.insert "room:lobby" initChannel initModel.channels }

                                ( model, _ ) =
                                    Phoenix.update (Incoming (ChannelLeaveError defaultPayload)) modelWithChannel

                                channel =
                                    Dict.get defaultPayload.topic model.channels
                            in
                            case channel of
                                Just ch ->
                                    Expect.equal ch.state LeaveErrored

                                _ ->
                                    Expect.fail "Expected channel to exist and be in a LeaveError state"
                    ]
                ]
            , describe "Outgoing" <|
                let
                    initSocket =
                        Socket.init "/socket"

                    initModel =
                        Phoenix.initialize initSocket fakeSend
                in
                [ describe "createSocket"
                    [ test "returns the socket as is" <|
                        \_ ->
                            let
                                command =
                                    Phoenix.Message.createSocket initSocket

                                ( model, _ ) =
                                    Phoenix.update command initModel
                            in
                            Expect.equal model.socket initSocket
                    ]
                , describe "disconnect"
                    [ test "returns the socket as is" <|
                        \_ ->
                            let
                                cmd =
                                    Phoenix.Message.disconnect

                                ( model, _ ) =
                                    Phoenix.update cmd initModel
                            in
                            Expect.equal model initModel
                    ]
                , describe "createChannel"
                    [ test "puts the channel in the socket's channels dictionary" <|
                        \_ ->
                            let
                                channel =
                                    Channel.init "room:lobby"

                                cmd =
                                    Phoenix.Message.createChannel channel

                                ( model, _ ) =
                                    Phoenix.update cmd initModel
                            in
                            Expect.equal (Dict.get "room:lobby" model.channels) (Just channel)
                    ]
                , describe "leaveChannel"
                    [ test "has no immediate effect on the socket" <|
                        \_ ->
                            let
                                channel =
                                    Channel.init "room:lobby"

                                modelWithChannel =
                                    { initModel | channels = Dict.insert channel.topic channel initSocket.channels }

                                cmd =
                                    Phoenix.Message.leaveChannel channel

                                ( model, _ ) =
                                    Phoenix.update cmd modelWithChannel
                            in
                            Expect.equal model modelWithChannel
                    ]
                , describe "createPush"
                    [ test "adds a push to the socket's pushes dictionary" <|
                        \_ ->
                            let
                                push =
                                    Push.init "room:lobby" "my_event"

                                cmd =
                                    Phoenix.Message.createPush push

                                ( model, _ ) =
                                    Phoenix.update cmd initModel
                            in
                            Expect.equal (Dict.get push.topic model.pushes) (Just push)
                    ]
                ]
            ]
        ]


type Msg
    = FakeSendMsg Phoenix.Message.Data


fakeSend : Phoenix.Message.Data -> Cmd Msg
fakeSend =
    Task.perform identity << Task.succeed << FakeSendMsg
