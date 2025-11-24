import React from 'react';
import { StyleSheet, Text, View, TouchableOpacity, Image, Alert } from 'react-native';
import { FontAwesome5 } from '@expo/vector-icons';
import { auth } from '../../firebaseConfig';
import { signOut } from 'firebase/auth';
import ClientList from './ClientList'; // 1. Import the new ClientList component

const TrainerDashboard = ({ userData }) => {

    const handleLogout = () => {
        signOut(auth).catch(error => Alert.alert("Logout Error", error.message));
    };

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <View style={styles.headerLeft}>
                    <Image source={require('../../assets/images/logo.png')} style={styles.logo} />
                    <Text style={styles.headerTitle}>Trainer Dashboard</Text>
                </View>
                <View style={styles.headerRight}>
                    <FontAwesome5 name="user-circle" size={24} color="#333" />
                    <View style={styles.trainerMeta}>
                        <Text style={styles.trainerName}>{userData.fullName.split(' ')[0]}</Text>
                        <Text style={styles.trainerTag}>Trainer</Text>
                    </View>
                    <TouchableOpacity onPress={handleLogout}>
                        <FontAwesome5 name="sign-out-alt" size={24} color="#F37307" />
                    </TouchableOpacity>
                </View>
            </View>

            {/* Tab Navigation */}
            <View style={styles.tabContainer}>
                <TouchableOpacity style={[styles.tab, styles.activeTab]}>
                    <FontAwesome5 name="users" size={18} color="#F37307" />
                    <Text style={[styles.tabText, styles.activeTabText]}>Client</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.tab} onPress={() => Alert.alert("Coming Soon!", "Workout feature is under development.")}>
                    <FontAwesome5 name="dumbbell" size={18} color="#aaa" />
                    <Text style={styles.tabText}>Workout</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.tab} onPress={() => Alert.alert("Coming Soon!", "Analysis feature is under development.")}>
                    <FontAwesome5 name="chart-line" size={18} color="#aaa" />
                    <Text style={styles.tabText}>Analysis</Text>
                </TouchableOpacity>
            </View>

            {/* 2. Render the new ClientList component and pass the trainer's data to it */}
            <ClientList trainerId={userData.id} />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f8f9fa',
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingHorizontal: 15,
        paddingTop: 50,
        paddingBottom: 15,
        backgroundColor: '#fff',
        borderBottomWidth: 1,
        borderBottomColor: '#eee',
    },
    headerLeft: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    logo: {
        width: 40,
        height: 40,
        marginRight: 10,
    },
    headerTitle: {
        fontSize: 16,
        fontWeight: '600',
        color: '#666',
    },
    headerRight: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    trainerMeta: {
        marginHorizontal: 10,
        alignItems: 'flex-start',
    },
    trainerName: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#333',
    },
    trainerTag: {
        fontSize: 12,
        color: '#fff',
        backgroundColor: '#F37307',
        paddingHorizontal: 5,
        borderRadius: 5,
        overflow: 'hidden',
    },
    tabContainer: {
        flexDirection: 'row',
        justifyContent: 'space-around',
        backgroundColor: '#fff',
        paddingVertical: 10,
    },
    tab: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 10,
    },
    activeTab: {
        borderBottomWidth: 2,
        borderBottomColor: '#F37307',
    },
    tabText: {
        marginLeft: 8,
        fontSize: 16,
        color: '#aaa',
        fontWeight: '600',
    },
    activeTabText: {
        color: '#F37307',
    },
});

export default TrainerDashboard;

