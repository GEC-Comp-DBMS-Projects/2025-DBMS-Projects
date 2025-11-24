import React from 'react';
import { StyleSheet, Text, View, Image, StatusBar } from 'react-native'; // 1. Import Image and StatusBar
import { FontAwesome5 } from '@expo/vector-icons';

const UserWaitingScreen = ({ userData }) => {
  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" />
      {/* 2. Replaced the old header with a new, more appealing branded header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.welcomeText}>Welcome,</Text>
          <Text style={styles.userName}>{userData.fullName.split(' ')[0]}!</Text>
        </View>
      </View>

      <View style={styles.waitingCard}>
        <FontAwesome5 name="clock" size={40} color="#F37307" />
        <Text style={styles.waitingTitle}>Plan Coming Soon!</Text>
        <Text style={styles.waitingText}>
          Your trainer has been notified and is preparing your personalized workout. 
          Please check back later!
        </Text>
      </View>
    </View>
  );
};

// --- 3. UPDATED STYLES ---
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    paddingTop: StatusBar.currentHeight || 40,
  },
  header: {
    paddingHorizontal: 20,
    marginBottom: 30, // Increased margin for better spacing
    flexDirection: 'row',
    alignItems: 'center',
  },
  logo: {
    width: 50,
    height: 50,
    marginRight: 15,
  },
  welcomeText: {
    fontSize: 22,
    color: '#555',
  },
  userName: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#212121',
  },
  waitingCard: {
      backgroundColor: '#f9f9f9',
      borderRadius: 15,
      padding: 30,
      marginHorizontal: 20,
      alignItems: 'center',
      borderWidth: 1,
      borderColor: '#eee',
      // Added a subtle shadow for depth
      shadowColor: "#000",
      shadowOffset: {
        width: 0,
        height: 2,
      },
      shadowOpacity: 0.05,
      shadowRadius: 3.84,
      elevation: 3,
  },
  waitingTitle: {
      fontSize: 22,
      fontWeight: 'bold',
      color: '#333',
      marginTop: 20,
      marginBottom: 10,
  },
  waitingText: {
      fontSize: 16,
      color: '#666',
      textAlign: 'center',
      lineHeight: 24,
  }
});

export default UserWaitingScreen;