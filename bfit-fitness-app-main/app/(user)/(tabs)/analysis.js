import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ActivityIndicator,
  ScrollView,
  TouchableOpacity,
  Alert,
  Image,
} from 'react-native';
import { FontAwesome5 } from '@expo/vector-icons';
import { useRouter, Stack } from 'expo-router';
import { auth, db } from '../../../firebaseConfig';
import { doc, getDoc, collection, getDocs } from 'firebase/firestore';

const UserAnalyticsScreen = () => {
  const [analytics, setAnalytics] = useState(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const fetchAnalytics = async () => {
      setLoading(true);
      try {
        const userId = auth.currentUser?.uid;
        if (!userId) {
          setLoading(false);
          return;
        }

        // Fetch user profile data
        const userRef = doc(db, 'users', userId);
        const userSnap = await getDoc(userRef);
        const userData = userSnap.data() || {};

        // Fetch workout logs
        const logsRef = collection(db, 'users', userId, 'progressLogs');
        const logsSnap = await getDocs(logsRef);
        const logs = logsSnap.docs.map(doc => doc.data());

        // Filter completed workouts
        const completedLogs = logs.filter(log => log.completed);
        const totalWorkouts = completedLogs.length;
        const calories = completedLogs.reduce((sum, log) => sum + (log.caloriesBurned || 0), 0);

        const bmi = userData.bmi || 'N/A';
        const today = new Date();
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(today.getDate() - 6);

        const recentLogs = completedLogs.filter(log => {
          const logDate = new Date(log.date);
          return logDate >= sevenDaysAgo && logDate <= today;
        });

        const uniqueDays = new Set(
          recentLogs.map(log => new Date(log.date).toDateString())
        );

        const weeklyProgress = `${uniqueDays.size} of 7 days active`;

        setAnalytics({ bmi, totalWorkouts, calories, weeklyProgress });
      } catch (error) {
        console.error('Error fetching analytics:', error);
        setAnalytics({
          bmi: 'Error',
          totalWorkouts: 'Error',
          calories: 'Error',
          weeklyProgress: 'Error',
        });
      } finally {
        setLoading(false);
      }
    };

    fetchAnalytics();
  }, []);

  if (loading) {
    return (
      <View style={styles.loader}>
        <ActivityIndicator size="large" color="#F37307" />
      </View>
    );
  }

  if (!analytics) {
    return (
      <View style={styles.loader}>
        <Text style={styles.errorText}>Could not load analytics data.</Text>
      </View>
    );
  }

  const Card = ({ icon, title, value, route }) => (
    <TouchableOpacity
      style={styles.card}
      onPress={() =>
        route ? router.push(route) : Alert.alert('Coming Soon', 'Detailed view not yet available.')
      }
    >
      <FontAwesome5 name={icon} size={24} color="#F37307" />
      <View style={styles.cardContent}>
        <Text style={styles.cardTitle}>{title}</Text>
        <Text style={styles.cardValue}>{value}</Text>
      </View>
      <FontAwesome5 name="chevron-right" size={18} color="#999" />
    </TouchableOpacity>
  );

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Stack.Screen options={{ headerShown: false }} />

      {/* Header */}
      <View style={styles.header}>
        <Image source={require('../../../assets/images/logo.png')} style={styles.logo} />
        <Text style={styles.appName}>B-FIT</Text>
      </View>

      <Text style={styles.title}>Your Analytics</Text>

      <Card icon="heartbeat" title="BMI" value={analytics.bmi} route={'../bmi'} />
      <Card icon="dumbbell" title="Workouts Completed" value={analytics.totalWorkouts} route={'../workouts'} />
      <Card icon="fire" title="Calories Burned" value={`${analytics.calories} kcal`} route={'../calories'} />
      <Card icon="calendar-week" title="Weekly Progress" value={analytics.weeklyProgress} route={'../progress'} />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingBottom: 40,
    paddingHorizontal: 20,
    backgroundColor: '#fff',
    minHeight: '100%',
  },
  loader: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  errorText: {
    fontSize: 16,
    color: 'red',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingTop: 50,
    paddingBottom: 20,
    paddingHorizontal: 0,
  },
  logo: {
    width: 50,
    height: 50,
    marginRight: 10,
  },
  appName: {
    fontSize: 25,
    fontWeight: 'bold',
    color: '#F37307',
  },
  title: {
    fontSize: 26,
    fontWeight: 'bold',
    color: '#212121',
    marginBottom: 30,
    textAlign: 'center',
  },
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f9f9f9',
    borderRadius: 15,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
  },
  cardContent: {
    flex: 1,
    marginLeft: 15,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  cardValue: {
    fontSize: 18,
    color: '#555',
    marginTop: 5,
  },
});
export default UserAnalyticsScreen;