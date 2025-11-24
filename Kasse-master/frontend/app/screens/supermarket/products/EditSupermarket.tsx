import React, { useState, useEffect } from 'react'; // Added useEffect
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
  ActivityIndicator, // Added
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { doc, updateDoc, getDoc } from "firebase/firestore"; // Added getDoc
import { db } from "@/firebase";
import { useAdminContext } from '../context/adminContext';
import { router } from "expo-router"
import * as ImagePicker from 'expo-image-picker';

export default function EditSupermarket() {
  // Form State
  const [supermarketName, setSupermarketName] = useState('');
  const [streetAddress, setStreetAddress] = useState('');
  const [state, setState] = useState('');
  const [pinCode, setPinCode] = useState('');
  const [description, setDescription] = useState('');
  
  // Image State
  const [supermarketPicture, setSupermarketPicture] = useState(''); // Holds NEW base64 image
  const [currentImageUrl, setCurrentImageUrl] = useState(''); // Holds EXISTING image URL
  
  // Loading State
  const [isLoading, setIsLoading] = useState(true);
  const [isUpdating, setIsUpdating] = useState(false);
  
  const { authAdmin, AdminProfileData } = useAdminContext();

  // --- 1. Fetch Existing Data ---
  useEffect(() => {
    if (!AdminProfileData?.supermarketId) {
      Alert.alert("Error", "Could not find supermarket ID. Please log in again.");
      router.replace("/"); // Go back home if no ID
      return;
    }

    const fetchSupermarketData = async () => {
      setIsLoading(true);
      try {
        const supermarketDocRef = doc(db, 'supermarket', AdminProfileData.supermarketId);
        const docSnap = await getDoc(supermarketDocRef);

        if (docSnap.exists()) {
          const data = docSnap.data();
          // Populate all the form fields
          setSupermarketName(data.sname || '');
          setStreetAddress(data.streetAddress || '');
          setState(data.state || '');
          setPinCode(data.pinCode || '');
          setDescription(data.desc || '');
          setCurrentImageUrl(data.supermarketImgUrl || ''); // Set the current image
        } else {
          Alert.alert("Error", "Supermarket document not found.");
        }
      } catch (error) {
        console.error("Error fetching supermarket data:", error);
        Alert.alert("Error", "Could not load supermarket data.");
      } finally {
        setIsLoading(false);
      }
    };

    fetchSupermarketData();
  }, [AdminProfileData]); // Re-run if profile data (and ID) loads

  // --- 2. Pick Image (Same as Register) ---
  const pickImage = async () => {
    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes:['images'],
      allowsEditing: true,
      aspect: [4, 3],
      quality: 1,
      base64: true,
    });

    if (result.assets && !result.canceled) {
      const mimeType = result.assets[0].mimeType || 'image/jpeg';
      const dataUri = `data:${mimeType};base64,${result.assets[0].base64}`;
      setSupermarketPicture(dataUri); // Set the NEW base64 image
    }
  };

  // --- 3. Handle Update (Adapted from Register) ---
  const handleUpdate = async () => {
    if (!supermarketName || !streetAddress || !state || !pinCode) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }
    if (!authAdmin || !AdminProfileData?.supermarketId) {
      Alert.alert("Error", "Authentication error or missing ID.");
      return;
    }

    setIsUpdating(true);

    try {
      let finalImageUrl = currentImageUrl; // Start with the existing image URL

      // 1. Check if the user picked a NEW image
      if (supermarketPicture) {
        console.log("Uploading new image to backend...");
        const uploadResponse = await fetch('https://kasse-backend.onrender.com/upload', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ image: supermarketPicture }), // Send the NEW base64
        });

        const uploadData = await uploadResponse.json();

        if (uploadResponse.ok && uploadData.imageURL) {
          finalImageUrl = uploadData.imageURL; // Get the NEW public URL
          console.log("Image updated successfully:", finalImageUrl);
        } else {
          throw new Error(uploadData.error || "Backend image upload failed");
        }
      }

      // 2. Prepare data for update
      const updatedData = {
        sname: supermarketName,
        streetAddress,
        state,
        pinCode,
        desc: description,
        supermarketImgUrl: finalImageUrl, // Use new URL or the original one
      };

      // 3. Update the existing document
      const supermarketDocRef = doc(db, "supermarket", AdminProfileData.supermarketId);
      await updateDoc(supermarketDocRef, updatedData);

      Alert.alert('Success', 'Supermarket updated successfully!');
      router.back(); // Go back to the previous screen (e.g., Dashboard)

    } catch (error:any) {
      console.log("Error", "Could not update supermarket.");
      console.error(error);
      Alert.alert("Error", `Update failed: ${error.message}`);
    } finally {
      setIsUpdating(false);
    }
  };

  // --- Show loading indicator while fetching ---
  if (isLoading) {
    return (
      <SafeAreaView style={[styles.container, { justifyContent: 'center', alignItems: 'center' }]}>
        <ActivityIndicator size="large" color="#FDB022" />
      </SafeAreaView>
    );
  }

  // Determine which image to show: the new one (if picked) or the current one
  const displayImageUri = supermarketPicture || currentImageUrl;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
            <Ionicons name="arrow-back" size={24} color="#000" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Edit Supermarket</Text>
        </View>

        {/* Form */}
        <View style={styles.form}>
          {/* Supermarket Name */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Supermarket Name</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter Supermarket Name"
              placeholderTextColor="#999"
              value={supermarketName}
              onChangeText={setSupermarketName}
            />
          </View>

          {/* Street Address */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Street Address</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter Street Address"
              placeholderTextColor="#999"
              value={streetAddress}
              onChangeText={setStreetAddress}
            />
          </View>

          {/* State and Pin Code */}
          <View style={styles.row}>
            <View style={[styles.inputGroup, styles.halfWidth]}>
              <Text style={styles.label}>State</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter State"
                placeholderTextColor="#999"
                value={state}
                onChangeText={setState}
              />
            </View>
            <View style={[styles.inputGroup, styles.halfWidth]}>
              <Text style={styles.label}>Pin Code</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter Pin Code"
                placeholderTextColor="#999"
                value={pinCode}
                onChangeText={setPinCode}
                keyboardType="numeric"
                maxLength={6}
              />
            </View>
          </View>

          {/* Description */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Description</Text>
            <TextInput
              style={[styles.input, styles.textArea]}
              placeholder=""
              placeholderTextColor="#999"
              value={description}
              onChangeText={setDescription}
              multiline
              numberOfLines={4}
              textAlignVertical="top"
            />
          </View>

          {/* Upload Image */}
          <View style={styles.uploadContainer}>
            <View style={styles.uploadBox}>
              {displayImageUri ? (
                <Image source={{ uri: displayImageUri }} style={styles.uploadedImage} />
              ) : (
                <>
                  <Text style={styles.uploadTitle}>Upload Image</Text>
                  <Text style={styles.uploadSubtitle}>
                    Tap to upload an image of your supermarket
                  </Text>
                </>
              )}
            </View>
            <TouchableOpacity style={styles.uploadButton} onPress={pickImage}>
              <Text style={styles.uploadButtonText}>
                {displayImageUri ? "Change Image" : "Upload Image"}
              </Text>
            </TouchableOpacity>
          </View>

          {/* Update Button */}
          <TouchableOpacity
            style={[styles.registerButton, isUpdating && { opacity: 0.7 }]}
            onPress={handleUpdate}
            disabled={isUpdating}
          >
            {isUpdating ? (
              <ActivityIndicator color="#000" />
            ) : (
              <Text style={styles.registerButtonText}>Update Supermarket</Text>
            )}
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

// --- Styles (Copied directly from RegisterSupermarket) ---
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  scrollContent: {
    paddingBottom: 30,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  backButton: {
    marginRight: 16,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#000',
  },
  form: {
    padding: 16,
  },
  inputGroup: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: '#000',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#FFF8E7',
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 14,
    fontSize: 14,
    color: '#000',
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 12,
  },
  halfWidth: {
    flex: 1,
  },
  textArea: {
    height: 120,
    paddingTop: 14,
  },
  uploadContainer: {
    marginBottom: 20,
  },
  uploadBox: {
    backgroundColor: '#fff',
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#e0e0e0',
    borderStyle: 'dashed',
    padding: 32,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 150,
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
  uploadedImage: {
    width: '100%',
    height: 150,
    borderRadius: 8,
    resizeMode: 'cover',
  },
  uploadButton: {
    backgroundColor: '#fff',
    borderRadius: 8,
    paddingVertical: 12,
    paddingHorizontal: 24,
    alignSelf: 'center',
    borderWidth: 1,
    borderColor: '#ddd',
  },
  uploadButtonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#000',
  },
  registerButton: {
    backgroundColor: '#FDB022',
    borderRadius: 8,
    paddingVertical: 16,
    alignItems: 'center',
    marginTop: 10,
  },
  registerButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#000',
  },
});