import React, { useState } from 'react';
import { View, Text,Image, TextInput, TouchableOpacity, ScrollView, StatusBar, ActivityIndicator, Alert } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { signInWithEmailAndPassword, createUserWithEmailAndPassword } from 'firebase/auth';
import { doc, setDoc, getDoc, serverTimestamp } from 'firebase/firestore';
import { auth, db } from '../firebase';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';


const UserLogin = () => {
  const navigation = useNavigation();
  const [mode, setMode] = useState<'login' | 'register'>('login');
  const [userType, setUserType] = useState<'tourist' | 'storeowner'>('tourist');
  
  // Form fields
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [storeName, setStoreName] = useState('');
  const [storeLocation, setStoreLocation] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  
  const [rememberMe, setRememberMe] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  // Validation
  const validateEmail = (email: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const validateForm = () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please enter both email and password');
      return false;
    }

    if (!validateEmail(email)) {
      Alert.alert('Error', 'Please enter a valid email address');
      return false;
    }

    if (mode === 'register') {
      if (!name) {
        Alert.alert('Error', 'Please enter your name');
        return false;
      }

      if (password.length < 6) {
        Alert.alert('Error', 'Password must be at least 6 characters');
        return false;
      }

      if (password !== confirmPassword) {
        Alert.alert('Error', 'Passwords do not match');
        return false;
      }

      if (userType === 'storeowner') {
        if (!storeName || !storeLocation) {
          Alert.alert('Error', 'Please enter store name and location');
          return false;
        }
      }
    }

    return true;
  };

  // Handle Sign In
  const handleSignIn = async () => {
    if (!validateForm()) return;

    setLoading(true);
    try {
      // Sign in with Firebase Auth
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Get user data from Firestore
      const userDoc = await getDoc(doc(db, 'users', user.uid));
      
      if (userDoc.exists()) {
        const userData = userDoc.data();
        console.log('User logged in:', userData);
        
        // Navigate based on user type
        if (userData.userType === 'storeowner') {
          navigation.navigate('StoreOwner' as never);
        } else {
          navigation.navigate('Home' as never);
        }
      } else {
        // If user data doesn't exist in Firestore, navigate based on selected type
        navigation.navigate('Home' as never);
      }
    } catch (error: any) {
      console.error('Sign in error:', error);
      let errorMessage = 'Failed to sign in';
      
      if (error.code === 'auth/user-not-found') {
        errorMessage = 'No account found with this email';
      } else if (error.code === 'auth/wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (error.code === 'auth/invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (error.code === 'auth/user-disabled') {
        errorMessage = 'This account has been disabled';
      }
      
      Alert.alert('Sign In Failed', errorMessage);
    } finally {
      setLoading(false);
    }
  };

  // Handle Registration
  const handleRegister = async () => {
    if (!validateForm()) return;

    setLoading(true);
    try {
      // Create user with Firebase Auth
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // Prepare user data
      const userData: any = {
        uid: user.uid,
        email: user.email,
        name: name,
        userType: userType,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
      };

      // Add type-specific fields
      if (userType === 'tourist') {
        userData.phoneNumber = phoneNumber || '';
        userData.preferences = [];
        userData.visitedPlaces = [];
        userData.savedPlaces = [];
      } else if (userType === 'storeowner') {
        userData.storeName = storeName;
        userData.storeLocation = storeLocation;
        userData.phoneNumber = phoneNumber || '';
        userData.storeType = '';
        userData.verified = false;
      }

      // Save to Firestore
      await setDoc(doc(db, 'users', user.uid), userData);

      console.log('User registered successfully:', userData);
      Alert.alert(
        'Success',
        'Account created successfully!',
        [
          {
            text: 'OK',
            onPress: () => {
              // Navigate based on user type
              if (userType === 'storeowner') {
                navigation.navigate('StoreOwner' as never);
              } else {
                navigation.navigate('preference' as never);
              }
            }
          }
        ]
      );
    } catch (error: any) {
      console.error('Registration error:', error);
      let errorMessage = 'Failed to create account';
      
      if (error.code === 'auth/email-already-in-use') {
        errorMessage = 'An account with this email already exists';
      } else if (error.code === 'auth/invalid-email') {
        errorMessage = 'Invalid email address';
      } else if (error.code === 'auth/weak-password') {
        errorMessage = 'Password is too weak';
      }
      
      Alert.alert('Registration Failed', errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = () => {
    if (mode === 'login') {
      handleSignIn();
    } else {
      handleRegister();
    }
  };

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" backgroundColor="#f9fafb" />
      
      <ScrollView 
        className="flex-1" 
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        {/* Header with Gradient */}
        <View className="bg-white pt-12 pb-8 px-6 rounded-b-3xl shadow-sm">
          <LinearGradient
            colors={['#3b82f6', '#8b5cf6']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
            style={{ 
              position: 'absolute', 
              top: 0, 
              left: 0, 
              right: 0, 
              bottom: 0, 
              borderBottomLeftRadius: 24,
              borderBottomRightRadius: 24,
              opacity: 0.05
            }}
          />
          
          <View className="items-center mb-6">
            <View className="flex-row mb-2">
            <Image 
              source={require('../assets/tourzy-logo.png')}
              style={{ width: 100, height: 20 }}
            />
            </View>
            <Text className="text-gray-500 text-sm">Your intelligent travel companion</Text>
          </View>

          {/* Login/Register Tabs */}
          <View className="flex-row bg-gray-100 rounded-2xl p-1">
            <TouchableOpacity
              onPress={() => setMode('login')}
              className={`flex-1 py-3 rounded-xl ${
                mode === 'login' ? 'bg-white shadow-sm' : ''
              }`}
            >
              <Text className={`text-center font-bold ${
                mode === 'login' ? 'text-blue-600' : 'text-gray-500'
              }`}>
                Login
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={() => setMode('register')}
              className={`flex-1 py-3 rounded-xl ${
                mode === 'register' ? 'bg-white shadow-sm' : ''
              }`}
            >
              <Text className={`text-center font-bold ${
                mode === 'register' ? 'text-blue-600' : 'text-gray-500'
              }`}>
                Register
              </Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Form Content */}
        <View className="px-6 pt-6 pb-8">
          {/* User Type Selection */}
          <View className="mb-6">
            <Text className="text-gray-900 text-sm font-semibold mb-3">I'm a</Text>
            <View className="flex-row gap-3">
              <TouchableOpacity
                onPress={() => setUserType('tourist')}
                className={`flex-1 py-4 px-4 rounded-2xl border-2 ${
                  userType === 'tourist' 
                    ? 'bg-blue-50 border-blue-500' 
                    : 'bg-white border-gray-200'
                }`}
              >
                <View className="items-center">
                  <View className={`w-16 h-16 rounded-full items-center justify-center mb-2 ${
                    userType === 'tourist' ? 'bg-blue-100' : 'bg-gray-100'
                  }`}>
                    <Ionicons 
                      name="person" 
                      size={32} 
                      color={userType === 'tourist' ? '#3b82f6' : '#9ca3af'} 
                    />
                  </View>
                  <Text className={`text-center text-sm font-bold ${
                    userType === 'tourist' ? 'text-blue-600' : 'text-gray-600'
                  }`}>
                    Tourist
                  </Text>
                  <Text className="text-xs text-gray-500 text-center mt-1">
                    Explore & Travel
                  </Text>
                </View>
              </TouchableOpacity>

              <TouchableOpacity
                onPress={() => setUserType('storeowner')}
                className={`flex-1 py-4 px-4 rounded-2xl border-2 ${
                  userType === 'storeowner' 
                    ? 'bg-purple-50 border-purple-500' 
                    : 'bg-white border-gray-200'
                }`}
              >
                <View className="items-center">
                  <View className={`w-16 h-16 rounded-full items-center justify-center mb-2 ${
                    userType === 'storeowner' ? 'bg-purple-100' : 'bg-gray-100'
                  }`}>
                    <Ionicons 
                      name="storefront" 
                      size={32} 
                      color={userType === 'storeowner' ? '#8b5cf6' : '#9ca3af'} 
                    />
                  </View>
                  <Text className={`text-center text-sm font-bold ${
                    userType === 'storeowner' ? 'text-purple-600' : 'text-gray-600'
                  }`}>
                    Store Owner
                  </Text>
                  <Text className="text-xs text-gray-500 text-center mt-1">
                    Manage Business
                  </Text>
                </View>
              </TouchableOpacity>
            </View>
          </View>

          {/* Form Fields */}
          <View className="bg-white rounded-2xl p-5 shadow-sm">
            {/* Name (Register only) */}
            {mode === 'register' && (
              <View className="mb-4">
                <Text className="text-gray-900 text-sm font-semibold mb-2">Full Name *</Text>
                <View className="bg-gray-50 rounded-xl px-4 py-3.5 flex-row items-center">
                  <Ionicons name="person-outline" size={20} color="#9ca3af" />
                  <TextInput
                    value={name}
                    onChangeText={setName}
                    placeholder="Enter your full name"
                    placeholderTextColor="#9CA3AF"
                    className="flex-1 ml-3 text-gray-900"
                  />
                </View>
              </View>
            )}

            {/* Email */}
            <View className="mb-4">
              <Text className="text-gray-900 text-sm font-semibold mb-2">Email *</Text>
              <View className="bg-gray-50 rounded-xl px-4 py-3.5 flex-row items-center">
                <Ionicons name="mail-outline" size={20} color="#9ca3af" />
                <TextInput
                  value={email}
                  onChangeText={setEmail}
                  placeholder="Enter your email"
                  placeholderTextColor="#9CA3AF"
                  keyboardType="email-address"
                  autoCapitalize="none"
                  className="flex-1 ml-3 text-gray-900"
                />
              </View>
            </View>

            {/* Password */}
            <View className="mb-4">
              <Text className="text-gray-900 text-sm font-semibold mb-2">Password *</Text>
              <View className="bg-gray-50 rounded-xl px-4 py-3.5 flex-row items-center">
                <Ionicons name="lock-closed-outline" size={20} color="#9ca3af" />
                <TextInput
                  value={password}
                  onChangeText={setPassword}
                  placeholder="Enter your password"
                  placeholderTextColor="#9CA3AF"
                  secureTextEntry={!showPassword}
                  className="flex-1 ml-3 text-gray-900"
                />
                <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
                  <Ionicons 
                    name={showPassword ? "eye-outline" : "eye-off-outline"} 
                    size={20} 
                    color="#9ca3af" 
                  />
                </TouchableOpacity>
              </View>
            </View>

            {/* Confirm Password (Register only) */}
            {mode === 'register' && (
              <View className="mb-4">
                <Text className="text-gray-900 text-sm font-semibold mb-2">Confirm Password *</Text>
                <View className="bg-gray-50 rounded-xl px-4 py-3.5 flex-row items-center">
                  <Ionicons name="lock-closed-outline" size={20} color="#9ca3af" />
                  <TextInput
                    value={confirmPassword}
                    onChangeText={setConfirmPassword}
                    placeholder="Confirm your password"
                    placeholderTextColor="#9CA3AF"
                    secureTextEntry={!showConfirmPassword}
                    className="flex-1 ml-3 text-gray-900"
                  />
                  <TouchableOpacity onPress={() => setShowConfirmPassword(!showConfirmPassword)}>
                    <Ionicons 
                      name={showConfirmPassword ? "eye-outline" : "eye-off-outline"} 
                      size={20} 
                      color="#9ca3af" 
                    />
                  </TouchableOpacity>
                </View>
              </View>
            )}

            {/* Phone Number (Register only) */}
            {mode === 'register' && (
              <View className="mb-4">
                <Text className="text-gray-900 text-sm font-semibold mb-2">Phone Number</Text>
                <View className="bg-gray-50 rounded-xl px-4 py-3.5 flex-row items-center">
                  <Ionicons name="call-outline" size={20} color="#9ca3af" />
                  <TextInput
                    value={phoneNumber}
                    onChangeText={setPhoneNumber}
                    placeholder="Enter your phone number"
                    placeholderTextColor="#9CA3AF"
                    keyboardType="phone-pad"
                    className="flex-1 ml-3 text-gray-900"
                  />
                </View>
              </View>
            )}

            {/* Store-specific fields */}
            {mode === 'register' && userType === 'storeowner' && (
              <>
                <View className="mb-4">
                  <Text className="text-gray-900 text-sm font-semibold mb-2">Store Name *</Text>
                  <View className="bg-gray-50 rounded-xl px-4 py-3.5 flex-row items-center">
                    <Ionicons name="storefront-outline" size={20} color="#9ca3af" />
                    <TextInput
                      value={storeName}
                      onChangeText={setStoreName}
                      placeholder="Enter your store name"
                      placeholderTextColor="#9CA3AF"
                      className="flex-1 ml-3 text-gray-900"
                    />
                  </View>
                </View>

                <View className="mb-4">
                  <Text className="text-gray-900 text-sm font-semibold mb-2">Store Location *</Text>
                  <View className="bg-gray-50 rounded-xl px-4 py-3.5 flex-row items-center">
                    <Ionicons name="location-outline" size={20} color="#9ca3af" />
                    <TextInput
                      value={storeLocation}
                      onChangeText={setStoreLocation}
                      placeholder="Enter store location"
                      placeholderTextColor="#9CA3AF"
                      className="flex-1 ml-3 text-gray-900"
                    />
                  </View>
                </View>
              </>
            )}

            {/* Remember Me & Forgot Password (Login only) */}
            {mode === 'login' && (
              <View className="flex-row justify-between items-center mb-4">
                <TouchableOpacity
                  onPress={() => setRememberMe(!rememberMe)}
                  className="flex-row items-center"
                >
                  <View className={`w-5 h-5 rounded-md border-2 mr-2 items-center justify-center ${
                    rememberMe ? 'bg-blue-500 border-blue-500' : 'bg-white border-gray-300'
                  }`}>
                    {rememberMe && <Ionicons name="checkmark" size={14} color="#fff" />}
                  </View>
                  <Text className="text-gray-700 text-sm">Remember me</Text>
                </TouchableOpacity>

                <TouchableOpacity>
                  <Text className="text-blue-500 text-sm font-semibold">Forgot password?</Text>
                </TouchableOpacity>
              </View>
            )}

            {/* Submit Button */}
            <TouchableOpacity
              onPress={handleSubmit}
              disabled={loading}
              className="rounded-xl overflow-hidden mt-2"
            >
              <LinearGradient
                colors={loading ? ['#9ca3af', '#6b7280'] : ['#3b82f6', '#8b5cf6']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 0 }}
                style={{ 
                  paddingVertical: 16, 
                  alignItems: 'center',
                  flexDirection: 'row',
                  justifyContent: 'center'
                }}
              >
                {loading && <ActivityIndicator color="#fff" style={{ marginRight: 8 }} />}
                <Text className="text-white text-center font-bold text-base">
                  {loading 
                    ? (mode === 'login' ? 'Signing In...' : 'Creating Account...') 
                    : (mode === 'login' ? 'Sign In' : 'Create Account')
                  }
                </Text>
              </LinearGradient>
            </TouchableOpacity>
          </View>

          {/* Additional Options */}
          <View className="mt-6 items-center">
            {mode === 'login' ? (
              <View className="flex-row">
                <Text className="text-gray-500 text-sm">Don't have an account? </Text>
                <TouchableOpacity onPress={() => setMode('register')}>
                  <Text className="text-blue-500 text-sm font-bold">Register here</Text>
                </TouchableOpacity>
              </View>
            ) : (
              <View className="flex-row">
                <Text className="text-gray-500 text-sm">Already have an account? </Text>
                <TouchableOpacity onPress={() => setMode('login')}>
                  <Text className="text-blue-500 text-sm font-bold">Login here</Text>
                </TouchableOpacity>
              </View>
            )}
          </View>
        </View>

        {/* Bottom Spacing */}
        <View className="h-8" />
      </ScrollView>
    </View>
  );
};

export default UserLogin;
