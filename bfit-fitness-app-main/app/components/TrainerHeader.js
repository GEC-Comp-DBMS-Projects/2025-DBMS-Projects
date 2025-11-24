import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, Alert, StatusBar, ActivityIndicator } from 'react-native';
import { FontAwesome5 } from '@expo/vector-icons';
// --- CORRECTED PATH ---
// Path goes up from components -> app -> root
import { auth, db } from '../../firebaseConfig'; 
import { doc, getDoc } from 'firebase/firestore';
import { signOut } from 'firebase/auth';
import { useRouter } from 'expo-router';

const TrainerHeader = () => {
    const [trainerData, setTrainerData] = useState(null);
    const [loading, setLoading] = useState(true);
    const router = useRouter();

    useEffect(() => {
        const fetchTrainerData = async () => {
            setLoading(true);
            const trainerId = auth.currentUser?.uid;
            if (!trainerId) {
                setLoading(false);
                // No trainer logged in, main layout should handle redirect
                return;
            }

            try {
                const trainerRef = doc(db, 'trainers', trainerId);
                const trainerSnap = await getDoc(trainerRef);
                if (trainerSnap.exists()) {
                    setTrainerData({ id: trainerSnap.id, ...trainerSnap.data() });
                } else {
                    console.log("Trainer data not found!");
                }
            } catch (error) {
                console.error("Error fetching trainer data for header: ", error);
                // Avoid alerting here as it might interrupt user flow, just log
            } finally {
                setLoading(false);
            }
        };
        fetchTrainerData();
    }, []);

    const handleLogout = () => {
        signOut(auth)
            .then(() => {
                // Main layout should handle redirect after sign out
                console.log("User signed out");
            })
            .catch(error => Alert.alert("Logout Error", error.message));
    };

    // Show a minimal loading state or placeholder within the header bounds
    if (loading || !trainerData) {
        return (
            <View style={[styles.header, styles.headerLoading]}>
                <View style={styles.headerLeft}>
                   {/* Corrected path for logo */}
                   <Image source={require('../../assets/images/logo.png')} style={styles.logo} />
                     <View>
                        <Text style={styles.appName}>B-FIT</Text>
                        <Text style={styles.headerSubtitle}>Trainer Dashboard</Text>
                     </View>
                </View>
                <ActivityIndicator color="#F37307" />
            </View>
        );
    }

    // Render the full header once data is loaded
    return (
        <View style={styles.header}>
            <View style={styles.headerLeft}>
                {/* Corrected path for logo */}
                <Image source={require('../../assets/images/logo.png')} style={styles.logo} />
                <View>
                    <Text style={styles.appName}>B-FIT</Text>
                    <Text style={styles.headerSubtitle}>Trainer Dashboard</Text>
                </View>
            </View>
            <View style={styles.headerRight}>
                <Image
                    // Corrected path for trainer avatar
                    source={require('../../assets/images/trainer-avatar.png')}
                    style={styles.trainerAvatar}
                />
                <View style={styles.trainerMeta}>
                    <Text style={styles.trainerName} numberOfLines={1} ellipsizeMode='tail'>{trainerData.fullName.split(' ')[0]}</Text>
                    <View style={styles.trainerTagContainer}>
                        <Text style={styles.trainerTag}>Trainer</Text>
                    </View>
                </View>
                <TouchableOpacity onPress={handleLogout} style={styles.logoutButton}>
                    <FontAwesome5 name="sign-out-alt" size={24} color="#F37307" />
                </TouchableOpacity>
            </View>
        </View>
    );
};

// --- STYLES (Copied from the refined TrainerClientsScreen header) ---
const styles = StyleSheet.create({
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingHorizontal: 15, // Adjusted padding
        paddingTop: (StatusBar.currentHeight || 0) + 10,
        paddingBottom: 15,
        backgroundColor: '#fff', // White header background
        borderBottomWidth: 0, // Removed bottom border for cleaner look
        shadowColor: '#000', // Added subtle shadow
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
        elevation: 3,
        marginTop: 22
    },
    headerLoading: { // Style for when header is loading data
        justifyContent: 'space-between', // Keep alignment during load
    },
    headerLeft: {
        flexDirection: 'row',
        alignItems: 'center',
        flexShrink: 1, // Allow left side to shrink if needed
    },
    logo: {
        width: 35, // Slightly smaller logo
        height: 35,
        marginRight: 8, // Reduced margin
    },
    appName: {
        fontSize: 18, // Reduced font size
        fontWeight: 'bold',
        color: '#F37307', // Orange B-FIT color
    },
     headerSubtitle: {
        fontSize: 12, // Reduced subtitle font size
        color: '#888', // Softer color
        marginTop: 2,
     },
    headerRight: {
        flexDirection: 'row',
        alignItems: 'center',
        flexShrink: 0, // Prevent right side from shrinking
    },
    trainerAvatar: { // Style for trainer's actual image avatar
        width: 38,
        height: 38,
        borderRadius: 19,
        // Removed background color if using actual image
        marginRight: 8, // Reduced margin
    },
    trainerMeta: {
        marginRight: 8, // Reduced margin
        alignItems: 'flex-start',
        maxWidth: 80, // Limit width for trainer name
    },
    trainerName: {
        fontSize: 15, // Reduced font size
        fontWeight: 'bold',
        color: '#333',
    },
    trainerTagContainer: {
        backgroundColor: '#FFF0E0', // Light orange background for tag
        borderRadius: 5,
        paddingHorizontal: 6,
        paddingVertical: 2,
        marginTop: 2,
    },
    trainerTag: {
        fontSize: 10,
        color: '#F37307', // Orange text
        fontWeight: 'bold',
    },
    logoutButton: {
        marginLeft: 0, // Adjusted margin
        padding: 5,
    },
});

export default TrainerHeader;

