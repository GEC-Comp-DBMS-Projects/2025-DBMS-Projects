import React, { useState, useEffect } from 'react';
import {
    View, Text, StyleSheet, TextInput, TouchableOpacity, Alert, ScrollView,
    StatusBar, ActivityIndicator, Modal, FlatList, KeyboardAvoidingView, Platform
} from 'react-native';
import { Stack, useLocalSearchParams, useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';
import TrainerHeader from '../components/TrainerHeader';
import { db, auth } from '../../firebaseConfig';
import {
    collection, addDoc, serverTimestamp, doc, updateDoc,
    Timestamp, getDocs, query, writeBatch, deleteDoc, getDoc,
    orderBy, limit
} from 'firebase/firestore';

// Helper function to get dates for the current week (Monday to Sunday)
const getCurrentWeekDates = () => {
    const dates = {};
    const today = new Date();
    const currentDayOfWeek = today.getDay(); // 0 (Sun) to 6 (Sat)
    // Adjust to make Monday the start (0 = Mon, 6 = Sun)
    const adjustedDay = currentDayOfWeek === 0 ? 6 : currentDayOfWeek - 1; 
    
    // Calculate Monday's date
    const mondayDate = new Date(today);
    mondayDate.setDate(today.getDate() - adjustedDay);

    const daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
    for (let i = 0; i < 7; i++) {
        const date = new Date(mondayDate);
        date.setDate(mondayDate.getDate() + i);
        dates[daysOfWeek[i]] = date.getDate(); // Store just the day number
    }
    return dates;
};


const AddEditPlanScreen = () => {
    // --- DAYS CONSTANT NOW DEFINED HERE ---
    const DAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    // --- END MOVE ---

    const { clientId, clientName, planId } = useLocalSearchParams();
    const router = useRouter();

    const [planName, setPlanName] = useState('');
    
    // --- UPDATED State for Workout Plan Structure ---
    // Each day is now an object with targetCalories and an exercises array
    const [planDays, setPlanDays] = useState({
        monday: { targetCalories: '', exercises: [] },
        tuesday: { targetCalories: '', exercises: [] },
        wednesday: { targetCalories: '', exercises: [] },
        thursday: { targetCalories: '', exercises: [] },
        friday: { targetCalories: '', exercises: [] },
        saturday: { targetCalories: '', exercises: [] },
        sunday: { targetCalories: '', exercises: [] } // For rest day calories/notes
    });
    
    const [selectedDay, setSelectedDay] = useState('monday');
    const [isModalVisible, setIsModalVisible] = useState(false);
    const [currentExercise, setCurrentExercise] = useState({
        exerciseName: '', sets: '', reps: '', weight: '', rest: '', note: ''
    });
    const [editingIndex, setEditingIndex] = useState(null);
    const [saving, setSaving] = useState(false);
    const [isPlanSavedModalVisible, setIsPlanSavedModalVisible] = useState(false);
    const [loadingPlan, setLoadingPlan] = useState(!!planId); // Load only if planId exists
    
    // State to hold current week's dates
    const [weekDates, setWeekDates] = useState({});

    const isEditing = !!planId;

    // Fetch dates on component mount
    useEffect(() => {
        setWeekDates(getCurrentWeekDates());
    }, []);


    // --- UPDATED useEffect to load new data structure ---
    useEffect(() => {
        const fetchPlanToEdit = async () => {
            if (!clientId || !planId) {
                setLoadingPlan(false);
                // Ensure state is clean for a new plan
                setPlanName('');
                setPlanDays({
                    monday: { targetCalories: '', exercises: [] }, tuesday: { targetCalories: '', exercises: [] },
                    wednesday: { targetCalories: '', exercises: [] }, thursday: { targetCalories: '', exercises: [] },
                    friday: { targetCalories: '', exercises: [] }, saturday: { targetCalories: '', exercises: [] },
                    sunday: { targetCalories: '', exercises: [] } 
                });
                return; 
            }
            
            setLoadingPlan(true);
            try {
                const planRef = doc(db, 'users', String(clientId), 'workoutPlans', String(planId));
                const planSnap = await getDoc(planRef);

                if (planSnap.exists()) {
                    const existingPlanData = planSnap.data();
                    setPlanName(existingPlanData.name || '');
                    
                    // Populate days state with new structure
                    const fetchedDays = existingPlanData.days || {};
                    const initialDaysState = {};
                    [...DAYS, 'sunday'].forEach(day => { // Now uses DAYS from component scope
                        initialDaysState[day] = {
                            // Convert fetched number back to string for input
                            targetCalories: String(fetchedDays[day]?.targetCalories || ''), 
                            exercises: fetchedDays[day]?.exercises || [] 
                        };
                    });
                    setPlanDays(initialDaysState);
                } else {
                    Alert.alert('Error', 'Could not find the plan specified for editing.');
                     // Reset fields if plan wasn't found
                     setPlanName('');
                     setPlanDays({
                         monday: { targetCalories: '', exercises: [] }, tuesday: { targetCalories: '', exercises: [] },
                         wednesday: { targetCalories: '', exercises: [] }, thursday: { targetCalories: '', exercises: [] },
                         friday: { targetCalories: '', exercises: [] }, saturday: { targetCalories: '', exercises: [] },
                         sunday: { targetCalories: '', exercises: [] }
                     });
                }
            } catch (error) {
                console.error("Error fetching plan to edit: ", error);
                Alert.alert('Error', 'Could not load plan data for editing.');
            } finally {
                setLoadingPlan(false);
            }
        };

        fetchPlanToEdit();
    }, [clientId, planId]);


    // --- UPDATED Modal Functions to work with new state ---
    const openAddExerciseModal = () => {
        setEditingIndex(null);
        setCurrentExercise({ exerciseName: '', sets: '', reps: '', weight: '', rest: '', note: '' });
        setIsModalVisible(true);
    };
    const openEditExerciseModal = (exercise, index) => {
        setEditingIndex(index);
        setCurrentExercise({...exercise});
        setIsModalVisible(true);
    };
    const handleSaveExercise = () => {
        if (!currentExercise.exerciseName) {
            Alert.alert('Missing Info', 'Please enter at least an exercise name.');
            return;
        }
        // Get exercises for the selected day
        const updatedDayExercises = [...planDays[selectedDay].exercises]; 
        const exerciseData = {
            exerciseName: currentExercise.exerciseName,
            sets: currentExercise.sets || '', reps: currentExercise.reps || '',
            weight: currentExercise.weight || '', rest: currentExercise.rest || '',
            note: currentExercise.note || '',
        };
        if (editingIndex !== null) {
            updatedDayExercises[editingIndex] = exerciseData;
        } else {
            updatedDayExercises.push(exerciseData);
        }
        // Save exercises back into the day's object
        setPlanDays(prev => ({ 
            ...prev, 
            [selectedDay]: { 
                ...prev[selectedDay], // Keep existing targetCalories
                exercises: updatedDayExercises // Update only exercises
            } 
        }));
        setIsModalVisible(false);
    };
     const handleDeleteExercise = (indexToDelete) => {
         Alert.alert( "Delete Exercise", "Are you sure you want to delete this exercise?",
            [ { text: "Cancel", style: "cancel" },
                { text: "Delete", style: "destructive",
                    onPress: () => {
                        // Filter exercises for the selected day
                        const updatedDayExercises = planDays[selectedDay].exercises.filter((_, index) => index !== indexToDelete);
                        // Update the state
                        setPlanDays(prev => ({ 
                            ...prev, 
                            [selectedDay]: { 
                                ...prev[selectedDay], // Keep existing targetCalories
                                exercises: updatedDayExercises // Update only exercises
                            } 
                        }));
                    }
                }
            ]
        );
    };
    // --- End Modal Functions ---


    // --- UPDATED Save Plan Function ---
    const handleSavePlan = async () => {
        // Only validate planName, daily calories are optional
        if (!planName) { 
            Alert.alert('Missing Info', 'Please enter a Plan Name.');
            return;
        }
        if (!clientId) {
             Alert.alert('Error', 'Client ID is missing. Cannot save plan.');
            return;
        }

        setSaving(true);
        try {
            // Convert daily targetCalories from string to number before saving
             const finalPlanDays = {};
             Object.keys(planDays).forEach(day => {
                 finalPlanDays[day] = {
                     ...planDays[day],
                     // Convert to number, default 0 if empty or invalid
                     targetCalories: parseInt(planDays[day].targetCalories, 10) || 0 
                 };
             });

            // Prepare payload, remove single targetCalories
            const planDataPayload = {
                name: planName,
                days: finalPlanDays, // Use the converted days data
                updatedAt: serverTimestamp(), 
            };
            

            if (isEditing) {
                // --- EDITING EXISTING PLAN ---
                console.log("Updating existing plan:", planId);
                const planRef = doc(db, 'users', String(clientId), 'workoutPlans', String(planId));
                await updateDoc(planRef, planDataPayload); 
                console.log("Plan updated successfully.");

            } else {
                // --- ADDING NEW PLAN (Replace old one) ---
                console.log("Adding new plan for client:", clientId, "(replacing old if exists)");
                const plansRef = collection(db, 'users', String(clientId), 'workoutPlans');
                
                const existingPlansQuery = query(plansRef);
                const existingPlansSnapshot = await getDocs(existingPlansQuery);
                const batch = writeBatch(db);
                existingPlansSnapshot.forEach((docSnapshot) => { batch.delete(docSnapshot.ref); });
                await batch.commit();

                planDataPayload.createdAt = serverTimestamp(); // Add createdAt only for new plans
                await addDoc(plansRef, planDataPayload); 
                console.log("New plan added successfully.");

                const userRef = doc(db, 'users', String(clientId));
                await updateDoc(userRef, { hasActivePlan: true });
                console.log("User 'hasActivePlan' status confirmed/updated.");
            }
            
            setIsPlanSavedModalVisible(true); // Show success modal

        } catch (error) {
            console.error("Error saving plan: ", error);
            Alert.alert('Error', `Could not save the workout plan. ${error.message}`);
        } finally {
            setSaving(false);
        }
    };
    // --- End UPDATED Save Plan Function ---


    const handlePlanSavedDone = () => {
        setIsPlanSavedModalVisible(false);
        router.back();
    };


    const renderExerciseItem = ({ item, index }) => (
       <View style={styles.exerciseItem}>
            <View style={styles.exerciseDetails}>
                <Text style={styles.exerciseName}>{item.exerciseName}</Text>
                <Text style={styles.exerciseInfo}>
                    Sets: {item.sets || 'N/A'} | Reps: {item.reps || 'N/A'} {item.weight ? `| W: ${item.weight}` : ''} {item.rest ? `| R: ${item.rest}` : ''}
                </Text>
                {item.note ? <Text style={styles.exerciseNote}>Note: {item.note}</Text> : null}
            </View>
            <View style={styles.exerciseActions}>
                 <TouchableOpacity onPress={() => openEditExerciseModal(item, index)} style={styles.editIcon}>
                     <FontAwesome5 name="edit" size={16} color="#4B5563" />
                 </TouchableOpacity>
                 <TouchableOpacity onPress={() => handleDeleteExercise(index)} style={styles.deleteIcon}>
                     <FontAwesome5 name="trash-alt" size={16} color="#EF4444" />
                 </TouchableOpacity>
            </View>
        </View>
    );

     if (loadingPlan) {
        return (
            <View style={styles.loaderContainer}>
                 <ActivityIndicator size="large" color="#F37307" />
                 <Text style={styles.loadingText}>Loading Plan...</Text>
            </View>
        )
     }

    return (
        <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === "ios" ? "padding" : undefined} >
            <View style={styles.container}>
                <Stack.Screen options={{ headerShown: false }} />
                <StatusBar barStyle="dark-content" />
                <TrainerHeader />

                 <View style={styles.screenHeader}>
                     <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
                        <FontAwesome5 name="arrow-left" size={20} color="#555" />
                     </TouchableOpacity>
                     <Text style={styles.screenTitle}>{isEditing ? 'Edit Plan' : 'New Plan'} for {clientName || 'Client'}</Text>
                     <View style={{width: 30}} />
                 </View>

                <ScrollView contentContainerStyle={styles.formPadding}>
                    {/* Plan Details Inputs */}
                    <View style={styles.inputContainer}>
                        <Text style={styles.label}>Workout Plan Name</Text>
                        <TextInput style={styles.input} placeholder="e.g., Strength Phase 1" value={planName} onChangeText={setPlanName} />
                    </View>
                    
                    {/* --- REMOVED Single Target Calories Input --- */}
                    
                    {/* Day Selection with Dates */}
                    <Text style={[styles.label, { marginTop: 10 }]}>Select Day</Text>
                    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.daySelectorScroll}>
                        <View style={styles.daySelector}>
                            {/* Include Sunday in the map */}
                            {[...DAYS, 'sunday'].map((day) => (
                                <TouchableOpacity
                                    key={day}
                                    style={[styles.dayButton, selectedDay === day && styles.activeDayButton]}
                                    onPress={() => setSelectedDay(day)}
                                >
                                    {/* Display Day Abbreviation */}
                                    <Text style={[styles.dayButtonTextAbbr, selectedDay === day && styles.activeDayButtonText]}>
                                        {day.substring(0, 3).toUpperCase()}
                                    </Text>
                                    {/* Display Date */}
                                    <Text style={[styles.dayButtonTextDate, selectedDay === day && styles.activeDayButtonText]}>
                                        {weekDates[day] || ''} 
                                    </Text>
                                </TouchableOpacity>
                            ))}
                        </View>
                    </ScrollView>

                    {/* Exercise Section for Selected Day */}
                    <View style={styles.exerciseSection}>
                        <Text style={styles.sectionTitle}>Details for {selectedDay.charAt(0).toUpperCase() + selectedDay.slice(1)}</Text>
                        
                        {/* --- NEW: Daily Target Calories Input --- */}
                        <View style={styles.inputContainer}>
                            <Text style={styles.label}>Target Calories for Day</Text>
                            <TextInput 
                                style={styles.input} 
                                placeholder="e.g., 1500 kcal" 
                                // Access nested state correctly, ensure it's a string
                                value={String(planDays[selectedDay]?.targetCalories ?? '')} 
                                onChangeText={(text) => {
                                    // Update the targetCalories string within the day's object
                                    setPlanDays(prev => ({
                                        ...prev,
                                        [selectedDay]: {
                                            ...prev[selectedDay], // Keep existing exercises
                                            targetCalories: text // Store as string
                                        }
                                    }))
                                }} 
                                keyboardType="numeric"
                            />
                        </View>
                        
                        <Text style={styles.label}>Exercises</Text>
                        <FlatList
                             // Access nested exercises correctly
                            data={planDays[selectedDay]?.exercises ?? []} 
                            renderItem={renderExerciseItem}
                            keyExtractor={(item, index) => `${selectedDay}-${index}-${item.exerciseName}`} 
                            ListEmptyComponent={<Text style={styles.noExercisesText}>No exercises added for this day yet.</Text>}
                            nestedScrollEnabled={true}
                        />
                        <TouchableOpacity style={styles.addExerciseButton} onPress={openAddExerciseModal}>
                            <FontAwesome5 name="plus" size={14} color="#fff" />
                            <Text style={styles.addExerciseButtonText}>Add Exercise</Text>
                        </TouchableOpacity>
                    </View>

                    <TouchableOpacity
                        style={[styles.saveButton, saving && styles.disabledButton]}
                        onPress={handleSavePlan}
                        disabled={saving}
                    >
                        {saving ? ( <ActivityIndicator color="#fff" /> ) : ( <Text style={styles.saveButtonText}>Save Full Plan</Text> )}
                    </TouchableOpacity>
                </ScrollView>
            </View>

             {/* --- Modals (Remain the same) --- */}
            <Modal
                animationType="slide"
                transparent={true}
                visible={isModalVisible}
                onRequestClose={() => setIsModalVisible(false)}
            >
                <KeyboardAvoidingView
                    style={{ flex: 1 }}
                    behavior={Platform.OS === "ios" ? "padding" : "height"}
                >
                    <View style={styles.modalOverlay}>
                        <View style={styles.modalContent}>
                            <ScrollView>
                                <Text style={styles.modalTitle}>{editingIndex !== null ? 'Edit Exercise' : 'Add New Exercise'}</Text>
                                <TextInput style={styles.modalInput} placeholder="Exercise Name" value={currentExercise.exerciseName} onChangeText={(text) => setCurrentExercise({...currentExercise, exerciseName: text})} />
                                <TextInput style={styles.modalInput} placeholder="Sets" value={currentExercise.sets} onChangeText={(text) => setCurrentExercise({...currentExercise, sets: text})} keyboardType="numeric" />
                                <TextInput style={styles.modalInput} placeholder="Reps" value={currentExercise.reps} onChangeText={(text) => setCurrentExercise({...currentExercise, reps: text})} keyboardType="numeric" />
                                <TextInput style={styles.modalInput} placeholder="Weight (*Optional)" value={currentExercise.weight} onChangeText={(text) => setCurrentExercise({...currentExercise, weight: text})} />
                                <TextInput style={styles.modalInput} placeholder="Rest (e.g., 60s)" value={currentExercise.rest} onChangeText={(text) => setCurrentExercise({...currentExercise, rest: text})} />
                                <TextInput style={[styles.modalInput, styles.modalNoteInput]} placeholder="Note (*Optional)" value={currentExercise.note} onChangeText={(text) => setCurrentExercise({...currentExercise, note: text})} multiline />
                                <View style={styles.modalButtonContainer}>
                                    <TouchableOpacity style={[styles.modalButton, styles.cancelButton]} onPress={() => setIsModalVisible(false)}>
                                        <Text style={styles.cancelButtonText}>Cancel</Text>
                                    </TouchableOpacity>
                                    <TouchableOpacity style={[styles.modalButton, styles.saveExerciseButton]} onPress={handleSaveExercise}>
                                        <Text style={styles.saveExerciseButtonText}>Save Exercise</Text>
                                    </TouchableOpacity>
                                </View>
                            </ScrollView>
                        </View>
                    </View>
                </KeyboardAvoidingView>
            </Modal>
            <Modal
                animationType="fade"
                transparent={true}
                visible={isPlanSavedModalVisible}
                onRequestClose={() => setIsPlanSavedModalVisible(false)}
            >
                 <View style={styles.successModalOverlay}>
                    <View style={styles.successModalContent}>
                        <FontAwesome5 name="check-circle" size={50} color="#F37307" style={styles.successIcon} />
                        <Text style={styles.successMessage}>Plan saved successfully</Text>
                        <TouchableOpacity style={styles.successDoneButton} onPress={handlePlanSavedDone}>
                            <Text style={styles.successDoneButtonText}>Done</Text>
                        </TouchableOpacity>
                    </View>
                </View>
            </Modal>
        </KeyboardAvoidingView>
    );
};

// --- STYLES ---
const styles = StyleSheet.create({
    loaderContainer: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#f8f9fa' },
    loadingText: { marginTop: 10, fontSize: 16, color: '#555' },
    container: { flex: 1, backgroundColor: '#f8f9fa' },
    screenHeader: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: 15, paddingVertical: 10, backgroundColor: '#fff', borderBottomWidth: 1, borderBottomColor: '#eee' },
    backButton: { padding: 5 },
    screenTitle: { fontSize: 18, fontWeight: 'bold', color: '#333', textAlign: 'center' },
    formPadding: { padding: 15, paddingBottom: 60 },
    inputContainer: { marginBottom: 15 },
    label: { fontSize: 16, color: '#555', fontWeight: '600', marginBottom: 8 },
    input: { backgroundColor: '#fff', borderRadius: 10, borderWidth: 1, borderColor: '#eee', paddingVertical: 12, paddingHorizontal: 15, fontSize: 16, color: '#333' },
    // --- Updated Day Selector Styles ---
    daySelectorScroll: { 
        marginBottom: 25,
        marginTop: 5,
    },
    daySelector: {
        flexDirection: 'row',
        // Removed justifyContent
    },
    dayButton: {
        // Removed flex: 1
        width: 65, // Fixed width
        paddingVertical: 8, // Adjusted padding
        paddingHorizontal: 5,
        borderRadius: 8,
        borderWidth: 1,
        borderColor: '#ddd',
        backgroundColor: '#fff',
        alignItems: 'center',
        marginHorizontal: 4, // Added gap
        minHeight: 55, // Set min height
        justifyContent: 'center',
    },
    activeDayButton: { backgroundColor: '#fde8d4', borderColor: '#F37307' },
    dayButtonTextAbbr: { // Style for MON, TUE etc.
        fontSize: 14,
        fontWeight: 'bold',
        color: '#555',
    },
    dayButtonTextDate: { // Style for the date number
        fontSize: 12,
        color: '#777',
        marginTop: 2,
    },
    activeDayButtonText: { color: '#F37307' },
    // --- End Day Selector Styles ---
    exerciseSection: { marginTop: 10, marginBottom: 30, padding: 15, backgroundColor: '#fff', borderRadius: 10, borderWidth: 1, borderColor: '#eee' },
    sectionTitle: { fontSize: 17, fontWeight: 'bold', color: '#333', marginBottom: 15 },
    noExercisesText: { fontStyle: 'italic', color: '#888', textAlign: 'center', paddingVertical: 10 },
    exerciseItem: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 12, borderBottomWidth: 1, borderBottomColor: '#f0f0f0' },
    exerciseDetails: { flex: 1, marginRight: 10 },
    exerciseName: { fontSize: 16, fontWeight: '600', color: '#333', marginBottom: 3 },
    exerciseInfo: { fontSize: 13, color: '#666', flexWrap: 'wrap' },
    exerciseNote: { fontSize: 12, color: '#888', fontStyle: 'italic', marginTop: 4 },
    exerciseActions: { flexDirection: 'row', alignItems: 'center' },
    editIcon: { padding: 8, marginRight: 5 },
    deleteIcon: { padding: 8 },
    addExerciseButton: { backgroundColor: '#4CAF50', paddingVertical: 10, paddingHorizontal: 15, borderRadius: 8, alignItems: 'center', justifyContent: 'center', flexDirection: 'row', marginTop: 15, alignSelf: 'flex-start' },
    addExerciseButtonText: { color: '#fff', fontSize: 14, fontWeight: 'bold', marginLeft: 8 },
    saveButton: { backgroundColor: '#F37307', paddingVertical: 15, borderRadius: 10, alignItems: 'center', marginTop: 10, flexDirection: 'row', justifyContent: 'center' },
    disabledButton: { backgroundColor: '#fda769' },
    saveButtonText: { color: '#fff', fontSize: 18, fontWeight: 'bold', textAlign: 'center' },
    // --- Modal Styles ---
    modalOverlay: { flex: 1, backgroundColor: 'rgba(0, 0, 0, 0.5)', justifyContent: 'center', alignItems: 'center' },
    modalContent: { backgroundColor: '#fff', borderRadius: 15, padding: 25, width: '90%', maxHeight: '85%', shadowColor: "#000", shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.25, shadowRadius: 3.84, elevation: 5 },
    modalTitle: { fontSize: 20, fontWeight: 'bold', marginBottom: 20, textAlign: 'center', color: '#333' },
    modalInput: { backgroundColor: '#f8f9fa', borderRadius: 10, borderWidth: 1, borderColor: '#eee', paddingVertical: 12, paddingHorizontal: 15, fontSize: 16, marginBottom: 15, color: '#333' },
    modalNoteInput: { minHeight: 80, textAlignVertical: 'top' },
    modalButtonContainer: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 20 },
    modalButton: { flex: 1, paddingVertical: 12, borderRadius: 8, alignItems: 'center' },
    cancelButton: { backgroundColor: '#E5E7EB', marginRight: 10 },
    cancelButtonText: { color: '#374151', fontWeight: '600', fontSize: 16 },
    saveExerciseButton: { backgroundColor: '#10B981', marginLeft: 10 },
    saveExerciseButtonText: { color: '#fff', fontWeight: '600', fontSize: 16 },
    // --- Success Modal Styles ---
    successModalOverlay: { flex: 1, backgroundColor: 'rgba(0, 0, 0, 0.5)', justifyContent: 'center', alignItems: 'center' },
    successModalContent: { backgroundColor: '#fff', borderRadius: 15, padding: 30, width: '80%', alignItems: 'center', shadowColor: "#000", shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.25, shadowRadius: 3.84, elevation: 5 },
    successIcon: { marginBottom: 15 },
    successMessage: { fontSize: 18, fontWeight: '600', color: '#333', marginBottom: 25, textAlign: 'center' },
    successDoneButton: { backgroundColor: '#F37307', paddingVertical: 12, paddingHorizontal: 40, borderRadius: 8, alignItems: 'center', width: '80%' },
    successDoneButtonText: { color: '#fff', fontSize: 16, fontWeight: 'bold' },
});

export default AddEditPlanScreen;

