
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  SafeAreaView,
  Image,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
//import * as ImagePicker from 'expo-image-picker';
import { createUserWithEmailAndPassword } from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';
import { auth, db} from '@/firebase'; // Import your firebase instances
import {router} from "expo-router"
import * as ImagePicker from 'expo-image-picker';

export default function CreateProfile() {
  const [name, setName] = useState('');
  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [contactNumber, setContactNumber] = useState('');
  const [profilePicture, setProfilePicture] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [secureText, setSecureText] = useState(true);

  const pickImage = async () => {
    // No permissions request is necessary for launching the image library
    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true,
      aspect: [4, 3],
      quality: 1,
      base64:true,
    });

    console.log(result);

    let mimeType,dataUri;
    if(result.assets){
    mimeType = result.assets[0].mimeType || 'image/jpeg'; // Fallback to jpeg if mimeType is null
      
      // 2. Build the complete data URI
      dataUri = `data:${mimeType};base64,${result.assets[0].base64}`;
    }

    if (dataUri && !result.canceled) {
      setProfilePicture(dataUri);
    }
  };

  

 

  const handleRegister = async () => {
    // Clear previous error
    setError(null);

    // Validation (no changes here)
    if (!name || !username || !email || !password || !contactNumber) {
      setError('Please fill in all required fields');
      return;
    }
    if (password.length < 6) {
      setError('Password must be at least 6 characters');
      return;
    }
    if (contactNumber.length < 10) {
      setError('Please enter a valid contact number');
      return;
    }

    setLoading(true);
    try {
      // Create user with email and password
      const userCredential = await createUserWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // --- START: MODIFIED IMAGE UPLOAD LOGIC ---
      let profilePictureURL = null; // Default to null

      // 1. Check if the user picked a profile picture
      if (profilePicture) {
        console.log("Uploading profile picture to backend...");
        
        // 2. Make the POST request to your backend server
        const uploadResponse = await fetch('https://kasse-backend.onrender.com/upload', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            image: profilePicture, // Send the base64 data URI
          }),
        });

        const uploadData = await uploadResponse.json();

        // 3. Check if the upload was successful and get the new URL
        if (uploadResponse.ok && uploadData.imageURL) {
          profilePictureURL = uploadData.imageURL; // Get the public URL
          console.log("Profile picture uploaded successfully:", profilePictureURL);
        } else {
          // Handle cases where your backend fails, but don't block registration
          console.error("Backend image upload failed:", uploadData);
          // We can still create the user, just without a profile picture.
          // You could alert the user here if you prefer.
          // setError("Profile picture failed to upload, but profile was created.");
        }
      }
      // --- END: MODIFIED IMAGE UPLOAD LOGIC ---

      // Create user document in Firestore
      await setDoc(doc(db, "users", user.uid), {
        name,
        username,
        email,
        contactNumber,
        profilePictureURL, // This will be the URL from backend or null
        role: 'supermarket admin',
        supermarketId: "", // Initially empty
        createdAt: new Date(),
      });

      // On success, navigation will be handled by the auth state listener
      // in your root layout. No need for router.replace() here.
      // console.log("/screens/supermarket/register")
      // router.navigate('/screens/supermarket/register');

    } catch (err: any) {
      // Handle Firebase and other errors (no changes here)
      let errorMessage = 'An error occurred during registration';
      if (err.code === 'auth/email-already-in-use') {
        errorMessage = 'This email is already registered';
      } else if (err.code === 'auth/invalid-email') {
        errorMessage = 'Invalid email address';
      } // ... etc.
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={()=>router.back()}>
            <Ionicons name="arrow-back" size={24} color="#000" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Create Profile</Text>
          <View style={styles.placeholder} />
        </View>

        {/* Form */}
        <View style={styles.form}>
          {/* Error Message */}
          {error && (
            <View style={styles.errorContainer}>
              <Ionicons name="alert-circle" size={20} color="#DC2626" />
              <Text style={styles.errorText}>{error}</Text>
            </View>
          )}

          {/* Name Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Name</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter Name"
              placeholderTextColor="#B8956A"
              value={name}
              onChangeText={(text) => {
                setName(text);
                if (error) setError(null);
              }}
              editable={!loading}
            />
          </View>

          {/* Username Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Username</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter Username"
              placeholderTextColor="#B8956A"
              value={username}
              onChangeText={(text) => {
                setUsername(text);
                if (error) setError(null);
              }}
              autoCapitalize="none"
              editable={!loading}
            />
          </View>

          {/* Email Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Email</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter Email"
              placeholderTextColor="#B8956A"
              value={email}
              onChangeText={(text) => {
                setEmail(text);
                if (error) setError(null);
              }}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
              editable={!loading}
            />
          </View>

          {/* Password Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Password</Text>
            <View style={styles.passwordContainer}>
              <TextInput
                style={styles.passwordInput}
                placeholder="Enter Password (min 6 characters)"
                placeholderTextColor="#B8956A"
                value={password}
                onChangeText={(text) => {
                  setPassword(text);
                  if (error) setError(null);
                }}
                secureTextEntry={secureText}
                autoCapitalize="none"
                autoCorrect={false}
                editable={!loading}
              />
              <TouchableOpacity
                style={styles.eyeIcon}
                onPress={() => setSecureText(!secureText)}
                disabled={loading}
              >
                <Ionicons
                  name={secureText ? 'eye-off' : 'eye'}
                  size={20}
                  color="#666"
                />
              </TouchableOpacity>
            </View>
          </View>

          {/* Contact Number Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Contact Number</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter Contact Number"
              placeholderTextColor="#B8956A"
              value={contactNumber}
              onChangeText={(text) => {
                setContactNumber(text);
                if (error) setError(null);
              }}
              keyboardType="phone-pad"
              maxLength={15}
              editable={!loading}
            />
          </View>

          {/* Profile Picture Upload */}
          <View style={styles.uploadSection}>
            <Text style={styles.uploadLabel}>
              Profile Picture <Text style={styles.optionalText}>(Optional)</Text>
            </Text>
            
            <View style={styles.uploadContainer}>
              <View style={styles.uploadBox}>
                {profilePicture ? (
                  <Image source={{ uri: profilePicture }} style={styles.profileImage} />
                ) : (
                  <>
                    <Text style={styles.uploadTitle}>Upload Picture</Text>
                    <Text style={styles.uploadSubtitle}>
                      Tap to upload your profile picture
                    </Text>
                  </>
                )}
              </View>
              <TouchableOpacity
                style={styles.uploadButton}
                onPress={pickImage}
                disabled={loading}
              >
                <Text style={styles.uploadButtonText}>Upload</Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Complete Profile Button */}
          <TouchableOpacity
            style={[styles.completeButton, loading && styles.completeButtonDisabled]}
            onPress={handleRegister}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator size="small" color="#000" />
            ) : (
              <Text style={styles.completeButtonText}>Complete Profile</Text>
            )}
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFEF9',
  },
  scrollContent: {
    paddingBottom: 30,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 16,
  },
  backButton: {
    width: 40,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#000',
  },
  placeholder: {
    width: 40,
  },
  form: {
    paddingHorizontal: 16,
    paddingTop: 10,
  },
  errorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FEE2E2',
    borderRadius: 8,
    padding: 12,
    marginBottom: 16,
    gap: 8,
  },
  errorText: {
    flex: 1,
    fontSize: 14,
    color: '#DC2626',
    fontWeight: '500',
  },
  inputGroup: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#000',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#FFF8E7',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 16,
    fontSize: 14,
    color: '#000',
  },
  passwordContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF8E7',
    borderRadius: 8,
    paddingHorizontal: 16,
  },
  passwordInput: {
    flex: 1,
    paddingVertical: 16,
    fontSize: 14,
    color: '#000',
  },
  eyeIcon: {
    padding: 4,
  },
  uploadSection: {
    marginBottom: 24,
  },
  uploadLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: '#000',
    marginBottom: 12,
  },
  optionalText: {
    fontWeight: '400',
    color: '#666',
  },
  uploadContainer: {
    marginTop: 8,
  },
  uploadBox: {
    backgroundColor: '#fff',
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#e0e0e0',
    borderStyle: 'dashed',
    padding: 40,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 160,
    marginBottom: 12,
  },
  uploadTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
    marginBottom: 8,
  },
  uploadSubtitle: {
    fontSize: 13,
    color: '#666',
    textAlign: 'center',
  },
  profileImage: {
    width: 120,
    height: 120,
    borderRadius: 60,
    resizeMode: 'cover',
  },
  uploadButton: {
    backgroundColor: '#fff',
    borderRadius: 8,
    paddingVertical: 12,
    paddingHorizontal: 32,
    alignSelf: 'center',
    borderWidth: 1,
    borderColor: '#ddd',
  },
  uploadButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#000',
  },
  completeButton: {
    backgroundColor: '#FDB022',
    borderRadius: 8,
    paddingVertical: 16,
    alignItems: 'center',
    marginTop: 20,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  completeButtonDisabled: {
    opacity: 0.7,
  },
  completeButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
  },
});