import React, { useState } from 'react';
// --- 1. IMPORT KEYBOARDAVOIDINGVIEW, AND PLATFORM ---
import {
  StyleSheet, Text, View, TouchableOpacity, StatusBar,
  TextInput, ScrollView, Alert, KeyboardAvoidingView, Platform
} from 'react-native';
import { useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';

import { auth, db } from '../firebaseConfig';
import { createUserWithEmailAndPassword } from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';

const TrainerRegisterScreen = () => {
  const router = useRouter();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [contactNo, setContactNo] = useState('');
  const [qualifications, setQualifications] = useState('');

  const handleRegister = async () => {
    if (!fullName || !email || !password || !contactNo || !qualifications) {
      Alert.alert('Incomplete Form', 'Please fill out all fields.');
      return;
    }

    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      console.log('Trainer registered in Auth:', user.uid);

      await setDoc(doc(db, "trainers", user.uid), {
        fullName: fullName,
        email: email,
        contactNo: contactNo,
        qualifications: qualifications,
        role: 'trainer'
      });
      console.log("Trainer data saved to Firestore!");

      Alert.alert('Success', 'Your trainer account has been created!');
      router.push('/(tabs)');

    } catch (error) {
      console.error("Trainer Registration Error:", error);
      Alert.alert('Registration Failed', error.message);
    }
  };

  // --- 2. WRAP THE ENTIRE SCREEN ---
  return (
    <KeyboardAvoidingView
      style={{ flex: 1, backgroundColor: '#f2f2f2' }}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <View style={styles.container}>
        <StatusBar barStyle="dark-content" />
        <View style={styles.backgroundShape} />
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <FontAwesome5 name="arrow-left" size={24} color="#fff" />
        </TouchableOpacity>
        <Text style={styles.title}>TRAINER REGISTRATION</Text>
        <ScrollView style={styles.formContainer} contentContainerStyle={styles.formContent}>
          <Text style={styles.subtitle}>Create your professional account</Text>
          <View style={styles.separator} />
          <View style={styles.inputContainer}>
            <TextInput style={styles.input} placeholder="Full Name" placeholderTextColor="#999" value={fullName} onChangeText={setFullName} />
            <FontAwesome5 name="user-tie" size={20} color="#F37307" style={styles.icon} />
          </View>
          <View style={styles.inputContainer}>
            <TextInput style={styles.input} placeholder="Email" placeholderTextColor="#999" value={email} onChangeText={setEmail} keyboardType="email-address" autoCapitalize="none" />
            <FontAwesome5 name="envelope" size={20} color="#F37307" style={styles.icon} />
          </View>
          <View style={styles.inputContainer}>
            <TextInput style={styles.input} placeholder="Password" placeholderTextColor="#999" value={password} onChangeText={setPassword} secureTextEntry />
            <FontAwesome5 name="lock" size={20} color="#F37307" style={styles.icon} />
          </View>
          <View style={styles.inputContainer}>
            <TextInput style={styles.input} placeholder="Contact No." placeholderTextColor="#999" value={contactNo} onChangeText={setContactNo} keyboardType="phone-pad" />
            <FontAwesome5 name="phone" size={20} color="#F37307" style={styles.icon} />
          </View>
          <View style={[styles.inputContainer, styles.textAreaContainer]}>
            <TextInput
              style={[styles.input, styles.textArea]}
              placeholder="Qualifications (e.g., CPT, B.Sc. Kinesiology)"
              placeholderTextColor="#999"
              value={qualifications}
              onChangeText={setQualifications}
              multiline={true}
            />
            <FontAwesome5 name="award" size={20} color="#F37307" style={[styles.icon, { paddingTop: 20 }]} />
          </View>
          <TouchableOpacity style={styles.registerButton} onPress={handleRegister}>
            <Text style={styles.registerButtonText}>REGISTER</Text>
          </TouchableOpacity>
          <View style={styles.loginContainer}>
            <Text style={styles.loginText}>Already have an account? </Text>
            <TouchableOpacity onPress={() => router.push('/trainer-login')}>
              <Text style={styles.loginLink}>Login here</Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </View>
    </KeyboardAvoidingView>
  );
};

// --- 3. NO STYLE CHANGES NEEDED, THE EXISTING SCROLLVIEW SETUP IS ENOUGH ---
const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#f2f2f2',
    },
    backgroundShape: {
        position: 'absolute',
        width: '150%',
        height: '50%',
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
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        color: '#fff',
        marginTop: 120,
        zIndex: 10,
        letterSpacing: 1.5,
        textAlign: 'center',
        marginBottom: 20,
    },
    formContainer: {
        flex: 1,
        width: '100%',
        paddingHorizontal: 30,
    },
    formContent: {
        alignItems: 'center',
        paddingBottom: 40,
    },
    subtitle: {
        fontSize: 18,
        color: '#551919fe',
        textAlign: 'center',
        marginTop: 20,
    },
    separator: {
        width: '100%',
        height: 2,
        backgroundColor: '#af5205ff',
        marginTop: 5,
        marginBottom: 30,
    },
    inputContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: '#fff',
        borderRadius: 15,
        width: '100%',
        marginBottom: 20,
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
    textAreaContainer: {
        minHeight: 120,
        alignItems: 'flex-start',
    },
    textArea: {
        height: 100,
        textAlignVertical: 'top',
        paddingTop: 20,
    },
    registerButton: {
        backgroundColor: '#FFD200',
        width: '100%',
        paddingVertical: 18,
        borderRadius: 15,
        alignItems: 'center',
        marginTop: 20,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.2,
        shadowRadius: 5,
        elevation: 8,
    },
    registerButtonText: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#333',
    },
    loginContainer: {
        flexDirection: 'row',
        marginTop: 20,
    },
    loginText: {
        fontSize: 16,
        color: '#555',
    },
    loginLink: {
        fontSize: 16,
        color: '#F37307',
        fontWeight: 'bold',
    },
});

export default TrainerRegisterScreen;

