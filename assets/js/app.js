import { Elm } from '../elm/Main.elm';
import css from '../css/app.css';

const ELM_DIV = document.getElementById("elm-scrabble");
let elmApp = Elm.Main.init(ELM_DIV);