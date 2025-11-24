// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDsLAVgD0uViykhJ7sUbrugNADv56MwELg",
  authDomain: "kasse-afadc.firebaseapp.com",
  projectId: "kasse-afadc",
  storageBucket: "kasse-afadc.firebasestorage.app",
  messagingSenderId: "195861027803",
  appId: "1:195861027803:web:96776a51cb4737e9a425fe"
};

// Initialize Firebase
export const app = initializeApp(firebaseConfig)
export const auth = getAuth(app) // Initialize Firebase Auth
export const db = getFirestore(app) // Initialize Firebase Firestore