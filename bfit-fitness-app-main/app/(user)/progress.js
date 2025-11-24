import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  TouchableOpacity,
  StatusBar,
  Dimensions,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { Stack, useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';
import { BarChart } from 'react-native-chart-kit';
import { auth, db } from '../../firebaseConfig';
import { collection, query, where, getDocs } from 'firebase/firestore';

const screenWidth = Dimensions.get('window').width;
const chartWidth = screenWidth - 40;

const ProgressDetailScreen = () => {
  const router = useRouter();
  const [weeklyData, setWeeklyData] = useState({});
  const [completedLogs, setCompletedLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [streakCount, setStreakCount] = useState(0);

  useEffect(() => {
    const fetchProgress = async () => {
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
        const grouped = {
          Mon: 0,
          Tue: 0,
          Wed: 0,
          Thu: 0,
          Fri: 0,
          Sat: 0,
          Sun: 0,
        };
        const completed = [];

        const dayMap = {
          Sunday: 'Sun',
          Monday: 'Mon',
          Tuesday: 'Tue',
          Wednesday: 'Wed',
          Thursday: 'Thu',
          Friday: 'Fri',
          Saturday: 'Sat',
        };

        logs.forEach(log => {
          const fullDay = new Date(log.date).toLocaleDateString('en-US', { weekday: 'long' });
          const day = dayMap[fullDay];
          if (day) {
            grouped[day] += log.caloriesBurned || 0;
          }
          if (log.completed) completed.push(log);
        });

        setWeeklyData(grouped);
        setCompletedLogs(completed);
        setStreakCount(calculateStreak(logs));
      } catch (error) {
        console.error('Error fetching progress:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchProgress();
  }, []);

  const chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const chartData = chartLabels.map(day => weeklyData[day] || 0);
  const totalCalories = chartData.reduce((sum, val) => sum + val, 0);

  const calculateStreak = (logs) => {
    const dates = logs
      .filter(log => log.completed)
      .map(log => log.date)
      .filter((v, i, a) => a.indexOf(v) === i);

    dates.sort((a, b) => new Date(b) - new Date(a));
    let streak = 0;
    let current = new Date();

    for (let i = 0; i < dates.length; i++) {
      const logDate = new Date(dates[i]);
      const diff = Math.floor((current - logDate) / (1000 * 60 * 60 * 24));
      if (diff === streak) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  };

  const getBadge = (streak) => {
    if (streak >= 7) return '🏆 Consistency King';
    if (streak >= 3) return '🔥 Streak Starter';
    return '💡 Keep Going';
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Stack.Screen options={{ headerShown: false }} />
      <StatusBar barStyle="dark-content" />

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

      {/* Title */}
      <Text style={styles.title}>Weekly Progress Details</Text>

      {/* Chart Section */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Calories Burned</Text>
        <Text style={styles.totalCalories}>🔥 Total: {totalCalories} cal</Text>
        {loading ? (
          <ActivityIndicator size="large" color="#F37307" />
        ) : (
          <View style={styles.chartWrapper}>
            <BarChart
              data={{
                labels: chartLabels,
                datasets: [{ data: chartData }],
              }}
              width={chartWidth}
              height={260}
              fromZero
              showValuesOnTopOfBars
              yAxisSuffix=" cal"
              withInnerLines={true}
              withHorizontalLabels={true}
              chartConfig={{
                backgroundColor: '#fff',
                backgroundGradientFrom: '#fff',
                backgroundGradientTo: '#fff',
                decimalPlaces: 0,
                barPercentage: 0.6,
                color: (opacity = 1) => `rgba(243, 115, 7, ${opacity})`,
                labelColor: () => '#333',
                propsForLabels: { fontSize: 12 },
              }}
              style={styles.chart}
            />
          </View>
        )}
      </View>

      {/* Completed Workouts */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Completed Workouts</Text>
        {completedLogs.length === 0 ? (
          <Text style={styles.cardText}>No workouts completed yet.</Text>
        ) : (
          completedLogs.map((log, index) => (
            <Text key={index} style={styles.logText}>
              ✅ {log.exerciseName} on {log.date} ({log.day}) — {log.caloriesBurned} cal
            </Text>
          ))
        )}
      </View>

      {/* Streak Badge */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Your Streak</Text>
        <Text style={styles.streakText}>🔥 {streakCount} day streak</Text>
        <Text style={styles.badge}>{getBadge(streakCount)}</Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingTop: StatusBar.currentHeight || 40,
    paddingHorizontal: 20,
    paddingBottom: 40,
    backgroundColor: '#fff',
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
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#212121',
    marginBottom: 20,
    alignSelf: 'center',
  },
  card: {
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
  totalCalories: {
    fontSize: 16,
    fontWeight: '600',
    color: '#065f46',
    marginBottom: 10,
  },
  chartWrapper: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingBottom: 20,
    paddingHorizontal: 10,
  },
  chart: {
    marginTop: 10,
    borderRadius: 10,
  },
  cardText: {
    fontSize: 14,
    color: '#666',
  },
  logText: {
    fontSize: 15,
    color: '#333',
    marginBottom: 6,
  },
  streakText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#F37307',
    marginBottom: 6,
  },
  badge: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#212121',
  },
});

export default ProgressDetailScreen;