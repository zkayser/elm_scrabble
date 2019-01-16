import { Socket } from 'phoenix';

const TAGS = {
  CREATE_SOCKET: 'CreateSocket',
  CREATE_CHANNEL: 'CreateChannel',
  CREATE_PUSH: 'CreatePush',
  DISCONNECT: 'Disconnect',
  LEAVE_CHANNEL: 'LeaveChannel',
  SOCKET_OPENED: 'SocketOpened',
  SOCKET_CLOSED: 'SocketClosed',
  SOCKET_ERRORED: 'SocketErrored',
  CHANNEL_JOINED: 'ChannelJoined',
  CHANNEL_JOIN_ERROR: 'ChannelJoinError',
  CHANNEL_JOIN_TIMEOUT: 'ChannelJoinTimeout',
  CHANNEL_LEFT: 'ChannelLeft',
  CHANNEL_LEAVE_ERROR: 'ChannelLeaveError',
  CHANNEL_MESSAGE_RECEIVED: 'ChannelMessageReceived'
};

export class PhoenixData {

  constructor({incoming, outgoing}) {
    this.socket = null;
    this.channels = {};
    this.toElm = incoming;
    this.fromElm = outgoing;
    this.fromElm.subscribe(({tag, data}) => {
      switch (tag) {
        case TAGS.CREATE_SOCKET:
          this.connect(data);
          break;
        case TAGS.CREATE_CHANNEL:
          this.channelInit(data);
          break;
        case TAGS.CREATE_PUSH:
          this.handlePush(data)
          break;
        case TAGS.DISCONNECT:
          this.disconnectSocket();
          break;
        case TAGS.LEAVE_CHANNEL:
          this.leaveChannel(data)
          break;
        default:
          console.warn(`[JS]: Received an unknown message from Elm: ${tag} with data: `, data);
      }
    });
  }

  connect({endpoint, params, debug}) {
    if (this.socket && this.socket.connected()) {
      return;
    }
    let logger;
    if (debug) {
      logger = (kind, msg, data) => console.log(`${kind}: ${msg}`, data)
    };

    const socket = new Socket(endpoint, { ...params, logger: logger });
    socket.connect();
    socket.onOpen(() => this.toElm.send({tag: TAGS.SOCKET_OPENED, data: {}}));
    socket.onClose(() => this.toElm.send({tag: TAGS.SOCKET_CLOSED, data: {}}));
    socket.onError((error) => this.toElm.send({tag: TAGS.SOCKET_ERRORED, data: { error }}));
    this.socket = socket;
  }

  disconnectSocket() {
    if (this.socket && this.socket.connected()) {
      this.socket.disconnect();
    }
  }

  channelInit({topic, payload, messages}) {
    let channel = this.socket.channel(topic, payload);
    channel.join()
      .receive("ok", (payload) => {
       this.toElm.send({ tag: TAGS.CHANNEL_JOINED, data: { payload, topic, message: TAGS.CHANNEL_JOINED } });
      })
      .receive("error", (error) => {
        this.toElm.send({ tag: TAGS.CHANNEL_JOIN_ERROR, data: { payload: error, topic, message: TAGS.CHANNEL_JOIN_ERROR } });
      })
      .receive("timeout", () => {
        this.toElm.send({ tag: TAGS.CHANNEL_JOIN_TIMEOUT, data: { payload: {}, topic, message: TAGS.CHANNEL_JOIN_TIMEOUT } });
      })

    messages.forEach((message) => {
      channel.on(message, (payload) => {
        this.toElm.send({tag: TAGS.CHANNEL_MESSAGE_RECEIVED, data: { payload: payload, topic, message}});
      });
    });

    this.channels[topic] = channel;
  }

  leaveChannel({topic}) {
    if (this.channels[topic]) {
      const channel = this.channels[topic];
      channel.leave()
        .receive("ok", (payload) => {
          this.toElm.send({ tag: TAGS.CHANNEL_LEFT, data: { payload, topic, message: TAGS.CHANNEL_LEFT }});
          delete this.channels[topic];
        })
        .receive("error", (error) => {
          this.toElm.send({ tag: TAGS.CHANNEL_LEAVE_ERROR, data: { payload: error, topic, message: TAGS.CHANNEL_LEAVE_ERROR }});
        });
    }
  }

  handlePush({topic, event, payload}) {
    if (!this.channels[topic]) {
      return;
    }

    const channel = this.channels[topic];
    channel.push(event, payload);
  }
}