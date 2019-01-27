import './main.css';
import { Elm } from './Main.elm';

const posts = localStorage.getItem('posts');

function getImage() {
  const image = localStorage.getItem('image');
  console.log('getimage', image);

  if (image && isTodaysImage(image)) {
    return image;
  }

  return null;
}

function isTodaysImage(image) {
  const imagesDate = new Date(image.date).getDate();
  const currentDate = new Date().getDate();

  return imagesDate === currentDate;
}

const app = Elm.Main.init({
  flags: {
    apiUrl: process.env.ELM_APP_NASA_API_URL,
    cachedImage: getImage(),
    cachedTodos: posts ? JSON.parse(posts) : null,
  },
  node: document.getElementById('root'),
});

app.ports.saveImage.subscribe(data => {
  localStorage.setItem('image', JSON.stringify(data));
});

app.ports.savePost.subscribe(data => {
  const posts = localStorage.getItem('posts');
  const dataToSave = posts ? JSON.parse(posts).concat(data) : [data];

  localStorage.setItem('posts', JSON.stringify(dataToSave));
});
