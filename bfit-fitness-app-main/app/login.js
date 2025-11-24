import React from 'react';
import { StyleSheet, Text, View, TouchableOpacity, StatusBar } from 'react-native';
import { useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons'; // Import icons

const LoginTypeScreen = () => {
  const router = useRouter();

  // The handleLogin function needs to be updated with logic
  const handleLogin = (userType) => {
    if (userType === 'user') {
      router.push('/user-login'); // Go to the user login screen
    } else if (userType === 'trainer') {
      router.push('/trainer-login'); //go to the trainer login screen
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <View style={styles.backgroundShape} />

      <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
        <FontAwesome5 name="arrow-left" size={24} color="#fff" />
      </TouchableOpacity>

      <View style={styles.contentContainer}>
        <Text style={styles.title}>Select the Login type</Text>

        <View style={styles.buttonContainer}>
          {/* User Button - updated onPress */}
          <TouchableOpacity style={styles.optionButton} onPress={() => handleLogin('user')}>
            <FontAwesome5 name="user-graduate" size={48} color="#F37307" />
            <Text style={styles.optionText}>User</Text>
          </TouchableOpacity>

          {/* Trainer Button - updated onPress */}
          <TouchableOpacity style={styles.optionButton} onPress={() => handleLogin('trainer')}>
            <FontAwesome5 name="chalkboard-teacher" size={48} color="#F37307" />
            <Text style={styles.optionText}>Trainer</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
};

// We use similar styles to the welcome screen for consistency
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  backgroundShape: {
    position: 'absolute',
    width: '150%',
    height: '60%',
    left: '-25%',
    top: '-15%',
    backgroundColor: '#F37307',
    transform: [{ rotate: '-15deg' }],
  },
  backButton: {
    position: 'absolute',
    top: 60, // Adjust for status bar height
    left: 20,
    zIndex: 10,
    padding: 10,
  },
  contentContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#212121',
    marginBottom: 80,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '90%', // Widened the container slightly for better spacing
  },
  optionButton: {
    backgroundColor: '#fff',
    paddingVertical: 30,
    // We remove paddingHorizontal and set a fixed width
    width: 140,
    borderRadius: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 10,
    elevation: 8,
  },
  optionText: {
    marginTop: 15,
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
  },
});

export default LoginTypeScreen;


