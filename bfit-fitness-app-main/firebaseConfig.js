// firebaseConfig.js
import { initializeApp } from "firebase/app";
import { getAuth, initializeAuth, getReactNativePersistence } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { Platform } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";

// Your Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyDcopSI4RcmFo9aX5vttvJDQ6k95TPczuc",
  authDomain: "bfit-6da5a.firebaseapp.com",
  projectId: "bfit-6da5a",
  storageBucket: "bfit-6da5a.firebasestorage.app",
  messagingSenderId: "52039809629",
  appId: "1:52039809629:web:6d921c6771be733a5eebb4",
  measurementId: "G-ERJVJQ4FXJ",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

let auth;

// 👇 Handle different platforms properly
if (Platform.OS === "web") {
  // Web: normal getAuth (no async storage)
  auth = getAuth(app);
} else {
  // Native (Expo Go): use React Native persistence
  auth = initializeAuth(app, {
    persistence: getReactNativePersistence(AsyncStorage),
  });
}

// Firestore stays the same
const db = getFirestore(app);

export { auth, db };
