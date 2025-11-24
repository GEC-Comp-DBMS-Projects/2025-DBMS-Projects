import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  ScrollView,
  ActivityIndicator,
  TouchableOpacity,
  Dimensions,
} from 'react-native';
import { auth, db } from '../../../firebaseConfig';
import {
  collection,
  getDocs,
  addDoc,
  serverTimestamp,
} from 'firebase/firestore';

const screenWidth = Dimensions.get('window').width;
const dayWidth = screenWidth / 7;

const UserPlansScreen = () => {
  const [plans, setPlans] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [completedExercises, setCompletedExercises] = useState({});

  useEffect(() => {
    const fetchPlansAndLogs = async () => {
      try {
        const userId = auth.currentUser?.uid;
        if (!userId) return;

        const plansRef = collection(db, 'users', userId, 'workoutPlans');
        const snapshot = await getDocs(plansRef);
        const planList = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        setPlans(planList);

        const logsRef = collection(db, 'users', userId, 'progressLogs');
        const logsSnapshot = await getDocs(logsRef);

        const completedMap = {};
        logsSnapshot.docs.forEach(doc => {
          const data = doc.data();
          if (data.completed) {
            const key = `${data.day.toLowerCase()}-${data.exerciseName}-${data.date}`;
            completedMap[key] = true;
          }
        });

        setCompletedExercises(completedMap);
      } catch (error) {
        console.error('Error fetching plans or logs:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchPlansAndLogs();
  }, []);

  const getDayName = (date) => {
    return date.toLocaleDateString('en-US', { weekday: 'long' });
  };

  const getWeekDates = () => {
    const today = new Date();
    const startOfWeek = new Date(today);
    startOfWeek.setDate(today.getDate() - today.getDay() + 1);
    return Array.from({ length: 7 }, (_, i) => {
      const d = new Date(startOfWeek);
      d.setDate(startOfWeek.getDate() + i);
      return d;
    });
  };

  const handleToggleExercise = async (dayName, index, exerciseName) => {
    const today = new Date().toDateString();
    const selected = selectedDate.toDateString();
    const dateKey = new Date().toISOString().split('T')[0];
    const key = `${dayName}-${exerciseName}-${dateKey}`;

    if (today !== selected || completedExercises[key]) return;

    const userId = auth.currentUser?.uid;
    setCompletedExercises(prev => ({ ...prev, [key]: true }));

    const normalizedDay = dayName.toLowerCase();
    const plan = plans[0];
    const dayData = plan?.days?.[normalizedDay];
    const caloriesBurned = dayData?.targetCalories || 0;

    try {
      const logRef = collection(db, 'users', userId, 'progressLogs');
      await addDoc(logRef, {
        date: dateKey,
        day: dayName,
        exerciseName,
        completed: true,
        caloriesBurned,
        createdAt: serverTimestamp(),
      });
    } catch (error) {
      console.error('Error saving progress log:', error);
    }
  };

  const renderExercises = (dayName) => {
    const normalizedDay = dayName.toLowerCase();
    const plan = plans[0];
    const dayData = plan?.days?.[normalizedDay];
    const exercises = dayData?.exercises || [];
    const targetCalories = dayData?.targetCalories || 0;

    const selectedDateStr = selectedDate.toISOString().split('T')[0];
    const todayDateStr = new Date().toISOString().split('T')[0];
    const isToday = selectedDateStr === todayDateStr;
    const isPast = new Date(selectedDateStr) < new Date(todayDateStr);

    return (
      <>
        {targetCalories > 0 && (
          <Text style={styles.cardText}>🎯 Target Calories: {targetCalories} kcal</Text>
        )}
        {exercises.length === 0 ? (
          <Text style={styles.cardText}>Rest day or no exercises assigned.</Text>
        ) : (
          exercises.map((exercise, index) => {
            const key = `${normalizedDay}-${exercise.exerciseName}-${selectedDateStr}`;
            const isDone = completedExercises[key];
            const isMissed = isPast && !isDone;
            const isDisabled = !isToday || isDone || isMissed;

            return (
              <TouchableOpacity
                key={key}
                style={[
                  styles.exerciseButton,
                  isDone && styles.exerciseDoneButton,
                  isMissed && styles.exerciseMissedButton,
                  isDisabled && { opacity: 0.6 },
                ]}
                disabled={isDisabled}
                onPress={() => handleToggleExercise(normalizedDay, index, exercise.exerciseName)}
              >
                <Text style={[
                  styles.exerciseText,
                  isDone && styles.exerciseDoneText,
                  isMissed && styles.exerciseMissedText,
                ]}>
                  {isDone ? '✅ Done' : isMissed ? '❌ Not Done' : exercise.exerciseName}
                </Text>

                {Object.entries(exercise).map(([param, value]) => {
                  if (param === 'exerciseName' || value === '' || value === null) return null;
                  return (
                    <Text key={param} style={styles.paramText}>
                      • {param}: {value}
                    </Text>
                  );
                })}
              </TouchableOpacity>
            );
          })
        )}
      </>
    );
  };

  const selectedDayName = getDayName(selectedDate);

  return (
    <ScrollView contentContainerStyle={styles.scrollContainer}>
      <View style={styles.header}>
        <Image source={require('../../../assets/images/logo.png')} style={styles.logo} />
        <Text style={styles.appName}>B-FIT</Text>
      </View>

      <Text style={styles.pageTitle}>My Plans</Text>

      {loading ? (
        <ActivityIndicator size="large" color="#F37307" />
      ) : plans.length === 0 ? (
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Workout Plan</Text>
          <Text style={styles.cardText}>Your trainer hasn't assigned a workout plan yet.</Text>
        </View>
      ) : (
        <>
          <Text style={styles.sectionTitle}>This Week</Text>
          <View style={styles.weekStrip}>
            {getWeekDates().map((date) => {
              const isToday = date.toDateString() === new Date().toDateString();
              const isSelected = date.toDateString() === selectedDate.toDateString();
              return (
                <TouchableOpacity
                  key={date.toISOString()}
                  style={[
                    styles.dayButton,
                    isSelected && styles.activeDayButton,
                    isToday && styles.todayBorder,
                  ]}
                  onPress={() => setSelectedDate(date)}
                >
                  <Text style={[styles.dayText, isSelected && styles.activeDayText]}>
                    {date.toLocaleDateString('en-US', { weekday: 'short' })}
                  </Text>
                  <Text style={[styles.dateText, isSelected && styles.activeDayText]}>
                    {date.getDate()}
                  </Text>
                </TouchableOpacity>
              );
            })}
          </View>

          <View style={styles.card}>
            <Text style={styles.cardTitle}>{selectedDayName}'s Exercises</Text>
            {renderExercises(selectedDayName)}
          </View>
        </>
      )}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  scrollContainer: {
    padding: 20,
    backgroundColor: '#fff',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    marginBottom: 10,
  },
  logo: {
    width: 50,
    height: 50,
    marginRight: 10,
    marginTop: 15,
  },
  appName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#F37307',
    marginTop: 12,
  },
  pageTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#212121',
    marginBottom: 20,
    alignSelf: 'center',
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  weekStrip: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  dayButton: {
    alignItems: 'center',
    paddingVertical: 10,
    width: dayWidth - 10,
    backgroundColor: '#eee',
    borderRadius: 10,
  },
  activeDayButton: {
    backgroundColor: '#F37307',
  },
  todayBorder: {
    borderWidth: 2,
    borderColor: '#F37307',
  },
  dayText: {
    fontSize: 14,
    color: '#555',
  },
  dateText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  activeDayText: {
    color: '#fff',
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
  cardText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 10,
  },
  exerciseButton: {
    backgroundColor: '#F37307',
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 10,
    marginBottom: 10,
  },
  exerciseText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  exerciseDoneButton: {
    backgroundColor: '#d1fae5',
  },
  exerciseDoneText: {
    color: '#065f46',
    textDecorationLine: 'line-through',
  },
});

export default UserPlansScreen;