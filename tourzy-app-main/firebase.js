// // Import the functions you need from the SDKs you need
// import * as firebase from "firebase/compat"
// // TODO: Add SDKs for Firebase products that you want to use
// // https://firebase.google.com/docs/web/setup#available-libraries

// // Your web app's Firebase configuration
// const firebaseConfig = {
//   apiKey: "AIzaSyASmOt-boxd1fuSKOlnVHyvQ2P9Ho3I1MU",
//   authDomain: "tourist-platform.firebaseapp.com",
//   projectId: "tourist-platform",
//   storageBucket: "tourist-platform.appspot.com",
//   messagingSenderId: "994084816234",
//   appId: "1:994084816234:web:7af1276516ce9f74b79113"
// };

// // Initialize Firebase
// let app;
// if (firebase.apps.length === 0) {
//   app = firebase.initializeApp(firebaseConfig);
// } else {
//   app = firebase.app()
// }

// const auth = firebase.auth()

// export { auth };

import AsyncStorage from "@react-native-async-storage/async-storage";
import { initializeApp } from "firebase/app";
import {
  getReactNativePersistence,
  initializeAuth,
} from "firebase/auth";
import { getFirestore, initializeFirestore } from "firebase/firestore";

export const firebaseApp = initializeApp({
  apiKey: "AIzaSyASmOt-boxd1fuSKOlnVHyvQ2P9Ho3I1MU",
  authDomain: "tourist-platform.firebaseapp.com",
  projectId: "tourist-platform",
  storageBucket: "tourist-platform.appspot.com",
  messagingSenderId: "994084816234",
  appId: "1:994084816234:web:7af1276516ce9f74b79113"
});

// Initialize Firestore with settings
export const db = initializeFirestore(firebaseApp, {
  experimentalForceLongPolling: true,
  useFetchStreams: false,
  cacheSizeBytes: 50000000, // 50 MB
});

export const auth = initializeAuth(firebaseApp, {
  persistence: getReactNativePersistence(AsyncStorage),
});