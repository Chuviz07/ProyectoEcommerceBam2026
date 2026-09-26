importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js'
);

importScripts(
  'https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js'
);

firebase.initializeApp({
  apiKey: 'AIzaSyADO-CQt1B9P6yMj8DrXdvLQr4S0SWv_Kk',
  authDomain: 'ecommerce-f1328.firebaseapp.com',
  projectId: 'ecommerce-f1328',
  storageBucket: 'ecommerce-f1328.firebasestorage.app',
  messagingSenderId: '203291514929',
  appId: '1:203291514929:web:cd5daea8089992eefa9d10',
  measurementId: 'G-WGYGY706TF',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log(
    '[firebase-messaging-sw.js] Mensaje recibido en segundo plano:',
    message
  );
});