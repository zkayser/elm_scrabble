import { Socket } from 'phoenix';

export class SocketManager {

  constructor(ports) {
    this.sockets = {};
    this.channels = {};
    this.ports = ports;
    ports.createSocket.subscribe(({endpoint, params, name}) => {
      params = params ? params : {};
      this.connect({endpoint, params, name});
    });
    ports.createChannel.subscribe(({socketName, topic, payload, messages}) => {
      this.channelInit(socketName, topic, payload, messages)
    });
    ports.push.subscribe(({topic, event, payload}) => {
      this.handlePush(topic, event, payload)
    });
  }

  connect(socketConfig) {
    let socket = new Socket(socketConfig.endpoint, {params: socketConfig.params, logger: (kind, msg, data) => {
      console.log(`${kind}: ${msg}`, data);
    }});
    socket.connect();
    socket.onOpen((payload) => this.ports.onOpen.send(payload));
    this.sockets[socketConfig.name] = socket;
  }

  channelInit(socketName, topic, channelPayload, messages) {
    let socket = this.sockets[socketName];
    let channel = socket.channel(topic, channelPayload);
    channel.join();
    this.channels[topic] = channel;
    messages.forEach((message) => {
      channel.on(message, (payload) => {
        this.ports.onMessageReceived.send({topic, message, payload});
      });
    });
  }

  handlePush(topic, event, payload) {
    let channel = this.channels[topic];
    channel.push(event, payload);
  }
}