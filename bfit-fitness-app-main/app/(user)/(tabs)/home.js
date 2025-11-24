import React, { useState, useEffect } from 'react';
import {
  StyleSheet,
  Text,
  View,
  ActivityIndicator,
  Alert,
  Image,
  ScrollView,
  StatusBar,
  TouchableOpacity,
} from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';
import { auth, db } from '../../../firebaseConfig';
import { onAuthStateChanged } from 'firebase/auth';
import {
  doc,
  getDoc,
  collection,
  getDocs,
  updateDoc,
} from 'firebase/firestore';

// Import the components this screen will display
import UserTrainerSelection from '../../components/UserTrainerSelection';
import UserWaitingScreen from '../../components/UserWaitingScreen';
import UserDashboard from '../../components/UserDashboard';

const UserHomeScreen = () => {
  const [userData, setUserData] = useState(null);
  const [trainers, setTrainers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activePlan, setActivePlan] = useState(null);
  const router = useRouter(); // Initialize router

  useEffect(() => {
    // This listener checks for login/logout
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        // If user is logged in, fetch all their data
        await fetchUserData(user.uid);
      } else {
        // User is logged out
        setUserData(null);
        setLoading(false);
      }
    });
    return () => unsubscribe(); // Cleanup listener on unmount
  }, []);

  // Main function to get the user's document from Firestore
  const fetchUserData = async (uid) => {
    setLoading(true);
    const userDocRef = doc(db, 'users', uid);
    try {
      const userDocSnap = await getDoc(userDocRef);
      if (userDocSnap.exists()) {
        const fetchedData = { id: userDocSnap.id, ...userDocSnap.data() };
        setUserData(fetchedData);

        // If user has no trainer, fetch the list of trainers
        if (!fetchedData.assignedTrainerId) {
          await fetchTrainers();
        }
        // If user has a plan, fetch the plan details
        if (fetchedData.hasActivePlan) {
          await fetchActivePlan(uid);
        }
      } else {
        console.log('User document not found!');
        setUserData(null);
      }
    } catch (error) {
      console.error('Error fetching user data:', error);
      setUserData(null);
    } finally {
      setLoading(false);
    }
  };

  // Fetches the user's active workout plan
  const fetchActivePlan = async (uid) => {
    try {
      const plansRef = collection(db, 'users', uid, 'workoutPlans');
      // We assume the user only has one plan
      const snapshot = await getDocs(plansRef); 
      const plans = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      if (plans.length > 0) {
        setActivePlan(plans[0]); // Set the first plan as active
      }
    } catch (error) {
      console.error('Error fetching active plan:', error);
    }
  };

  // Fetches all available trainers for the selection screen
  const fetchTrainers = async () => {
    const trainersCollectionRef = collection(db, 'trainers');
    try {
      const querySnapshot = await getDocs(trainersCollectionRef);
      const trainersList = querySnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));
      setTrainers(trainersList);
    } catch (error) {
      console.error('Error fetching trainers:', error);
    }
  };

  // Called when the user selects a trainer from the UserTrainerSelection component
  const handleSelectTrainer = async (trainerId) => {
    const userId = auth.currentUser.uid;
    const userDocRef = doc(db, 'users', userId);
    try {
      await updateDoc(userDocRef, {
        assignedTrainerId: trainerId,
        hasActivePlan: false, // Set to false, waiting for trainer
      });
      Alert.alert('Trainer Selected!', 'You are all set.');
      await fetchUserData(userId); // Re-fetch data to show the waiting screen
    } catch (error) {
      console.error('Error updating document: ', error);
      Alert.alert('Error', 'Could not select trainer.');
    }
  };

  // Reusable header component
  const renderHeader = () => (
    <View style={styles.inlineHeader}>
      <Image source={require('../../../assets/images/logo.png')} style={styles.logo} />
      <View>
        <Text style={styles.appName}>B-FIT</Text>
      </View>
    </View>
  );

  // Show loading spinner while fetching data
  if (loading) {
    return (
      <>
        <Stack.Screen options={{ headerShown: false }} />
        <View style={styles.loaderContainer}>
          {renderHeader()}
          <ActivityIndicator size="large" color="#F37307" />
        </View>
      </>
    );
  }

  // Once data is loaded, decide which screen to show
  if (userData) {
    return (
      <>
        <Stack.Screen options={{ headerShown: false }} />
        <ScrollView contentContainerStyle={styles.container}>
          {renderHeader()}

          {/* --- This is the main logic for the screen --- */}
          
          {/* 1. If user has NO trainer, show trainer selection */}
          {!userData.assignedTrainerId && (
            <UserTrainerSelection
              userData={userData}
              trainers={trainers}
              onSelectTrainer={handleSelectTrainer}
            />
          )}

          {/* 2. If user HAS a trainer but NO active plan, show waiting screen */}
          {userData.assignedTrainerId && !userData.hasActivePlan && (
            <UserWaitingScreen userData={userData} />
          )}

          {/* 3. If user HAS a trainer AND an active plan, show the full dashboard */}
          {userData.hasActivePlan && (
            <>
              {/* This component shows "Welcome back" and "Your Plan is Active!" */}
              <UserDashboard userData={userData} router={router} />

              {/* This card shows the Active Plan details */}
              {activePlan && (
                // --- Use the unified 'card' style ---
                <View style={styles.card}> 
                  <View style={styles.aiCardContent}>
                      <FontAwesome5 name="dumbbell" size={24} color="#F37307" />
                      <View style={styles.aiCardTextContainer}>
                        <Text style={styles.cardTitle}>Your Active Plan</Text>
                        <Text style={styles.cardText}>Plan Name: {activePlan.name}</Text>
                      </View>
                  </View>
                  {/* You can add a chevron arrow here if you want it to be pressable */}
                  {/* <FontAwesome5 name="chevron-right" size={16} color="#aaa" /> */}
                </View>
              )}

              {/* This card is the entry point for the AI Assistant */}
              <TouchableOpacity style={styles.card} onPress={() => router.push('../ai-chat')}>
                <View style={styles.aiCardContent}>
                    <FontAwesome5 name="robot" size={24} color="#F37307" />
                    <View style={styles.aiCardTextContainer}>
                      <Text style={styles.cardTitle}>AI Assistant</Text>
                      <Text style={styles.cardText}>Ask fitness & diet questions</Text>
                    </View>
                </View>
                <FontAwesome5 name="chevron-right" size={16} color="#aaa" />
              </TouchableOpacity>
            </>
          )}

        </ScrollView>
      </>
    );
  }

  // Fallback if data fails to load
  return (
    <>
      <Stack.Screen options={{ headerShown: false }} />
      <View style={styles.loaderContainer}>
        {renderHeader()}
        <Text>Could not load user data.</Text>
      </View>
    </>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingTop: StatusBar.currentHeight || 40,
    paddingHorizontal: 20, 
    paddingBottom: 40,
    backgroundColor: '#fff',
    minHeight: '100%',
  },
  loaderContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingTop: 50, 
    paddingHorizontal: 30, 
  },
  inlineHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 30,
    alignSelf: 'flex-start',
  },
  logo: {
    width: 50,
    height: 50,
    marginRight: 10,
    marginTop:15,
  },
  appName: {
    fontSize: 26,
    fontWeight: 'bold',
    color: '#F37307',
    marginTop:13,
  },
  // --- UNIFIED CARD STYLE ---
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between', // This will push chevron to the right
    backgroundColor: '#f9f9f9',
    borderRadius: 15,
    padding: 20,
    marginBottom: 20, 
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 5,
    elevation: 3,
    borderWidth: 1,
    borderColor: '#eee',
  },
  aiCardContent: { // Renamed to 'cardInnerContent' but represents the left part
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1, // Allow content to take available space
  },
  aiCardTextContainer: { // Renamed to 'cardTextContainer'
    flex: 1,
    marginLeft: 15,
  },
  cardTitle: {
    fontSize: 16, // Unified title size
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 4, 
  },
  cardText: {
    fontSize: 14,
    color: '#666',
    marginTop: 4,
  },
  // --- REMOVED REDUNDANT aiCard and planCard STYLES ---
  // --- KEPT planCard SPECIFIC STYLES ---
  planCard: {
    backgroundColor: '#f9f9f9',
    borderRadius: 15,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 5,
    elevation: 3,
    // Add row direction and justify to match aiCard if it becomes pressable
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  planTitle: { // This is now handled by cardTitle
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  planText: { // This is now handled by cardText
    fontSize: 15,
    color: '#555',
    marginBottom: 4,
  },
});

export default UserHomeScreen;


