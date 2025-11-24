import React, { useState, useEffect } from 'react';
import { StyleSheet, Text, View, FlatList, ActivityIndicator, TouchableOpacity, Image, TextInput, Alert, StatusBar } from 'react-native';
import { FontAwesome5 } from '@expo/vector-icons';
// Adjust path if needed (assuming components is inside app folder)
import { db, auth } from '../../firebaseConfig'; 
import { collection, query, where, getDocs } from 'firebase/firestore';
import { useRouter, Stack } from 'expo-router'; 

// --- CORRECTED IMPORT PATH ---
import TrainerHeader from '../components/TrainerHeader'; 

const TrainerClientsScreen = () => {
    // ... rest of the component code remains the same ...
    const [clients, setClients] = useState([]);
    const [filteredClients, setFilteredClients] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const router = useRouter();

    useEffect(() => {
        // Fetch clients assigned to this trainer
        const fetchData = async () => {
            setLoading(true);
            const trainerId = auth.currentUser?.uid;
            if (!trainerId) {
                setLoading(false);
                Alert.alert("Error", "Could not verify trainer.");
                return;
            }

            try {
                const q = query(collection(db, "users"), where("assignedTrainerId", "==", trainerId));
                const querySnapshot = await getDocs(q);
                const clientsList = querySnapshot.docs.map(doc => ({
                    id: doc.id,
                    ...doc.data(),
                    hasActivePlan: doc.data().hasActivePlan || false 
                }));
                setClients(clientsList);
                setFilteredClients(clientsList);
            } catch (error) {
                console.error("Error fetching clients: ", error);
                Alert.alert("Error", "Could not fetch clients.");
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    useEffect(() => {
        if (searchQuery === '') {
            setFilteredClients(clients);
        } else {
            const filtered = clients.filter(client =>
                client.fullName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                client.id.toLowerCase().includes(searchQuery.toLowerCase())
            );
            setFilteredClients(filtered);
        }
    }, [searchQuery, clients]);

    // Logout is handled in TrainerHeader

    if (loading) {
        return (
            <View style={styles.loader}>
                 <ActivityIndicator size="large" color="#F37307" />
            </View>
        );
    }

    return (
        <View style={styles.container}>
             {/* Use Stack.Screen mainly to hide the default header */}
             <Stack.Screen options={{ headerShown: false }} />
            <StatusBar barStyle="dark-content" />

            {/* Use the reusable TrainerHeader component */}
            <TrainerHeader /> 

            {/* Tab Navigation */}
            <View style={styles.tabContainer}>
                <TouchableOpacity style={[styles.tab, styles.activeTab]}>
                    <FontAwesome5 name="users" size={16} color="#F37307" />
                    <Text style={[styles.tabText, styles.activeTabText]}>Client</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.tab} onPress={() => router.push('/(trainer)/workout')}>
                    <FontAwesome5 name="dumbbell" size={16} color="#aaa" />
                    <Text style={styles.tabText}>Workout</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.tab} onPress={() => router.push('/(trainer)/analysis')}>
                    <FontAwesome5 name="chart-line" size={16} color="#aaa" />
                    <Text style={styles.tabText}>Analysis</Text>
                </TouchableOpacity>
            </View>

            {/* Search Bar */}
            <View style={styles.searchContainer}>
                <FontAwesome5 name="search" size={18} color="#aaa" style={styles.searchIcon} />
                <TextInput
                    style={styles.searchInput}
                    placeholder="Search Client...."
                    placeholderTextColor="#aaa"
                    value={searchQuery}
                    onChangeText={setSearchQuery}
                />
            </View>

            {/* Client List */}
            <FlatList
                data={filteredClients}
                keyExtractor={(item) => item.id}
                contentContainerStyle={styles.listContentContainer}
                renderItem={({ item }) => (
                    <TouchableOpacity style={styles.clientCard} onPress={() => Alert.alert("Client Details", `Viewing ${item.fullName}`)}>
                        <View style={styles.clientAvatar}>
                             {item.profilePictureUrl ? (
                                <Image source={{ uri: item.profilePictureUrl }} style={styles.clientAvatarImage} />
                            ) : (
                                <FontAwesome5 name="user" size={20} color="#F37307" />
                            )}
                        </View>
                        <View style={styles.clientInfo}>
                            <Text style={styles.clientName}>{item.fullName}</Text>
                            <Text style={styles.clientId}>ID: {item.id.substring(0, 5)}</Text>
                        </View>
                        <View style={[styles.statusBadge, item.hasActivePlan ? styles.activeBadge : styles.inactiveBadge]}>
                            <Text style={styles.statusText}>{item.hasActivePlan ? 'active' : 'inactive'}</Text>
                        </View>
                    </TouchableOpacity>
                )}
                ListEmptyComponent={
                    <View style={styles.emptyContainer}>
                        <Text style={styles.noClientsText}>You have no clients yet.</Text>
                    </View>
                }
            />
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
    // Header styles removed - now in TrainerHeader.js
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
    searchContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#fff',
        borderRadius: 12, 
        margin: 15,
        paddingHorizontal: 15,
        borderWidth: 1,
        borderColor: '#eee',
        shadowColor: '#000', 
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 2,
        elevation: 2,
    },
    searchIcon: {
        marginRight: 10,
    },
    searchInput: {
        flex: 1,
        height: 48, 
        fontSize: 16,
        color: '#333',
    },
    listContentContainer: {
        paddingVertical: 10, 
        paddingHorizontal: 15,
    },
    clientCard: {
        backgroundColor: '#fff',
        borderRadius: 15,
        padding: 15,
        marginBottom: 10,
        flexDirection: 'row',
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.08, 
        shadowRadius: 3,
        elevation: 3,
    },
    clientAvatar: { 
        width: 48, 
        height: 48,
        borderRadius: 24,
        backgroundColor: '#e7f0ff', 
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 15,
        overflow: 'hidden', 
    },
    clientAvatarImage: { 
        width: '100%',
        height: '100%',
    },
    clientInfo: {
        flex: 1,
    },
    clientName: {
        fontSize: 17, 
        fontWeight: 'bold',
        color: '#333',
    },
    clientId: {
        fontSize: 12,
        color: '#888', 
        marginTop: 4, 
    },
    statusBadge: {
        paddingHorizontal: 12,
        paddingVertical: 5,
        borderRadius: 15,
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
    emptyContainer: {
        marginTop: 50,
        alignItems: 'center',
    },
    noClientsText: {
        fontSize: 16,
        color: '#888',
    },
});

export default TrainerClientsScreen;

