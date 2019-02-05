module SocketTest exposing (suite)

import Expect
import Phoenix.Internal.EntityState exposing (EntityState(..))
import Phoenix.Socket as Socket exposing (Socket)
import Test exposing (..)


suite : Test
suite =
    describe "Socket" <|
        let
            socket =
                Socket.init "/socket"
        in
        [ describe "init"
            [ test "state starts out as Initializing" <|
                \_ ->
                    Expect.equal socket.state Initializing
            ]
        , describe "close"
            [ test "sets state to Closed" <|
                \_ ->
                    let
                        updatedSocket =
                            Socket.close socket
                    in
                    Expect.equal updatedSocket.state Closed
            ]
        , describe "errored"
            [ test "sets state to Errored" <|
                \_ ->
                    let
                        updatedSocket =
                            Socket.errored socket
                    in
                    Expect.equal updatedSocket.state Errored
            ]
        , describe "opened"
            [ test "sets state to Connected" <|
                \_ ->
                    let
                        updatedSocket =
                            Socket.opened socket
                    in
                    Expect.equal updatedSocket.state Connected
            ]
        ]
