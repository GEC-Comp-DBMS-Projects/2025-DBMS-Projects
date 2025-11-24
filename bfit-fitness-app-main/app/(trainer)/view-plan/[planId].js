import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, Alert, ScrollView, TouchableOpacity, Image } from 'react-native';
import { Stack, useLocalSearchParams, useRouter } from 'expo-router';
// Adjust path needed if firebaseConfig is elsewhere
import { db } from '../../../firebaseConfig';
// Adjust path needed if TrainerHeader is elsewhere
import TrainerHeader from '../../components/TrainerHeader';
import { doc, getDoc } from 'firebase/firestore'; // Removed unused imports
import { FontAwesome5 } from '@expo/vector-icons';


// Define days including Sunday for potential display
const DAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

const ViewPlanScreen = () => {
    // Get planId and clientId from the route parameters
    const { planId, clientId, clientName } = useLocalSearchParams();
    const [planData, setPlanData] = useState(null);
    const [loading, setLoading] = useState(true);
    const router = useRouter();

    useEffect(() => {
        if (!planId || !clientId) {
            Alert.alert("Error", "Missing Plan or Client ID.");
            setLoading(false);
            return;
        }
        console.log("Loading plan:", planId, "for client:", clientId); // Debug log

        const fetchPlanDetails = async () => {
            setLoading(true);
            try {
                // Construct the path to the specific plan document within the user's subcollection
                const planRef = doc(db, 'users', String(clientId), 'workoutPlans', String(planId));
                const planSnap = await getDoc(planRef);

                if (planSnap.exists()) {
                    setPlanData({ id: planSnap.id, ...planSnap.data() });
                    console.log("Plan data loaded:", planSnap.data().name); // Debug log
                } else {
                    Alert.alert("Error", "Workout plan not found.");
                     console.log("Plan document not found at path:", planRef.path); // Debug log
                }
            } catch (error) {
                console.error("Error fetching plan details: ", error);
                Alert.alert("Error", "Could not fetch plan details.");
            } finally {
                setLoading(false);
            }
        };

        fetchPlanDetails();
    }, [planId, clientId]); // Re-run if IDs change

     // Functions to get badge styles based on level
     const getBadgeColor = (level) => {
        switch (level?.toLowerCase()) {
            case 'intermediate': return '#FFF0E0';
            case 'beginner': return '#E0F2FE';
            case 'advanced': return '#FEE2E2';
            default: return '#F3F4F6';
        }
    };
    const getBadgeTextColor = (level) => {
         switch (level?.toLowerCase()) {
            case 'intermediate': return '#F37307';
            case 'beginner': return '#0284C7';
            case 'advanced': return '#DC2626';
            default: return '#6B7280';
        }
    }


     if (loading) {
        return (
            <View style={styles.loaderContainer}>
                 <ActivityIndicator size="large" color="#F37307" />
                 <Text style={styles.loadingText}>Loading Plan Details...</Text>
            </View>
        );
    }

    // Show error message if planData is still null after loading
    if (!planData) {
         return (
             <View style={styles.container}>
                {/* Use Stack Screen to potentially set title if needed, but hide default */}
                <Stack.Screen options={{ headerShown: false }} />
                <TrainerHeader/>
                 <View style={styles.screenHeader}>
                     <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
                        <FontAwesome5 name="arrow-left" size={20} color="#555" />
                     </TouchableOpacity>
                     <Text style={styles.screenTitle}>View Plan</Text>
                     <View style={{width: 30}} />
                 </View>
                <Text style={styles.errorText}>Plan data could not be loaded.</Text>
             </View>
         );
    }

    return (
        <View style={styles.container}>
            {/* Hide the default Stack header */}
            <Stack.Screen options={{ headerShown: false }} />
            <TrainerHeader />
             {/* Custom Header with Back Button and Title */}
             <View style={styles.screenHeader}>
                 <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
                    <FontAwesome5 name="arrow-left" size={20} color="#555" />
                 </TouchableOpacity>
                 <Text style={styles.screenTitle}>{planData.name || 'Workout Plan'}</Text>
                 <View style={{width: 30}} /> {/* Spacer to balance title */}
             </View>

            <ScrollView contentContainerStyle={styles.contentPadding}>
                {/* Plan Summary Card - Removed overall calories */}
                <View style={styles.summaryCard}>
                     <View style={styles.summaryRow}>
                        <Text style={styles.detailLabel}>Plan Name:</Text>
                        <Text style={styles.detailValue}>{planData.name}</Text>
                     </View>

                      {planData.level && (
                        <View style={[styles.summaryRow, { marginBottom: 0 }]}>
                            <Text style={styles.detailLabel}>Level:</Text>
                            <View style={[styles.levelBadge, { backgroundColor: getBadgeColor(planData.level) }]}>
                                <Text style={[styles.levelText, { color: getBadgeTextColor(planData.level)}]}>{planData.level}</Text>
                            </View>
                        </View>
                     )}
                </View>


                {/* Display Exercises per Day */}
                <Text style={styles.daysHeader}>Daily Schedule:</Text>
                {DAYS.map(day => {
                    // Get the data for the current day from the plan
                    const dayData = planData.days?.[day];
                    const exercises = dayData?.exercises || [];
                    const dailyCalories = dayData?.targetCalories || 0; // Get daily calories

                    // Only render the card if there are exercises OR calories set for the day
                    return (exercises.length > 0 || dailyCalories > 0) && (
                        <View key={day} style={styles.dayCard}>
                            {/* Display day and daily calories */}
                            <View style={styles.dayHeaderRow}>
                                <Text style={styles.dayTitle}>{day.charAt(0).toUpperCase() + day.slice(1)}</Text>
                                <Text style={styles.dayCalories}>{dailyCalories} kcal Target</Text>
                            </View>

                            {exercises.length > 0 ? (
                                // Map through exercises for the day
                                exercises.map((exercise, index) => (
                                    <View
                                        key={index}
                                        style={[
                                            styles.exerciseItem,
                                            // Add border only if NOT the last item
                                            index < exercises.length - 1 ? styles.exerciseItemBorder : null
                                        ]}
                                    >
                                        <Text style={styles.exerciseName}>{exercise.exerciseName}</Text>
                                         <Text style={styles.exerciseInfo}>
                                            Sets: {exercise.sets || 'N/A'} | Reps: {exercise.reps || 'N/A'} {exercise.weight ? `| W: ${exercise.weight}` : ''} {exercise.rest ? `| R: ${exercise.rest}` : ''}
                                        </Text>
                                        {exercise.note ? <Text style={styles.exerciseNote}>Note: {exercise.note}</Text> : null}
                                    </View>
                                ))
                            ) : (
                                // Show if calories are set but no exercises (could be cardio/rest day)
                                <Text style={styles.noExercisesText}>No specific exercises assigned.</Text>
                            )}
                        </View>
                    )}
                )}

                 {/* Display Sunday as Rest Day only if completely empty */}
                 {(!planData.days?.sunday || (planData.days.sunday.exercises?.length === 0 && !planData.days.sunday.targetCalories)) && (
                     <View style={[styles.dayCard, styles.restDayCard]}>
                         <Text style={styles.dayTitle}>Sunday</Text>
                         <Text style={styles.restDayText}>Rest Day</Text>
                     </View>
                 )}

                {/* Edit Button */}
                <TouchableOpacity
                    style={styles.editButton}
                    onPress={() => router.push({
                        pathname: '/(trainer)/add-edit-plan',
                        // Pass necessary info to the edit screen
                        params: {
                            clientId: String(clientId),
                            planId: String(planId), // Pass the ID of the plan to edit
                            clientName: String(clientName || 'Client') // Pass name
                        }
                    })}
                >
                    <FontAwesome5 name="edit" size={16} color="#fff" />
                    <Text style={styles.editButtonText}>Edit This Plan</Text>
                </TouchableOpacity>

            </ScrollView>
        </View>
    );
};

// --- STYLES ---
const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: '#f8f9fa' },
    loaderContainer: {
        flex: 1, justifyContent: 'center', alignItems: 'center',
        backgroundColor: '#f8f9fa',
    },
     loadingText: {
        marginTop: 10, fontSize: 16, color: '#555',
    },
    errorText: { textAlign: 'center', marginTop: 50, fontSize: 16, color: 'red' },
    screenHeader: {
        flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between',
        paddingHorizontal: 15, paddingVertical: 10, backgroundColor: '#fff',
        borderBottomWidth: 1, borderBottomColor: '#eee'
    },
    backButton: { padding: 5 },
    screenTitle: { fontSize: 18, fontWeight: 'bold', color: '#333', textAlign: 'center', flexShrink: 1, marginHorizontal: 5 },
    contentPadding: { padding: 15, paddingBottom: 40 },
    summaryCard: {
        backgroundColor: '#fff', borderRadius: 10, padding: 15,
        marginBottom: 20, borderWidth: 1, borderColor: '#eee',
        shadowColor: '#000', shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05, shadowRadius: 2, elevation: 2,
    },
    summaryRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 },
    // Removed summaryRow:last-child style
    detailLabel: { fontSize: 16, color: '#555', fontWeight: '600' },
    detailValue: { fontSize: 16, color: '#333', fontWeight: '500' },
    levelBadge: { paddingHorizontal: 10, paddingVertical: 3, borderRadius: 12 },
    levelText: { fontSize: 11, fontWeight: 'bold', textTransform: 'lowercase' },
    daysHeader: {
        fontSize: 18, fontWeight: 'bold', color: '#333',
        marginTop: 10, marginBottom: 15,
    },
    dayCard: {
        backgroundColor: '#fff', borderRadius: 10, padding: 15,
        marginBottom: 15, borderWidth: 1, borderColor: '#eee',
        shadowColor: '#000', shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05, shadowRadius: 2, elevation: 2,
    },
    dayHeaderRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 10,
        borderBottomWidth: 1,
        borderBottomColor: '#eee',
        paddingBottom: 5,
    },
    dayTitle: {
        fontSize: 17, fontWeight: 'bold', color: '#F37307',
    },
    dayCalories: {
        fontSize: 14, fontWeight: '600', color: '#333',
    },
     restDayCard: {
        alignItems: 'center', backgroundColor: '#f9fafb',
     },
     restDayText: { fontSize: 15, color: '#6b7280', fontStyle: 'italic' },
     noExercisesText: {
        fontSize: 14, color: '#888', fontStyle: 'italic',
        paddingVertical: 10, textAlign: 'center',
    },
    exerciseItem: { paddingVertical: 10 },
    exerciseItemBorder: { borderBottomWidth: 1, borderBottomColor: '#f0f0f0' },
     exerciseName: { fontSize: 16, fontWeight: '600', color: '#333', marginBottom: 4 },
     exerciseInfo: { fontSize: 14, color: '#555', flexWrap: 'wrap', marginBottom: 3 },
     exerciseNote: { fontSize: 13, color: '#777', fontStyle: 'italic', marginTop: 4 },
     editButton: {
        backgroundColor: '#0284C7', paddingVertical: 15, borderRadius: 10,
        alignItems: 'center', marginTop: 20, flexDirection: 'row',
        justifyContent: 'center', shadowColor: '#000', shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1, shadowRadius: 3, elevation: 3,
     },
     editButtonText: { color: '#fff', fontSize: 18, fontWeight: 'bold', marginLeft: 10 },
});

export default ViewPlanScreen;

