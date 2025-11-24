import React, { useState, useEffect } from 'react';
import { StyleSheet, Text, View, FlatList, ActivityIndicator, TouchableOpacity, TextInput } from 'react-native';
import { FontAwesome5 } from '@expo/vector-icons';
import { db } from '../../firebaseConfig'; // Adjust path if firebaseConfig is not in root
import { collection, query, where, getDocs } from 'firebase/firestore';
import { useRouter } from 'expo-router';

// This component receives the trainerId as a prop from TrainerClientsScreen
const ClientList = ({ trainerId }) => {
    const [clients, setClients] = useState([]);
    const [filteredClients, setFilteredClients] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const router = useRouter();

    // Fetch clients when the component mounts or trainerId changes
    useEffect(() => {
        const fetchClients = async () => {
            // Ensure we have a trainerId before querying
            if (!trainerId) {
                console.log("Trainer ID is missing, cannot fetch clients.");
                setLoading(false);
                return;
            }
            setLoading(true); // Start loading
            try {
                // Query the 'users' collection where assignedTrainerId matches the current trainer's ID
                const q = query(collection(db, "users"), where("assignedTrainerId", "==", trainerId));
                const querySnapshot = await getDocs(q);
                const clientsList = querySnapshot.docs.map(doc => ({
                    id: doc.id,
                    ...doc.data()
                }));
                console.log("Fetched Clients:", clientsList); // Log fetched clients
                setClients(clientsList);
                setFilteredClients(clientsList); // Initialize filtered list
            } catch (error) {
                console.error("Error fetching clients: ", error);
                // Optionally show an error message to the user
            } finally {
                setLoading(false); // Stop loading regardless of success or failure
            }
        };
        fetchClients();
    }, [trainerId]); // Re-run effect if trainerId changes

    // Filter clients based on search query
    useEffect(() => {
        if (searchQuery === '') {
            setFilteredClients(clients);
        } else {
            const filtered = clients.filter(client =>
                client.fullName.toLowerCase().includes(searchQuery.toLowerCase())
            );
            setFilteredClients(filtered);
        }
    }, [searchQuery, clients]);

    // Show loading indicator while fetching
    if (loading) {
        return <ActivityIndicator size="large" color="#F37307" style={styles.loader} />;
    }

    // Render the search bar and the list
    return (
        <View style={styles.container}>
            {/* Search Bar */}
            <View style={styles.searchContainer}>
                <FontAwesome5 name="search" size={18} color="#aaa" style={styles.searchIcon} />
                <TextInput
                    style={styles.searchInput}
                    placeholder="Search Client..."
                    placeholderTextColor="#aaa"
                    value={searchQuery}
                    onChangeText={setSearchQuery}
                />
            </View>

            {/* Client List */}
            <FlatList
                data={filteredClients}
                keyExtractor={(item) => item.id}
                contentContainerStyle={{ paddingBottom: 20 }}
                renderItem={({ item }) => (
                    // Make each client card pressable to navigate to their details later
                    <TouchableOpacity
                        style={styles.clientCard}
                        onPress={() => {
                            // Example navigation - you'll need to create this route
                            console.log("Navigating to client:", item.id);
                            // router.push(`/client-details/${item.id}`); // Uncomment when detail screen exists
                            Alert.alert("Client Details", `Details for ${item.fullName} coming soon.`);
                        }}
                    >
                        <View style={styles.clientAvatar}>
                            {/* Placeholder avatar */}
                            <FontAwesome5 name="user" size={20} color="#F37307" />
                        </View>
                        <View style={styles.clientInfo}>
                            <Text style={styles.clientName}>{item.fullName}</Text>
                            {/* Displaying first 5 chars of ID for brevity */}
                            <Text style={styles.clientId}>ID: {item.id.substring(0, 5)}...</Text>
                        </View>
                        {/* Display Active/Inactive status based on hasActivePlan */}
                        <View style={[styles.statusBadge, item.hasActivePlan ? styles.activeBadge : styles.inactiveBadge]}>
                            <Text style={styles.statusText}>{item.hasActivePlan ? 'Active' : 'Inactive'}</Text>
                        </View>
                    </TouchableOpacity>
                )}
                // Show a message if the list is empty
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.noClientsText}>You have no clients assigned yet.</Text>
                    </View>
                }
            />
        </View>
    );
};

// Styles specific to the ClientList component
const styles = StyleSheet.create({
    container: {
        flex: 1, // Take up remaining space
    },
    loader: {
        marginTop: 50, // Add some space from the top
    },
    searchContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#fff',
        borderRadius: 10,
        marginHorizontal: 15,
        marginTop: 15, // Add margin top
        marginBottom: 10, // Add margin bottom
        paddingHorizontal: 15,
        borderWidth: 1,
        borderColor: '#eee',
    },
    searchIcon: {
        marginRight: 10,
    },
    searchInput: {
        flex: 1,
        height: 50,
        fontSize: 16,
        color: '#333',
    },
    clientCard: {
        backgroundColor: '#fff',
        borderRadius: 15,
        padding: 15,
        marginHorizontal: 15,
        marginBottom: 10,
        flexDirection: 'row',
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 2,
        elevation: 2,
    },
    clientAvatar: {
        width: 45,
        height: 45,
        borderRadius: 22.5,
        backgroundColor: '#fde8d4', // Light orange background for avatar
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 15,
    },
    clientInfo: {
        flex: 1, // Takes up available space
    },
    clientName: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#333',
    },
    clientId: {
        fontSize: 12,
        color: '#aaa',
        marginTop: 2,
    },
    statusBadge: {
        paddingHorizontal: 12,
        paddingVertical: 5,
        borderRadius: 15,
    },
    activeBadge: {
        backgroundColor: '#d1f7c4', // Light green for active
    },
    inactiveBadge: {
        backgroundColor: '#ffd9d9', // Light red for inactive
    },
    statusText: {
        fontSize: 12,
        fontWeight: 'bold',
        color: '#333', // Dark text for contrast
    },
    emptyContainer: {
        marginTop: 50,
        alignItems: 'center',
    },
    noClientsText: {
        fontSize: 16,
        color: '#888',
    },
});

export default ClientList;

