import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, Alert, ScrollView, TouchableOpacity, Image } from 'react-native';
import { Stack, useLocalSearchParams, useRouter } from 'expo-router';
import { db, auth } from '../../../firebaseConfig'; // Adjust path needed from app/(trainer)/client-workout/
import { doc, getDoc, collection, getDocs, query } from 'firebase/firestore';
import { FontAwesome5 } from '@expo/vector-icons';
import TrainerHeader from '../../components/TrainerHeader'; // Adjust path needed

const ClientWorkoutScreen = () => {
    const { clientId } = useLocalSearchParams();
    const [clientData, setClientData] = useState(null);
    const [workoutPlans, setWorkoutPlans] = useState([]);
    const [loading, setLoading] = useState(true);
    const router = useRouter();

    useEffect(() => {
        if (!clientId) {
            Alert.alert("Error", "No client ID provided.");
            setLoading(false);
            return;
        }

        const fetchData = async () => {
            setLoading(true);
            try {
                // Fetch client details
                const clientRef = doc(db, 'users', clientId);
                const clientSnap = await getDoc(clientRef);
                if (clientSnap.exists()) {
                    setClientData({ id: clientSnap.id, ...clientSnap.data() });
                } else {
                    Alert.alert("Error", "Client not found.");
                }

                // Fetch existing workout plans (assuming a subcollection)
                const plansRef = collection(db, 'users', clientId, 'workoutPlans');
                // Fetch plans ordered by creation time if needed, otherwise just get all
                const plansQuery = query(plansRef, /* orderBy('createdAt', 'desc') */ ); 
                const plansSnap = await getDocs(plansQuery);
                const plansList = plansSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
                setWorkoutPlans(plansList);

            } catch (error) {
                console.error("Error fetching client workout data: ", error);
                Alert.alert("Error", "Could not fetch client data.");
            } finally {
                setLoading(false);
            }
        };

        fetchData();
        // Adding a listener or using router focus events might be needed
        // if you want this screen to auto-refresh after saving a plan
    }, [clientId]);

    // Function to determine badge color based on level
    const getBadgeColor = (level) => {
        switch (level?.toLowerCase()) {
            case 'intermediate': return '#FFF0E0'; // Light Orange
            case 'beginner': return '#E0F2FE'; // Light Blue
            case 'advanced': return '#FEE2E2'; // Light Red
            default: return '#F3F4F6'; // Default Gray
        }
    };
    const getBadgeTextColor = (level) => {
         switch (level?.toLowerCase()) {
            case 'intermediate': return '#F37307'; // Orange
            case 'beginner': return '#0284C7'; // Blue
            case 'advanced': return '#DC2626'; // Red
            default: return '#6B7280'; // Gray
        }
    }

    if (loading) {
        return <View style={styles.loader}><ActivityIndicator size="large" color="#F37307" /></View>;
    }

    if (!clientData) {
         return (
             <View style={styles.container}>
                <Stack.Screen options={{ title: 'Client Plan' }} />
                <TrainerHeader/>
                <Text style={styles.errorText}>Client data could not be loaded.</Text>
             </View>
         );
    }

    // Determine client status text based on hasActivePlan
    const clientStatus = clientData.hasActivePlan ? 'active' : 'inactive';

    return (
        <View style={styles.container}>
            {/* Configure Stack Header - Title is set dynamically below */}
             <Stack.Screen options={{ headerShown: false }} />
             <TrainerHeader/>

             {/* Back arrow + Screen Title */}
             <View style={styles.screenHeader}>
                 <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
                    <FontAwesome5 name="arrow-left" size={20} color="#555" />
                 </TouchableOpacity>
                 <Text style={styles.screenTitle}>{clientData.fullName.split(' ')[0]}'s Workouts</Text>
                 <View style={{width: 30}} /> {/* Spacer */}
             </View>

             {/* Client Info Card */}
             <View style={styles.clientInfoCard}>
                 <View style={styles.clientAvatar}>
                     {/* Placeholder Avatar */}
                     <FontAwesome5 name="user" size={30} color="#F37307" />
                 </View>
                 <View style={styles.clientMainDetails}> {/* New View to group client name and stats */}
                    <Text style={styles.clientName}>{clientData.fullName}</Text>
                    <View style={styles.clientStatsRow}>
                        <Text style={styles.clientStat}>Current: {clientData.weight || 'N/A'}kg</Text>
                        <Text style={styles.clientStat}>•</Text>
                        <Text style={styles.clientStat}>Target: {clientData.targetWeight || 'N/A'}kg</Text> {/* Assuming targetWeight field */}
                    </View>
                    <View style={styles.clientStatsRow}>
                        <View style={[styles.statusBadge, clientData.hasActivePlan ? styles.activeBadge : styles.inactiveBadge]}>
                            <Text style={styles.statusText}>{clientStatus}</Text>
                        </View>
                        <Text style={styles.workoutWeekText}>4 workouts this week</Text> {/* Placeholder */}
                    </View>
                 </View>
                 {/* Buttons moved below card */}
             </View>

            {/* Action Buttons Container - Placed BELOW the card */}
            <View style={styles.actionButtonsContainer}>
                <TouchableOpacity style={styles.editButton} onPress={() => Alert.alert("Edit Client", "Edit client details feature coming soon.")}>
                    <FontAwesome5 name="pen" size={14} color="#666" />
                    <Text style={styles.actionButtonText}>Edit</Text>
                </TouchableOpacity>
                <TouchableOpacity
                    style={styles.newButton}
                    onPress={() => router.push({
                        pathname: '/(trainer)/add-edit-plan',
                        params: { clientId: clientId, clientName: clientData?.fullName }
                    })}
                >
                    <FontAwesome5 name="plus" size={14} color="#fff" />
                    <Text style={[styles.actionButtonText, styles.newButtonText]}>New</Text>
                </TouchableOpacity>
            </View>


             {/* Existing Workout Plan Section */}
             <ScrollView style={styles.planSection}>
                <Text style={styles.sectionTitle}>Existing workout Plan</Text>
                {workoutPlans.length === 0 ? (
                    <Text style={styles.noPlansText}>No workout plans assigned yet.</Text>
                ) : (
                    workoutPlans.map((plan) => (
                        // --- UPDATED onPress FOR PLAN CARD ---
                        <TouchableOpacity 
                            key={plan.id} 
                            style={styles.planCard} 
                            // Navigate to view-plan screen, passing IDs and name
                            onPress={() => router.push({
                                pathname: `/(trainer)/view-plan/${plan.id}`, // Use dynamic route with plan ID
                                params: { 
                                    clientId: clientId, 
                                    clientName: clientData?.fullName // Pass client name for context
                                }
                            })}
                        >
                            <View style={styles.planHeader}>
                                <Text style={styles.planName}>{plan.name || 'Unnamed Plan'}</Text>
                                <View style={[styles.levelBadge, { backgroundColor: getBadgeColor(plan.level) }]}>
                                    <Text style={[styles.levelText, { color: getBadgeTextColor(plan.level)}]}>{plan.level || 'N/A'}</Text>
                                </View>
                            </View>
                            <Text style={styles.planDay}>{plan.day || 'N/A'}</Text> 
                            <View style={styles.planDetailsRow}>
                                <View style={styles.planDetailItem}>
                                    <FontAwesome5 name="clock" size={14} color="#888" />
                                    <Text style={styles.planDetailText}>{plan.duration || 'N/A'} min</Text>
                                </View>
                                <View style={styles.planDetailItem}>
                                    <FontAwesome5 name="running" size={14} color="#888" />
                                    <Text style={styles.planDetailText}>{plan.exerciseCount || 'N/A'} Exercise</Text> 
                                </View>
                            </View>
                        </TouchableOpacity>
                    ))
                )}
             </ScrollView>
        </View>
    );
};

// --- STYLES ---
const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f8f9fa',
    },
    loader: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
         backgroundColor: '#f8f9fa',
    },
    errorText: {
        textAlign: 'center',
        marginTop: 50,
        fontSize: 16,
        color: 'red',
    },
     screenHeader: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 15,
        paddingVertical: 10,
        backgroundColor: '#fff', 
        borderBottomWidth: 1,
        borderBottomColor: '#eee'
    },
    backButton: {
        padding: 5,
    },
    screenTitle: {
      fontSize: 20,
      fontWeight: 'bold',
      color: '#333',
      textAlign: 'center',
    },
    // Client Info Card Styles
    clientInfoCard: {
        backgroundColor: '#fff',
        borderRadius: 15,
        padding: 20,
        marginHorizontal: 15, // Keep margin horizontal
        marginTop: 15, // Add margin top
        marginBottom: 5, // Reduce margin bottom to bring buttons closer
        flexDirection: 'row', // Main direction for avatar and details
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
    },
    clientAvatar: {
        width: 60,
        height: 60,
        borderRadius: 30,
        backgroundColor: '#e7f0ff',
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 15,
        flexShrink: 0, // Don't let avatar shrink
    },
    clientMainDetails: { // Renamed from clientDetails for clarity
        flex: 1, // Allows this section to take up available space
        // Removed marginRight as buttons are outside now
    },
    clientName: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#333',
        marginBottom: 5,
    },
    clientStatsRow: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 5,
        flexWrap: 'wrap', // Allow items to wrap if space is tight
    },
    clientStat: {
        fontSize: 13,
        color: '#666',
        marginRight: 8,
    },
     statusBadge: {
        paddingHorizontal: 10,
        paddingVertical: 3,
        borderRadius: 12,
        marginRight: 10,
    },
    activeBadge: {
        backgroundColor: '#D1FAE5', 
    },
    inactiveBadge: {
        backgroundColor: '#FEE2E2', 
    },
    statusText: {
        fontSize: 11,
        fontWeight: 'bold',
        color: '#333',
        textTransform: 'capitalize',
    },
    workoutWeekText: {
        fontSize: 12,
        color: '#555',
        backgroundColor: '#f0f0f0',
        paddingHorizontal: 8,
        paddingVertical: 3,
        borderRadius: 8,
        overflow: 'hidden', 
    },
    // Action Buttons Container - Now below the card
    actionButtonsContainer: { 
        flexDirection: 'row', // Buttons side-by-side
        justifyContent: 'space-between', // Space them out
        paddingHorizontal: 15, // Match card horizontal margin
        marginTop: 10, // Space below the card
        marginBottom: 20, // Space above the plan section
    },
    editButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center', 
        backgroundColor: '#f0f0f0', // Grey background
        paddingHorizontal: 15, // More padding
        paddingVertical: 10, // More padding
        borderRadius: 10, // Rounded corners
        flex: 1, // Take half the space
        marginRight: 5, // Space between buttons
    },
    newButton: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center', 
        backgroundColor: '#F37307', // Orange background
        paddingHorizontal: 15, // More padding
        paddingVertical: 10, // More padding
        borderRadius: 10, // Rounded corners
        flex: 1, // Take half the space
        marginLeft: 5, // Space between buttons
    },
    actionButtonText: {
        marginLeft: 8, // More space from icon
        fontSize: 14, // Slightly larger text
        fontWeight: 'bold', // Bolder text
        color: '#333',
    },
    newButtonText: {
        color: '#fff', 
    },
    // Existing Workout Plan Styles
    planSection: {
        flex: 1, // Allows ScrollView to take remaining space
        paddingHorizontal: 15,
    },
    sectionTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#333',
        marginBottom: 15,
        // Removed marginTop, spacing handled by buttons container
    },
    noPlansText: {
        fontSize: 15,
        color: '#888',
        fontStyle: 'italic',
        textAlign: 'center',
        marginTop: 20,
    },
    planCard: {
        backgroundColor: '#fff',
        borderRadius: 12,
        padding: 15,
        marginBottom: 15,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 2,
        elevation: 2,
    },
    planHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 5,
    },
    planName: {
        fontSize: 17,
        fontWeight: 'bold',
        color: '#333',
    },
     levelBadge: {
        paddingHorizontal: 10,
        paddingVertical: 3,
        borderRadius: 12,
    },
    levelText: {
        fontSize: 11,
        fontWeight: 'bold',
        textTransform: 'lowercase',
    },
    planDay: {
        fontSize: 13,
        color: '#666',
        marginBottom: 10,
    },
    planDetailsRow: {
        flexDirection: 'row',
        justifyContent: 'flex-start',
        marginTop: 5,
    },
    planDetailItem: {
        flexDirection: 'row',
        alignItems: 'center',
        marginRight: 20, 
    },
    planDetailText: {
        marginLeft: 6,
        fontSize: 13,
        color: '#888',
    },
});

export default ClientWorkoutScreen;

