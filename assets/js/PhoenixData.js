import { Socket } from 'phoenix';

const TAGS = {
  CREATE_SOCKET: 'CreateSocket',
  CREATE_CHANNEL: 'CreateChannel',
  CREATE_PUSH: 'CreatePush',
  SOCKET_OPENED: 'SocketOpened',
  CHANNEL_MESSAGE_RECEIVED: 'ChannelMessageReceived'
};

export class PhoenixData {

  constructor({incoming, outgoing}) {
    this.socket = null;
    this.channels = {};
    this.incoming = incoming;
    this.outgoing = outgoing;
    outgoing.subscribe(({tag, data}) => {
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
    socket.onOpen(() => this.incoming.send({tag: TAGS.SOCKET_OPENED, data: {}}));
    this.socket = socket;
  }

  channelInit({topic, payload, messages}) {
    let channel = this.socket.channel(topic, payload);
    channel.join()
      .receive("ok", ({messages}) => {
       return  { tag: TAGS.CHANNEL_JOINED, data: messages }
      })
      .receive("error", ({reason}) => {
        return { tag: TAGS.CHANNEL_JOIN_FAILED, data: reason }
      })
      .receive("timeout", () => {
        return { tag: TAGS.CHANNEL_JOIN_TIMEOUT, data: {} }
      })

    this.channels[topic] = channel;
    messages.forEach((message) => {
      channel.on(message, (payload) => {
        this.incoming.send({tag: TAGS.CHANNEL_MESSAGE_RECEIVED, data: { payload: payload, topic, message}});
      });
    });
  }

  handlePush({topic, event, payload}) {
    if (!this.channels[topic]) {
      return;
    }

    const channel = this.channels[topic];
    channel.push(event, payload);
  }
}