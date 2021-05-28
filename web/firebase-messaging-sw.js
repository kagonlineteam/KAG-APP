importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyAFpBzKmDDJIL-3Y43tvC7mfHjCaWdwK5A",
    authDomain: "kag-api.firebaseapp.com",
    databaseURL: "https://kag-api.firebaseio.com",
    projectId: "kag-api",
    storageBucket: "kag-api.appspot.com",
    messagingSenderId: "932178639950",
    appId: "1:932178639950:web:a51a16deb1f1c001c7971f"
});

const messaging = firebase.messaging();