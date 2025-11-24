import React, { useState, useEffect } from 'react';
import {
    View, Text, StyleSheet, ActivityIndicator, Alert, StatusBar,
    TouchableOpacity, ScrollView, Dimensions, TextInput, Image // Added ScrollView, Dimensions, etc.
} from 'react-native';
import { Stack, useRouter } from 'expo-router';
import SelectDropdown from 'react-native-select-dropdown';
import { FontAwesome5 } from '@expo/vector-icons';
// Import Chart Kit
import { BarChart } from 'react-native-chart-kit'; 
import { db, auth } from '../../firebaseConfig';
// Added Timestamp for date queries
import { collection, query, where, getDocs, Timestamp } from 'firebase/firestore'; 
import TrainerHeader from '../components/TrainerHeader';

// Get screen width for chart
const screenWidth = Dimensions.get('window').width;
const chartWidth = screenWidth - 70; // Adjust for card padding (15*2) + (20*2)

// --- REMOVED calculateStreak and getBadge helper functions ---

const TrainerAnalysisScreen = () => {
    // State for client dropdown
    const [clients, setClients] = useState([]);
    const [loadingClients, setLoadingClients] = useState(true);
    const [selectedClient, setSelectedClient] = useState(null);
    const router = useRouter();

    // State for analysis data
    const [weeklyData, setWeeklyData] = useState({});
    const [completedLogs, setCompletedLogs] = useState([]);
    const [analysisLoading, setAnalysisLoading] = useState(false);
    // const [streakCount, setStreakCount] = useState(0); // REMOVED
    const [totalCalories, setTotalCalories] = useState(0);
    const [avgCalories, setAvgCalories] = useState(0); // --- ADDED for new card ---

    // Fetch clients for the dropdown (runs once)
    useEffect(() => {
        const fetchClients = async () => {
            setLoadingClients(true);
            const trainerId = auth.currentUser?.uid;
            if (!trainerId) {
                setLoadingClients(false);
                Alert.alert("Error", "Could not verify trainer.");
                return;
            }
            try {
                const q = query(collection(db, "users"), where("assignedTrainerId", "==", trainerId));
                const querySnapshot = await getDocs(q);
                const clientsList = querySnapshot.docs.map(doc => ({
                    id: doc.id,
                    name: doc.data().fullName
                }));
                setClients(clientsList);
            } catch (error) {
                console.error("Error fetching clients: ", error);
                Alert.alert("Error", "Could not fetch clients.");
            } finally {
                setLoadingClients(false);
            }
        };
        fetchClients();
    }, []);

    // --- useEffect to fetch analysis data ---
    // This runs whenever 'selectedClient' changes
    useEffect(() => {
        const fetchProgress = async () => {
            if (!selectedClient) {
                // Clear data if no client is selected
                setWeeklyData({});
                setCompletedLogs([]);
                // setStreakCount(0); // REMOVED
                setTotalCalories(0);
                setAvgCalories(0); // --- ADDED ---
                return;
            }

            setAnalysisLoading(true);
            try {
                const clientId = selectedClient.id; // Use the selected client's ID
                const today = new Date();
                const sevenDaysAgo = new Date();
                sevenDaysAgo.setDate(today.getDate() - 6);
                sevenDaysAgo.setHours(0, 0, 0, 0);

                // Query the selected client's progressLogs
                const logsRef = collection(db, 'users', String(clientId), 'progressLogs');
                // Note: You may need to create an index in Firestore for this query
                const logsQuery = query(logsRef, where('createdAt', '>=', Timestamp.fromDate(sevenDaysAgo)));
                const snapshot = await getDocs(logsQuery);

                const logs = snapshot.docs.map(doc => doc.data());
                const grouped = { Mon: 0, Tue: 0, Wed: 0, Thu: 0, Fri: 0, Sat: 0, Sun: 0 };
                const completed = [];
                const dayMap = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ];

                logs.forEach(log => {
                    const logDate = log.createdAt?.toDate ? log.createdAt.toDate() : new Date(log.date);
                    const day = dayMap[logDate.getDay()];
                    if (day) { grouped[day] += log.caloriesBurned || 0; }
                    const formattedDate = logDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
                    if (log.completed) completed.push({...log, date: formattedDate, day: day});
                });
                
                const chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                const chartData = chartLabels.map(day => grouped[day] || 0);
                const newTotalCalories = chartData.reduce((sum, val) => sum + val, 0);
                
                // --- NEW: Calculate Avg Calories ---
                const newAvgCalories = (newTotalCalories > 0 && completed.length > 0)
                    ? (newTotalCalories / completed.length).toFixed(0)
                    : 0;

                setWeeklyData(grouped);
                setCompletedLogs(completed);
                // setStreakCount(calculateStreak(logs)); // REMOVED
                setTotalCalories(newTotalCalories);
                setAvgCalories(newAvgCalories); // --- ADDED ---

            } catch (error) {
                console.error('Error fetching progress:', error);
                Alert.alert("Error", "Could not load client analysis.");
            } finally {
                setAnalysisLoading(false);
            }
        };

        fetchProgress();
    }, [selectedClient]); // This effect depends on selectedClient


    const handleClientSelect = (client) => {
        setSelectedClient(client || null); // Set the selected client in state
    };
    
     // Chart data configuration
    const chartLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const chartDataValues = chartLabels.map(day => weeklyData[day] || 0);

    return (
        <View style={styles.container}>
            <Stack.Screen options={{ headerShown: false }} />
            <StatusBar barStyle="dark-content" />
            <TrainerHeader />

            {/* Tab Navigation */}
            <View style={styles.tabContainer}>
                 <TouchableOpacity style={styles.tab} onPress={() => router.push('/(trainer)/clients')}>
                    <FontAwesome5 name="users" size={16} color="#aaa" />
                    <Text style={styles.tabText}>Client</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.tab} onPress={() => router.push('/(trainer)/workout')}>
                    <FontAwesome5 name="dumbbell" size={16} color="#aaa" />
                    <Text style={styles.tabText}>Workout</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[styles.tab, styles.activeTab]}>
                    <FontAwesome5 name="chart-line" size={16} color="#F37307" />
                    <Text style={[styles.tabText, styles.activeTabText]}>Analysis</Text>
                </TouchableOpacity>
            </View>

            {/* Use ScrollView for content */}
            <ScrollView contentContainerStyle={styles.scrollContainer}>
                {/* Client Selection Card */}
                <View style={styles.contentCard}>
                    <Text style={styles.screenTitle}>Client Analysis</Text>
                    <Text style={styles.cardDescription}>
                        Analyze and track client progress to fine-tune training plans.
                    </Text>

                    <Text style={styles.label}>Select Client</Text>
                    {loadingClients ? (
                        <ActivityIndicator color="#F37307" />
                    ) : (
                        <SelectDropdown
                            data={clients}
                            onSelect={(selectedItem) => handleClientSelect(selectedItem)}
                            renderButton={(selectedItem, isOpened) => (
                                <View style={styles.dropdownButtonStyle}>
                                    <Text style={styles.dropdownButtonTxtStyle} numberOfLines={1}>
                                        {(selectedItem && selectedItem.name) || (selectedClient && selectedClient.name) || 'Select client to analyze'}
                                    </Text>
                                    <FontAwesome5 name={isOpened ? 'chevron-up' : 'chevron-down'} style={styles.dropdownButtonArrowStyle} />
                                </View>
                            )}
                            renderItem={(item, index, isSelected) => (
                                <View style={{ ...styles.dropdownItemStyle, ...(isSelected && { backgroundColor: '#fde8d4' }) }}>
                                    <View style={styles.dropdownItemAvatar}>
                                        <FontAwesome5 name="user" size={16} color="#F37307" />
                                    </View>
                                    <Text style={styles.dropdownItemTxtStyle}>{item.name}</Text>
                                </View>
                            )}
                            showsVerticalScrollIndicator={false}
                            dropdownStyle={styles.dropdownMenuStyle}
                            buttonStyle={styles.dropdownButtonStyle}
                            rowStyle={styles.dropdownItemStyle}
                            rowTextStyle={styles.dropdownItemTxtStyle}
                            buttonTextAfterSelection={(selectedItem) => selectedItem.name}
                            rowTextForSelection={(item) => item.name}
                            search
                            searchInputStyle={styles.dropdownSearchInputStyle}
                            searchPlaceHolder={'Search here'}
                            searchPlaceHolderColor={'#999'}
                            renderSearchInputLeftIcon={() => <FontAwesome5 name={'search'} color={'#999'} size={18} />}
                        />
                    )}
                </View>

                {/* --- Conditionally Render Analysis --- */}
                {analysisLoading ? (
                    <ActivityIndicator size="large" color="#F37307" style={{ marginTop: 30 }} />
                ) : selectedClient ? (
                    // --- This is your friend's UI, merged and modified ---
                    <View style={styles.analysisSection}>
                        <Text style={styles.analysisTitle}>Progress for {selectedClient.name}</Text>
                        
                        {/* Chart Section */}
                        <View style={styles.card}>
                            <Text style={styles.cardTitle}>Calories Burned (Last 7 Days)</Text>
                            <Text style={styles.totalCalories}>🔥 Total: {totalCalories} cal</Text>
                             <View style={styles.chartWrapper}>
                                <BarChart
                                    data={{
                                        labels: chartLabels,
                                        datasets: [{ data: chartDataValues }],
                                    }}
                                    width={chartWidth}
                                    height={260}
                                    fromZero
                                    showValuesOnTopOfBars
                                    yAxisSuffix=" cal"
                                    withInnerLines={true}
                                    withHorizontalLabels={true}
                                    chartConfig={chartConfig}
                                    style={styles.chart}
                                />
                            </View>
                        </View>
                        {/* Completed Workouts */}
                        <View style={styles.card}>
                            <Text style={styles.cardTitle}>Completed Workouts (Last 7 Days)</Text>
                            {completedLogs.length === 0 ? (
                                <Text style={styles.cardText}>No workouts completed in the last 7 days.</Text>
                            ) : (
                                completedLogs.map((log, index) => (
                                    <Text key={index} style={styles.logText}>
                                        ✅ {log.exerciseName || 'Workout'} on {log.date} ({log.day}) — {log.caloriesBurned} cal
                                    </Text>
                                ))
                            )}
                        </View>
                        
                        {/* --- REPLACED Streak Card --- */}
                        <View style={styles.card}>
                            <Text style={styles.cardTitle}>Weekly Summary</Text>
                            <Text style={styles.logText}>
                                Workouts Completed: {completedLogs.length}
                            </Text>
                            <Text style={styles.logText}>
                                Avg. Calories / Workout: {avgCalories} cal
                            </Text>
                        </View>
                        {/* --- End of friend's UI --- */}
                    </View>
                ) : (
                    <Text style={styles.noClientText}>Please select a client to view their analysis.</Text>
                )}

            </ScrollView>
        </View>
    );
};

// Chart config from friend's code
const chartConfig = {
    backgroundColor: '#fff',
    backgroundGradientFrom: '#fff',
    backgroundGradientTo: '#fff',
    decimalPlaces: 0,
    barPercentage: 0.6,
    color: (opacity = 1) => `rgba(243, 115, 7, ${opacity})`,
    labelColor: () => '#333',
    propsForLabels: { fontSize: 11 },
};

// --- STYLES ---
const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f8f9fa',
    },
    scrollContainer: {
        paddingBottom: 40,
    },
    loader: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#f8f9fa',
    },
    // Tab styles
    tabContainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        backgroundColor: '#fff',
        paddingVertical: 10,
        paddingHorizontal: 10,
        marginHorizontal: 15,
        marginTop: 20,
        borderRadius: 12,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.08,
        shadowRadius: 3,
        elevation: 3,
    },
    tab: {
        flexDirection: 'row',
        alignItems: 'center',
        paddingVertical: 8,
        paddingHorizontal: 12,
        borderRadius: 10,
    },
    activeTab: {
        backgroundColor: '#fde8d4',
    },
    tabText: {
        marginLeft: 6,
        fontSize: 13,
        color: '#888',
        fontWeight: '600',
    },
    activeTabText: {
        color: '#F37307',
    },
    // Selection Card
    contentCard: {
        backgroundColor: '#fff',
        borderRadius: 15,
        padding: 20,
        margin: 15,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 5,
        elevation: 3,
    },
    screenTitle: {
       fontSize: 20,
       fontWeight: 'bold',
       color: '#333',
       textAlign: 'center',
       marginBottom: 5,
    },
    cardDescription: {
        fontSize: 15,
        color: '#666',
        marginBottom: 20,
        textAlign: 'center',
    },
    label: {
        fontSize: 16,
        color: '#555',
        fontWeight: '600',
        marginBottom: 10,
    },
    // Dropdown styles
    dropdownButtonStyle: {
        width: '100%',
        height: 55,
        backgroundColor: '#f8f9fa',
        borderRadius: 12,
        borderWidth: 1,
        borderColor: '#eee',
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 15,
    },
    dropdownButtonTxtStyle: {
        flex: 1,
        fontSize: 16,
        color: '#555',
        marginRight: 10,
    },
    dropdownButtonArrowStyle: {
        fontSize: 14,
        color: '#555',
    },
    dropdownMenuStyle: {
        backgroundColor: '#fff',
        borderRadius: 8,
        marginTop: 5,
        borderWidth: 1,
        borderColor: '#eee',
        maxHeight: 200,
    },
    dropdownItemStyle: {
        width: '100%',
        flexDirection: 'row',
        paddingHorizontal: 15,
        alignItems: 'center',
        paddingVertical: 12,
        borderBottomWidth: 1,
        borderBottomColor: '#f0f0f0',
    },
    dropdownItemAvatar: {
        width: 30,
        height: 30,
        borderRadius: 15,
        backgroundColor: '#fde8d4',
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 10,
    },
    dropdownItemTxtStyle: {
        flex: 1,
        fontSize: 16,
        color: '#333',
    },
    dropdownSearchInputStyle: {
        backgroundColor: '#f8f9fa',
        borderRadius: 8,
        borderBottomWidth: 0, 
        height: 50,
        fontSize: 16,
        paddingHorizontal: 12,
        margin: 5,
    },
    // Analysis results section
    analysisSection: {
        paddingHorizontal: 15,
    },
     analysisTitle: {
        fontSize: 22,
        fontWeight: 'bold',
        color: '#212121',
        marginBottom: 20,
        textAlign: 'center',
    },
    noClientText: {
        textAlign: 'center',
        fontSize: 16,
        color: '#888',
        fontStyle: 'italic',
        marginTop: 30,
    },
    // Friend's card styles
    card: {
        backgroundColor: '#fff', // White card
        borderRadius: 15,
        padding: 15, // Tighter padding
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
    // --- REMOVED streakText and badge styles ---
});

export default TrainerAnalysisScreen;

