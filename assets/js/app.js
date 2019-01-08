import { Elm } from '../elm/Main.elm';
import { SocketManager } from './socket-manager';
import { Socket } from 'phoenix';
import css from '../css/app.css';

const ELM_DIV = document.getElementById("elm-scrabble");
const elmApp = Elm.Main.init(ELM_DIV);
new SocketManager(elmApp.ports);