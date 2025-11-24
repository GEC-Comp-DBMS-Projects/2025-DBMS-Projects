import React, { useState } from 'react';
import { StyleSheet, Text, View, TouchableOpacity, StatusBar, TextInput, ScrollView, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';

// Import Firebase services
import { auth, db } from '../firebaseConfig';
import { createUserWithEmailAndPassword } from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';

const UserRegisterScreen = () => {
  const router = useRouter();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [age, setAge] = useState('');
  const [weight, setWeight] = useState('');
  const [height, setHeight] = useState('');
  // --- 1. ADD NEW STATE FOR GOAL AND HEALTH INFO ---
  const [goal, setGoal] = useState('');
  const [healthInfo, setHealthInfo] = useState(''); // Optional field

  const handleRegister = async () => {
    // --- 2. UPDATE VALIDATION TO INCLUDE 'GOAL' ---
    if (!fullName || !email || !password || !age || !weight || !height || !goal) {
      Alert.alert('Incomplete Form', 'Please fill out all required fields.');
      return;
    }

    try {
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;
      console.log('User registered in Auth:', user.uid);

      // --- 3. ADD NEW FIELDS TO THE DATA SAVED IN FIRESTORE ---
      await setDoc(doc(db, "users", user.uid), {
        fullName: fullName,
        email: email,
        age: age,
        weight: weight,
        height: height,
        goal: goal, // Added goal
        healthInfo: healthInfo, // Added optional health info
        role: 'user'
      });
      console.log("User data saved to Firestore!");

      Alert.alert('Success', 'Your account has been created!');
      router.push('/(tabs)');

    } catch (error) {
      console.error("Registration Error:", error);
      Alert.alert('Registration Failed', error.message);
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <View style={styles.backgroundShape} />
      <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
        <FontAwesome5 name="arrow-left" size={24} color="#fff" />
      </TouchableOpacity>
      <Text style={styles.title}>USER REGISTRATION</Text>
      <ScrollView style={styles.formContainer} contentContainerStyle={styles.formContent}>
        <Text style={styles.subtitle}>Create your account</Text>
        <View style={styles.separator} />
        <View style={styles.inputContainer}>
          <TextInput style={styles.input} placeholder="Full Name" placeholderTextColor="#999" value={fullName} onChangeText={setFullName} />
          <FontAwesome5 name="user" size={20} color="#F37307" style={styles.icon} />
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
          <TextInput style={styles.input} placeholder="Age" placeholderTextColor="#999" value={age} onChangeText={setAge} keyboardType="numeric" />
          <FontAwesome5 name="birthday-cake" size={20} color="#F37307" style={styles.icon} />
        </View>
        <View style={styles.inputContainer}>
          <TextInput style={styles.input} placeholder="Weight (kg)" placeholderTextColor="#999" value={weight} onChangeText={setWeight} keyboardType="numeric" />
          <FontAwesome5 name="weight" size={20} color="#F37307" style={styles.icon} />
        </View>
        <View style={styles.inputContainer}>
          <TextInput style={styles.input} placeholder="Height (cm)" placeholderTextColor="#999" value={height} onChangeText={setHeight} keyboardType="numeric" />
          <FontAwesome5 name="ruler-vertical" size={20} color="#F37307" style={styles.icon} />
        </View>

        {/* --- 4. ADDED NEW INPUT FIELDS FOR GOAL AND HEALTH INFO --- */}
        <View style={styles.inputContainer}>
          <TextInput style={styles.input} placeholder="Your Fitness Goal (e.g., Lose Weight)" placeholderTextColor="#999" value={goal} onChangeText={setGoal} />
          <FontAwesome5 name="bullseye" size={20} color="#F37307" style={styles.icon} />
        </View>
        <View style={[styles.inputContainer, styles.textAreaContainer]}>
          <TextInput
            style={[styles.input, styles.textArea]}
            placeholder="Any health issues? (Optional)"
            placeholderTextColor="#999"
            value={healthInfo}
            onChangeText={setHealthInfo}
            multiline={true}
          />
        </View>

        <TouchableOpacity style={styles.registerButton} onPress={handleRegister}>
          <Text style={styles.registerButtonText}>REGISTER</Text>
        </TouchableOpacity>
        <View style={styles.loginContainer}>
          <Text style={styles.loginText}>Already have an account? </Text>
          <TouchableOpacity onPress={() => router.push('/user-login')}>
            <Text style={styles.loginLink}>Login here</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </View>
  );
};

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
        color: '#555',
        marginTop: 20,
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
    // --- 5. ADDED NEW STYLES FOR THE MULTI-LINE TEXT AREA ---
    textAreaContainer: {
        minHeight: 120,
        alignItems: 'flex-start',
    },
    textArea: {
        height: 100,
        textAlignVertical: 'top',
        paddingTop: 20
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

export default UserRegisterScreen;

