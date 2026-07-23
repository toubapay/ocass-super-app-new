importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyB53XTeYKEWeFOi9k0uc3sEqGp5V_NbrPU",
  authDomain: "ocass-by-devteam.firebaseapp.com",
  databaseURL: "https://ocass-by-devteam-default-rtdb.firebaseio.com",
  projectId: "ocass-by-devteam",
  storageBucket: "ocass-by-devteam.firebasestorage.app",
  messagingSenderId: "362253661054",
  appId: "1:362253661054:web:79188a5f991a317887f92f",
  measurementId: "G-J0TDBDNQ55"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});