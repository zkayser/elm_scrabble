import { Elm } from '../elm/Main.elm';
import css from '../css/app.css';

const ELM_DIV = document.getElementById("elm-scrabble");

console.log('Here is Elm.Main: ', Elm.Main);
let elmApp = Elm.Main.init(ELM_DIV);