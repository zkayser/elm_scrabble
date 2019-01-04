import { Elm } from '../elm/Main.elm';
import { Socket } from 'phoenix';
import css from '../css/app.css';

const ELM_DIV = document.getElementById("elm-scrabble");
let elmApp = Elm.Main.init(ELM_DIV);

elmApp.ports.createSocket.subscribe(({endpoint}) => {
  let socket = new Socket(endpoint, {params: {}});
  socket.connect();
  elmApp.ports.socketCreated.send(socket);
});

