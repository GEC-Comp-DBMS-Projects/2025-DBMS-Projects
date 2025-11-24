import { collection, doc, getDocs, query, where, getDoc } from "firebase/firestore";
import { auth, db } from "../firebase";
import AsyncStorage from '@react-native-async-storage/async-storage';

// Fetches places with similar activities and terrain to the current user
export const getplaces = async () => {
  try {
    // Get the current authenticated user's UID
    const currentUser = auth.currentUser;
    if (!currentUser) {
      console.log("User is not authenticated");
      return;
    }

    const usersCollection = collection(db, "users"); // Reference to the users collection
  const q1 = query(usersCollection, where("email", "==", auth.currentUser?.email)); // Create a query to find the user by email
  const querySnapshot1 = await getDocs(q1); // Execute the query

  if (querySnapshot1.empty) {
    console.log('No user found with this email:', auth.currentUser?.email);
    return;
  }

  // Assuming emails are unique, get the first document
  const userDoc1 = querySnapshot1.docs[0];

  console.log('User found:', userDoc1.id);


    const userUid = currentUser.uid;
    console.log('User UID:', userUid);

    // Fetch the user's data from Firestore using their UID
    const userDocRef = doc(db, "users", userDoc1.id);
    const userDoc = await getDoc(userDocRef);
      console.log('User found:', userDoc.data());
    if (!userDoc.exists()) {
      console.log("No user data found in Firestore");
      return;
    }

    const userData = userDoc.data();
    const userActivities = userData.activities;
    const userLandscape = userData.landscape;

    console.log('User activities:', userActivities);
    console.log('User landscape:', userLandscape);

    // Reference to the 'places' collection in Firestore
    const placesCollection = collection(db, "places");

    // Create a query to find places with matching activities and terrain
    const q = query(
      placesCollection,
      where("activities", "array-contains-any", userActivities) // Match any activity
    );

   

    // Execute the query
    const querySnapshot = await getDocs(q);

    if (querySnapshot.empty) {
      console.log("No places found with similar activities or terrain");
      return;
    }

    // Retrieve all matching places
    let places = querySnapshot.docs.map((doc) => doc.data());

    

    // Optionally store the places in AsyncStorage
    const jsonPlaces = JSON.stringify(places);
    console.log('Places saved to AsyncStorage:', jsonPlaces);
    await AsyncStorage.setItem('places', jsonPlaces);

    return places;

  } catch (error) {
    console.error("Error fetching similar places:", error);
  }
};


export const getquest = async () => {
  try {
    // Get the current authenticated user's UID
    const currentUser = auth.currentUser;
    if (!currentUser) {
      console.log("User is not authenticated");
      return;
    }

    const usersCollection = collection(db, "users"); // Reference to the users collection
  const q1 = query(usersCollection, where("email", "==", auth.currentUser?.email)); // Create a query to find the user by email
  const querySnapshot1 = await getDocs(q1); // Execute the query

  if (querySnapshot1.empty) {
    console.log('No user found with this email:', auth.currentUser?.email);
    return;
  }

  // Assuming emails are unique, get the first document
  const userDoc1 = querySnapshot1.docs[0];

  console.log('User found:', userDoc1.id);


    const userUid = currentUser.uid;
    console.log('User UID:', userUid);

    // Fetch the user's data from Firestore using their UID
    const userDocRef = doc(db, "users", userDoc1.id);
    const userDoc = await getDoc(userDocRef);
      console.log('User found:', userDoc.data());
    if (!userDoc.exists()) {
      console.log("No user data found in Firestore");
      return;
    }

    const userData = userDoc.data();
    const userActivities = userData.activities;
    const userLandscape = userData.landscape;

    console.log('User activities:', userActivities);
    console.log('User landscape:', userLandscape);

    // Reference to the 'places' collection in Firestore
    const placesCollection = collection(db, "quests");

    // Create a query to find places with matching activities and terrain
    const q = query(
      placesCollection,
      where("activities", "array-contains-any", userActivities) // Match any activity
    );

   

    // Execute the query
    const querySnapshot = await getDocs(q);

    if (querySnapshot.empty) {
      console.log("No places found with similar activities or terrain");
      return;
    }

    // Retrieve all matching places
    let places = querySnapshot.docs.map((doc) => doc.data());

    console.log("Que: ",places)

    // Optionally store the places in AsyncStorage
    const jsonPlaces = JSON.stringify(places);
    console.log('Places saved to AsyncStorage:', jsonPlaces);
    await AsyncStorage.setItem('places', jsonPlaces);

    return places;

  } catch (error) {
    console.error("Error fetching similar places:", error);
  }
};


export const getplacesTerrain = async () => {
  try {
    // Get the current authenticated user's UID
    const currentUser = auth.currentUser;
    if (!currentUser) {
      console.log("User is not authenticated");
      return;
    }

    const usersCollection = collection(db, "users"); // Reference to the users collection
  const q1 = query(usersCollection, where("email", "==", auth.currentUser?.email)); // Create a query to find the user by email
  const querySnapshot1 = await getDocs(q1); // Execute the query

  if (querySnapshot1.empty) {
    console.log('No user found with this email:', auth.currentUser?.email);
    return;
  }

  // Assuming emails are unique, get the first document
  const userDoc1 = querySnapshot1.docs[0];

  console.log('User found:', userDoc1.id);


    const userUid = currentUser.uid;
    console.log('User UID:', userUid);

    // Fetch the user's data from Firestore using their UID
    const userDocRef = doc(db, "users", userDoc1.id);
    const userDoc = await getDoc(userDocRef);
      console.log('User found:', userDoc.data());
    if (!userDoc.exists()) {
      console.log("No user data found in Firestore");
      return;
    }

    const userData = userDoc.data();
   
    const userLandscape = userData.landscape;
    console.log('User landscape:', userLandscape);
    

    // Reference to the 'places' collection in Firestore
    const placesCollection = collection(db, "places");

    // Create a query to find places with matching activities and terrain
    const q = query(
      placesCollection,
      where("terrain", "in", userLandscape) // Match any landscape in the user's landscape array
    );

   

    // Execute the query
    const querySnapshot = await getDocs(q);

    if (querySnapshot.empty) {
      console.log("No places found with similar activities or terrain");
      return;
    }

    // Retrieve all matching places
    const places = querySnapshot.docs.map((doc) => doc.data());

    console.log('Places found:', places);

    

    // Optionally store the places in AsyncStorage
    

    return places;

  } catch (error) {
    console.error("Error fetching similar places:", error);
  }
};

