module Phoenix.ChannelTest exposing (suite)

import Expect
import Phoenix.Channel as Channel
import Phoenix.Internal.EntityState exposing (EntityState(..))
import Test exposing (..)


suite : Test
suite =
    describe "Channel" <|
        let
            channel =
                Channel.init "room:lobby"
        in
        [ describe "init"
            [ test "sets state to Initializing" <|
                \_ ->
                    Expect.equal channel.state Initializing
            ]
        , describe "joined"
            [ test "sets channel state to Connected" <|
                \_ ->
                    let
                        updatedChannel =
                            Channel.joined channel
                    in
                    Expect.equal updatedChannel.state Connected
            ]
        , describe "closed"
            [ test "sets channel state to Closed" <|
                \_ ->
                    let
                        updatedChannel =
                            Channel.closed channel
                    in
                    Expect.equal updatedChannel.state Closed
            ]
        , describe "errored"
            [ test "sets channel state to Errored" <|
                \_ ->
                    let
                        updatedChannel =
                            Channel.errored channel
                    in
                    Expect.equal updatedChannel.state Errored
            ]
        , describe "timedOut"
            [ test "sets channel state to TimedOut" <|
                \_ ->
                    let
                        updatedChannel =
                            Channel.timedOut channel
                    in
                    Expect.equal updatedChannel.state TimedOut
            ]
        , describe "leaveErrored"
            [ test "sets channel state to LeaveErrored" <|
                \_ ->
                    let
                        updatedChannel =
                            Channel.leaveErrored channel
                    in
                    Expect.equal updatedChannel.state LeaveErrored
            ]
        ]
