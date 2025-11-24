import React, { useState } from 'react';
// 1. Import TouchableOpacity and StatusBar
import { View, Text, TextInput, StyleSheet, Image, StatusBar, TouchableOpacity } from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
// 2. Import Stack and useRouter
import { Stack, useRouter } from 'expo-router';
// 3. Import FontAwesome5
import { FontAwesome5 } from '@expo/vector-icons';

export default function BMICalculatorScreen() {
  const [weight, setWeight] = useState('');
  const [height, setHeight] = useState('');
  const bmi = weight && height ? (parseFloat(weight) / (parseFloat(height) ** 2)).toFixed(2) : null;
  const router = useRouter(); // 4. Initialize router

  return (
    <LinearGradient colors={['#fff', '#f9f9f9']} style={styles.container}>
       <Stack.Screen
        options={{
            headerShown: false, // Keep default header hidden
         }}
      />
      <StatusBar barStyle="dark-content" />

      {/* 5. Updated Custom Header Structure */}
      <View style={styles.header}>
          {/* Back Button */}
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
              <FontAwesome5 name="arrow-left" size={20} color="#333" />
          </TouchableOpacity>
          {/* Logo and App Name Container */}
          <View style={styles.logoContainer}>
              <Image source={require('../../assets/images/logo.png')} style={styles.logo} />
              <Text style={styles.appName}>B-FIT</Text>
          </View>
          {/* Empty View removed */}
      </View>

      <Text style={styles.title}>BMI Calculator</Text>

      <View style={styles.card}>
        <TextInput
          style={styles.input}
          placeholder="Enter weight in kg"
          keyboardType="numeric"
          value={weight}
          onChangeText={setWeight}
        />
        <TextInput
          style={styles.input}
          placeholder="Enter height in meters (e.g., 1.75)"
          keyboardType="numeric"
          value={height}
          onChangeText={setHeight}
        />
        <View style={styles.resultBox}>
          <Text style={styles.resultLabel}>Your BMI</Text>
          <Text style={styles.resultValue}>{bmi ?? '___'}</Text>
        </View>
      </View>
    </LinearGradient>
  );
}

// --- 6. UPDATED STYLES ---
const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingHorizontal: 20,
    paddingTop: StatusBar.currentHeight || 40,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    // Removed justifyContent: 'space-between'
    marginBottom: 20,
    width: '100%',
  },
  backButton: {
      padding: 10,
      marginRight: 10, // Added margin to space out from logo/name
  },
  logoContainer: { // Group logo and name
      flexDirection: 'row',
      alignItems: 'center',
  },
  logo: {
    width: 40,
    height: 40,
    marginRight: 10,
  },
  appName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#F37307',
  },
  title: {
    fontSize: 26,
    fontWeight: 'bold',
    color: '#212121',
    marginBottom: 30,
    textAlign: 'center'
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 20,
    padding: 25,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowRadius: 10,
    elevation: 5,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 12,
    padding: 15,
    marginBottom: 20,
    fontSize: 16,
    backgroundColor: '#f9f9f9',
  },
  resultBox: {
    backgroundColor: '#F37307',
    borderRadius: 12,
    paddingVertical: 20,
    alignItems: 'center',
    marginTop: 10,
  },
  resultLabel: {
    fontSize: 16,
    color: '#fff',
    marginBottom: 6,
  },
  resultValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
  },
});

