import { collection, doc, getDocs, query, updateDoc, where, serverTimestamp } from "firebase/firestore";
import { auth, db } from "../firebase";



export const updateUser = async (points:any, score:any) => {
    const usersCollection = collection(db, "users"); // Reference to the users collection
    const q = query(usersCollection, where("email", "==", auth.currentUser?.email)); // Create a query to find the user by email
  
    try {
      const querySnapshot = await getDocs(q); // Execute the query
  
      if (querySnapshot.empty) {
        console.log('No user found with this email:', auth.currentUser?.email);
        return;
      }
  
      // Assuming emails are unique, get the first document
      const userDoc = querySnapshot.docs[0];
      const userRef:any = doc(db, "users", userDoc.id); // Get a reference to the user's document

      console.log('User found:', userDoc.data());
      console.log("points: ", points);
      // Update the user document
      await updateDoc(userRef, {
        points: userDoc.data()?.points + points, // Update the points field
        quiz:{
            score: userDoc.data().quiz?.score + score ,
            answered: true
        },
        updatedAt: serverTimestamp()
      });
      console.log('User data updated successfully:', userRef.id);
    } catch (error) {
      console.error('Error updating user data:', error);
    }
  };

  export const updateUserWheel = async (points:any) => {
    const usersCollection = collection(db, "users"); // Reference to the users collection
    const q = query(usersCollection, where("email", "==", auth.currentUser?.email)); // Create a query to find the user by email
  
    try {
      const querySnapshot = await getDocs(q); // Execute the query
  
      if (querySnapshot.empty) {
        console.log('No user found with this email:', auth.currentUser?.email);
        return;
      }
  
      // Assuming emails are unique, get the first document
      const userDoc = querySnapshot.docs[0];
      const userRef:any = doc(db, "users", userDoc.id); // Get a reference to the user's document

      console.log('User found:', userDoc.data());
      console.log("points: ", points);
      // Update the user document
      await updateDoc(userRef, {
        points: userDoc.data()?.points + points, // Update the points field
        updatedAt: serverTimestamp()
       
      
      });
      console.log('User data updated successfully:', userRef.id);
    } catch (error) {
      console.error('Error updating user data:', error);
    }
  };

  export const updateUserActivities = async(activities:any) => {

    const usersCollection = collection(db, "users"); // Reference to the users collection
    const q = query(usersCollection, where("email", "==", auth.currentUser?.email)); // Create a query to find the user by email
  
    try {
      const querySnapshot = await getDocs(q); // Execute the query
  
      if (querySnapshot.empty) {
        console.log('No user found with this email:', auth.currentUser?.email);
        return;
      }
  
      // Assuming emails are unique, get the first document
      const userDoc = querySnapshot.docs[0];
      const userRef:any = doc(db, "users", userDoc.id); // Get a reference to the user's document

      console.log('User found:', userDoc.data());
      console.log("activities: ", activities);
      // Update the user document
      await updateDoc(userRef, {
        activities: activities, // Update the activities field
        updatedAt: serverTimestamp()
      });
      console.log('User data updated successfully:', userRef.id);
    } catch (error) {
      console.error('Error updating user data:', error);
    }
  }

 export const updateUserLandscape = async(landscape:any) => {

    const usersCollection = collection(db, "users"); // Reference to the users collection
    const q = query(usersCollection, where("email", "==", auth.currentUser?.email)); // Create a query to find the user by email
  
    try {
      const querySnapshot = await getDocs(q); // Execute the query
  
      if (querySnapshot.empty) {
        console.log('No user found with this email:', auth.currentUser?.email);
        return;
      }
  
      // Assuming emails are unique, get the first document
      const userDoc = querySnapshot.docs[0];
      const userRef:any = doc(db, "users", userDoc.id); // Get a reference to the user's document

      console.log('User found:', userDoc.data());
      console.log("landscape: ", landscape);
      // Update the user document
      await updateDoc(userRef, {
        landscape: landscape, // Update the landscape field
        updatedAt: serverTimestamp()
      });
      console.log('User data updated successfully:', userRef.id);
    } catch (error) {
      console.error('Error updating user data:', error);
    }
  }
  
  
 
