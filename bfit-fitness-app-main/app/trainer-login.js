import React, { useState } from 'react';
// --- 1. IMPORT KEYBOARDAVOIDINGVIEW, SCROLLVIEW, AND PLATFORM ---
import { 
  StyleSheet, Text, View, TouchableOpacity, StatusBar, 
  TextInput, Image, Alert, KeyboardAvoidingView, ScrollView, Platform 
} from 'react-native';
import { useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';

import { auth } from '../firebaseConfig';
import { signInWithEmailAndPassword } from 'firebase/auth';

const TrainerLoginScreen = () => {
  const router = useRouter();
  const [email, setEmail] = useState(''); 
  const [password, setPassword] = useState('');

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please enter both email and password.');
      return;
    }

    try {
      await signInWithEmailAndPassword(auth, email, password);
      Alert.alert('Login Successful', 'Welcome back, Trainer!');
      router.replace('/(trainer)/clients');
    } catch (error) {
      console.error("Trainer Login Error:", error);
      Alert.alert('Login Failed', 'The email or password you entered is incorrect.');
    }
  };

  // --- 2. WRAP THE ENTIRE SCREEN ---
  return (
    <KeyboardAvoidingView 
      style={{ flex: 1, backgroundColor: '#f2f2f2' }}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.container}>
        <StatusBar barStyle="dark-content" />
        <View style={styles.backgroundShape} />

        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <FontAwesome5 name="arrow-left" size={24} color="#fff" />
        </TouchableOpacity>
        
        <Image 
          source={require('../assets/images/trainer-avatar.png')}
          style={styles.avatar}
        />

        <Text style={styles.title}>TRAINER LOGIN</Text>

        <View style={styles.formContainer}>
          <Text style={styles.subtitle}>Enter login credentials</Text>
          <View style={styles.separator} />

          <View style={styles.inputContainer}>
            <TextInput
              style={styles.input}
              placeholder="Email"
              placeholderTextColor="#999"
              value={email}
              onChangeText={setEmail}
              autoCapitalize="none"
              keyboardType="email-address"
            />
            <FontAwesome5 name="user-tie" size={20} color="#F37307" style={styles.icon} />
          </View>

          <View style={styles.inputContainer}>
            <TextInput
              style={styles.input}
              placeholder="Password"
              placeholderTextColor="#999"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />
            <FontAwesome5 name="lock" size={20} color="#F37307" style={styles.icon} />
          </View>

          <TouchableOpacity style={styles.loginButton} onPress={handleLogin}>
            <Text style={styles.loginButtonText}>Login</Text>
          </TouchableOpacity>

          <View style={styles.registerContainer}>
            <Text style={styles.registerText}>New Trainer? </Text>
            <TouchableOpacity onPress={() => router.push('/trainer-register')}>
              <Text style={styles.registerLink}>Click here to Register</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

// --- 3. ADJUST STYLES AND PRESERVE YOUR UI CHANGES ---
const styles = StyleSheet.create({
  container: {
      backgroundColor: '#f2f2f2',
      alignItems: 'center',
      paddingBottom: 50, // Add padding for scroll
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
      top: 60,
      left: 20,
      zIndex: 10,
      padding: 10,
  },
  avatar: {
      width: 100,
      height: 100,
      borderRadius: 50,
      marginTop: 120,
      zIndex: 10,
  },
  title: {
      fontSize: 32,
      fontWeight: 'bold',
      color: '#fff',
      marginTop: 20,
      zIndex: 10,
      letterSpacing: 2,
  },
  formContainer: {
      width: '100%',
      paddingHorizontal: 30,
      marginTop: 80,
      alignItems: 'center',
  },
  subtitle: {
      fontSize: 18,
      color: '#555',
  },
  separator: {
      width: '100%',
      height: 2,
      backgroundColor: '#F37307',
      marginTop: 5,
      marginBottom: 30,
  },
  inputContainer: {
      flexDirection: 'row',
      alignItems: 'center',
      backgroundColor: '#fff',
      borderRadius: 15,
      width: '100%',
      marginBottom: 23,
      paddingHorizontal: 20,
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 5,
      elevation: 5,
  },
  input: {
      flex: 1,
      height: 60,
      fontSize: 16,
      color: '#333',
  },
  icon: {
      marginLeft: 10,
  },
  loginButton: {
      backgroundColor: '#FFD200',
      width: '100%',
      paddingVertical: 18,
      borderRadius: 15,
      alignItems: 'center',
      marginTop: 1,
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 4 },
      shadowOpacity: 0.2,
      shadowRadius: 5,
      elevation: 8,
  },
  loginButtonText: {
      fontSize: 18,
      fontWeight: 'bold',
      color: '#333',
  },
  registerContainer: {
      flexDirection: 'row',
      marginTop: 10,
  },
  registerText: {
      fontSize: 16,
      color: '#555',
  },
  registerLink: {
      fontSize: 16,
      color: '#F37307',
      fontWeight: 'bold',
  },
});

export default TrainerLoginScreen;

