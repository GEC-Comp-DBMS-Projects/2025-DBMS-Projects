import React, { useState, useEffect } from 'react';
import { ActivityIndicator, View, StyleSheet } from 'react-native';
import { useRouter, useSegments, Slot } from 'expo-router';
import { onAuthStateChanged } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from '../firebaseConfig'; // Adjust path if needed

export default function RootLayout() {
  const [user, setUser] = useState(undefined); // undefined = initial loading
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const segments = useSegments();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (authenticatedUser) => {
      setUser(authenticatedUser); // Set auth state first

      if (authenticatedUser) {
        // Fetch Firestore data only if user is authenticated
        const userDocRef = doc(db, 'users', authenticatedUser.uid);
        const trainerDocRef = doc(db, 'trainers', authenticatedUser.uid);
        const userDocSnap = await getDoc(userDocRef);
        const trainerDocSnap = await getDoc(trainerDocRef);

        let fetchedData = null;
        if (userDocSnap.exists()) {
          fetchedData = userDocSnap.data();
        } else if (trainerDocSnap.exists()) {
          fetchedData = trainerDocSnap.data();
        }
        setUserData(fetchedData);
        setLoading(false); // Stop loading *after* fetching data
      } else {
        setUserData(null); // Clear user data immediately on logout
        setLoading(false); // Stop loading if logged out
      }
    });
    // Cleanup listener on unmount
    return () => unsubscribe();
  }, []); // Run only once on mount

  useEffect(() => {
    // Only run navigation logic *after* loading is complete
    if (loading) return;

    // Define routes that are considered part of the authentication flow (outside main app)
    const authRoutes = ['index', 'login', 'user-login', 'trainer-login', 'user-register', 'trainer-register'];
    // Check if the current route segment is one of the auth routes or if segments is empty (root)
    const isAuthRoute = segments.length === 0 || authRoutes.includes(segments[0]);

    if (user && userData) { // User logged in AND data fetched
      // Determine the correct group and starting screen based on role
      const targetGroup = userData.role === 'user' ? '(user)' : '(trainer)';
      const targetScreen = userData.role === 'user' ? '/home' : '/clients';
      const targetPath = `/${targetGroup}${targetScreen}`;

      // Redirect if not already within the correct group
      if (segments[0] !== targetGroup) {
        router.replace(targetPath);
      }
    } else if (!user) { // User is logged out
      // Redirect if not already on an auth route
      if (!isAuthRoute) {
        router.replace('/'); // Go back to the initial welcome screen (index.js)
      }
    }
    // Add segments to dependency array to re-evaluate when route changes
  }, [user, userData, loading, segments, router]);

  // Show loading indicator until authentication check and data fetch are complete
  if (loading) {
    return (
      <View style={styles.loaderContainer}>
        <ActivityIndicator size="large" color="#F37307" />
      </View>
    );
  }

  // Render the currently matched child route
  return <Slot />;
}

const styles = StyleSheet.create({
  loaderContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

