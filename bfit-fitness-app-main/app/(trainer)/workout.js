import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, Alert, StatusBar, TouchableOpacity } from 'react-native'; 
import { Stack, useRouter } from 'expo-router';
import SelectDropdown from 'react-native-select-dropdown';
import { FontAwesome5 } from '@expo/vector-icons';
import { db, auth } from '../../firebaseConfig'; // Path from app/(trainer)/ to root firebaseConfig.js
import { collection, query, where, getDocs } from 'firebase/firestore';
import TrainerHeader from '../components/TrainerHeader'; // Path from app/(trainer)/ to app/components/

const WorkoutPlannerScreen = () => {
    const [clients, setClients] = useState([]);
    const [loadingClients, setLoadingClients] = useState(true);
    const router = useRouter();

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

    const handleClientSelect = (selectedClient) => {
        if (selectedClient && selectedClient.id) {
            router.push(`/(trainer)/client-workout/${selectedClient.id}`);
        }
    };

    return (
        <View style={styles.container}>
            {/* Hides the default header for this specific screen */}
            <Stack.Screen options={{ headerShown: false }} /> 
            <StatusBar barStyle="dark-content" />

            {/* Reusable Trainer Header at the very top */}
            <TrainerHeader />

            {/* Custom Tab Navigation below the header */}
            <View style={styles.tabContainer}>
                <TouchableOpacity style={styles.tab} onPress={() => router.push('/(trainer)/clients')}>
                    <FontAwesome5 name="users" size={16} color="#aaa" />
                    <Text style={styles.tabText}>Client</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[styles.tab, styles.activeTab]}>
                    <FontAwesome5 name="dumbbell" size={16} color="#F37307" />
                    <Text style={[styles.tabText, styles.activeTabText]}>Workout</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.tab} onPress={() => router.push('/(trainer)/analysis')}>
                    <FontAwesome5 name="chart-line" size={16} color="#aaa" />
                    <Text style={styles.tabText}>Analysis</Text>
                </TouchableOpacity>
            </View>

            {/* The main content card for Workout Planner */}
            <View style={styles.contentCard}>
                <View style={styles.plannerHeader}>
                     <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
                        <FontAwesome5 name="arrow-left" size={20} color="#555" />
                     </TouchableOpacity>
                     <Text style={styles.screenTitle}>Workout Planner</Text>
                     {/* Placeholder to keep title centered */}
                     <View style={{width: 30}} /> 
                </View>

                <Text style={styles.cardDescription}>
                    Create and manage personalized workout plans for your clients.
                </Text>

                <Text style={styles.label}>Select Client</Text>
                {loadingClients ? (
                    <ActivityIndicator color="#F37307" />
                ) : (
                    <SelectDropdown
                        data={clients}
                        onSelect={(selectedItem, index) => {
                            handleClientSelect(selectedItem);
                        }}
                        renderButton={(selectedItem, isOpened) => {
                            return (
                                <View style={styles.dropdownButtonStyle}>
                                    <Text style={styles.dropdownButtonTxtStyle} numberOfLines={1}>
                                        {(selectedItem && selectedItem.name) || 'Select client whose workout you want to see'}
                                    </Text>
                                    <FontAwesome5 name={isOpened ? 'chevron-up' : 'chevron-down'} style={styles.dropdownButtonArrowStyle} />
                                </View>
                            );
                        }}
                        renderItem={(item, index, isSelected) => {
                            return (
                                <View style={{ ...styles.dropdownItemStyle, ...(isSelected && { backgroundColor: '#fde8d4' }) }}> 
                                    <View style={styles.dropdownItemAvatar}>
                                        <FontAwesome5 name="user" size={16} color="#F37307" />
                                    </View>
                                    <Text style={styles.dropdownItemTxtStyle}>{item.name}</Text>
                                </View>
                            );
                        }}
                        showsVerticalScrollIndicator={false}
                        dropdownStyle={styles.dropdownMenuStyle}
                        buttonStyle={styles.dropdownButtonStyle}
                        rowStyle={styles.dropdownItemStyle}
                        rowTextStyle={styles.dropdownItemTxtStyle}
                        buttonTextAfterSelection={(selectedItem, index) => selectedItem.name}
                        rowTextForSelection={(item, index) => item.name}
                        search
                        searchInputStyle={styles.dropdownSearchInputStyle}
                        searchPlaceHolder={'Search here'}
                        searchPlaceHolderColor={'#999'}
                        renderSearchInputLeftIcon={() => <FontAwesome5 name={'search'} color={'#999'} size={18} />}
                    />
                )}
            </View>
        </View>
    );
};

// --- STYLES ---
const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f8f9fa', // Light background for the whole screen
    },
    // Styles for TrainerHeader are in components/TrainerHeader.js
    tabContainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        backgroundColor: '#fff',
        paddingVertical: 10,
        paddingHorizontal: 10,
        marginHorizontal: 15, // Matches the design's spacing
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
        backgroundColor: '#fde8d4', // Light orange for active tab
    },
    tabText: {
        marginLeft: 6,
        fontSize: 13,
        color: '#888',
        fontWeight: '600',
    },
    activeTabText: {
        color: '#F37307', // Orange text for active tab
    },
    contentCard: {
        flex: 1, // Ensures the card takes up available space
        backgroundColor: '#fff',
        borderRadius: 15,
        padding: 25,
        margin: 15, // Matches the design's spacing
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 5,
        elevation: 3,
    },
    plannerHeader: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between', // Pushes back button left, title center
        marginBottom: 15,
        width: '100%',
    },
    backButton: {
        padding: 5, // Make touch target larger
    },
    screenTitle: {
      fontSize: 22, // Adjusted size to be prominent
      fontWeight: 'bold',
      color: '#333',
      textAlign: 'center',
    },
    cardDescription: {
        fontSize: 15,
        color: '#666',
        marginBottom: 30, // Increased space below description
        textAlign: 'center',
        paddingHorizontal: 10, // Add padding to constrain text width slightly
    },
    label: {
        fontSize: 16,
        color: '#555',
        fontWeight: '600',
        marginBottom: 10,
    },
    // --- Dropdown Styles ---
    dropdownButtonStyle: {
        width: '100%',
        height: 55,
        backgroundColor: '#f8f9fa', // Light background for dropdown button
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
        marginRight: 10, // Space before arrow
    },
    dropdownButtonArrowStyle: {
        fontSize: 14,
        color: '#555',
    },
    dropdownMenuStyle: {
        backgroundColor: '#fff', // White background for dropdown items
        borderRadius: 8,
        marginTop: 5,
        borderWidth: 1,
        borderColor: '#eee',
        maxHeight: 200, // Limit dropdown height
        shadowColor: '#000', // Add shadow to dropdown menu
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 2,
        elevation: 2,
    },
    dropdownItemStyle: {
        width: '100%',
        flexDirection: 'row',
        paddingHorizontal: 15,
        alignItems: 'center',
        paddingVertical: 12,
        borderBottomWidth: 1,
        borderBottomColor: '#f0f0f0', // Lighter separator
    },
    dropdownItemAvatar: { // Style for avatar placeholder in dropdown
        width: 30,
        height: 30,
        borderRadius: 15,
        backgroundColor: '#fde8d4', // Light orange background for avatar
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
        backgroundColor: '#f8f9fa', // Light grey background for search input
        borderRadius: 8,
        borderBottomWidth: 0, 
        height: 50,
        fontSize: 16,
        paddingHorizontal: 12,
        margin: 5,
    },
});

export default WorkoutPlannerScreen;

