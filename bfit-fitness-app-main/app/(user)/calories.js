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

const CaloriesDetailScreen = () => {
  const router = useRouter();

  const [weeklyData, setWeeklyData] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchCalories = async () => {
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
        });

        setWeeklyData(grouped);
      } catch (error) {
        console.error('Error fetching calories:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchCalories();
  }, []);

  const chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const chartData = chartLabels.map(day => weeklyData[day] || 0);
  const totalCalories = chartData.reduce((sum, val) => sum + val, 0);

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
      <Text style={styles.title}>Calories Burned Details</Text>

      {/* Chart */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Weekly Summary</Text>
        <Text style={styles.totalCalories}>🔥 Total: {totalCalories} kcal</Text>

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
              height={300}
              fromZero
              showValuesOnTopOfBars
              yAxisSuffix=" kcal"
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
    marginTop: 10,
  },
  chart: {
    borderRadius: 10,
  },
});

export default CaloriesDetailScreen;