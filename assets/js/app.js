import { Elm } from '../elm/Main.elm';
import { PhoenixData } from './PhoenixData';
import { Socket } from 'phoenix';
import css from '../css/app.css';

const ELM_DIV = document.getElementById("elm-scrabble");
const elmApp = Elm.Main.init(ELM_DIV);
new PhoenixData(elmApp.ports);