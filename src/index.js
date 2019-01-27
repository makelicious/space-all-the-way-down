import './main.css';
import { Elm } from './Main.elm';

Elm.Main.init({
  flags: process.env.ELM_APP_NASA_API_URL,
  node: document.getElementById('root'),
});
