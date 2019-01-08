import { Socket } from 'phoenix';

export class SocketManager {

  constructor(ports) {
    this.sockets = {};
    this.ports = ports;
    ports.createSocket.subscribe(({endpoint, params, name}) => {
      params = params ? params : {};
      this.connect({endpoint, params, name});
    });
    ports.createChannel.subscribe(({socketName, topic, payload, messages}) => {
      this.channelInit(socketName, topic, payload, messages)
    });
  }

  connect(socketConfig) {
    let socket = new Socket(socketConfig.endpoint, socketConfig.params);
    socket.connect();
    socket.onOpen((payload) => this.ports.onOpen.send(payload));
    this.sockets[socketConfig.name] = socket;
  }

  channelInit(socketName, topic, channelPayload, messages) {
    let socket = this.sockets[socketName];
    let channel = socket.channel(topic, channelPayload);
    messages.forEach((message) => {
      channel.on(message, (payload) => {
        console.log(`Received message: ${message}`);
        this.ports.onMessageReceived.send({message, payload});
      });
    });
  }

}