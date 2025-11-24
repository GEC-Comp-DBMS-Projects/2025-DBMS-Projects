import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  ActivityIndicator,
} from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';
import { auth, db } from '../../firebaseConfig';
import { collection, query, where, getDocs } from 'firebase/firestore';

const WorkoutsDetailScreen = () => {
  const router = useRouter();
  const [completedLogs, setCompletedLogs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchCompletedWorkouts = async () => {
      try {
        const userId = auth.currentUser?.uid;
        if (!userId) return;

        const today = new Date();
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(today.getDate() - 6);

        const logsRef = collection(db, 'users', userId, 'progressLogs');
        const logsQuery = query(logsRef, where('createdAt', '>=', sevenDaysAgo));
        const snapshot = await getDocs(logsQuery);

        const logs = snapshot.docs.map(doc => doc.data());
        const completed = logs.filter(log => log.completed);

        setCompletedLogs(completed);
      } catch (error) {
        console.error('Error fetching completed workouts:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchCompletedWorkouts();
  }, []);

  return (
    <>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar barStyle="dark-content" />

      <ScrollView contentContainerStyle={styles.scrollContainer}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            <FontAwesome5 name="arrow-left" size={20} color="#333" />
          </TouchableOpacity>

          <View style={styles.logoContainer}>
            <Image source={require('../../assets/images/logo.png')} style={styles.logo} />
            <Text style={styles.appName}>B-FIT</Text>
          </View>
        </View>

        <Text style={styles.pageTitle}>Workout Details</Text>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Completed Workouts</Text>
          {loading ? (
            <ActivityIndicator size="large" color="#F37307" />
          ) : completedLogs.length === 0 ? (
            <Text style={styles.cardText}>No workouts completed yet.</Text>
          ) : (
            completedLogs.map((log, index) => (
              <View key={index} style={styles.logItem}>
                <Text style={styles.logText}>
                  ✅ {log.exerciseName} on {log.date} ({log.day})
                </Text>
                {log.caloriesBurned !== undefined && (
                  <Text style={styles.caloriesText}>
                    🔥 Calories Burned: {log.caloriesBurned} kcal
                  </Text>
                )}
              </View>
            ))
          )}
        </View>
      </ScrollView>
    </>
  );
};

const styles = StyleSheet.create({
  scrollContainer: {
    paddingTop: StatusBar.currentHeight || 40,
    paddingHorizontal: 30,
    paddingBottom: 40,
    backgroundColor: '#fff',
    minHeight: '100%',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 30,
    width: '100%',
  },
  backButton: {
    padding: 10,
    marginRight: 10,
  },
  logoContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  logo: {
    width: 40,
    height: 40,
    marginRight: 10,
  },
  appName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#F37307',
  },
  pageTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#212121',
    marginBottom: 20,
    alignSelf: 'center',
  },
  card: {
    width: '100%',
    backgroundColor: '#f9f9f9',
    borderRadius: 15,
    padding: 20,
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 5,
    elevation: 3,
    marginBottom: 20,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  cardText: {
    fontSize: 14,
    color: '#666',
  },
  logItem: {
    marginBottom: 12,
  },
  logText: {
    fontSize: 15,
    color: '#333',
  },
  caloriesText: {
    fontSize: 14,
    color: '#F37307',
    marginTop: 2,
  },
});

export default WorkoutsDetailScreen;