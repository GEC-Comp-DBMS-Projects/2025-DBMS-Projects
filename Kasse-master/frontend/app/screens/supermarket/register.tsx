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
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import {doc,addDoc, collection,updateDoc} from "firebase/firestore";
import { db } from "@/firebase";
import { useAdminContext } from './context/adminContext';
import {router} from "expo-router"
import * as ImagePicker from 'expo-image-picker';

export default function RegisterSupermarket() {
  const [supermarketName, setSupermarketName] = useState('');
  const [streetAddress, setStreetAddress] = useState('');
  const [state, setState] = useState('');
  const [pinCode, setPinCode] = useState('');
  const [description, setDescription] = useState('');
  const [supermarketPicture, setSupermarketPicture] = useState('');
  const [gstin, setGstin] = useState('');
  const {authAdmin,AdminProfileData} = useAdminContext();

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
        setSupermarketPicture(dataUri);
      }
  };

  const handleRegister = async () => {
    if (!supermarketName || !streetAddress || !state || !pinCode) {
      console.log('Error', 'Please fill in all required fields');
      return;
    }

    if (!authAdmin) {
      Alert.alert("Error", "You must be logged in.");
      return;
    }

    try{

            let finalImageUrl = null; // This will hold the public URL from your backend

            // --- START: Added Code ---
            
            // 1. Check if the user picked an image
            if (supermarketPicture) {
              console.log("Uploading image to backend...");
              
              // 2. Make the POST request to your backend server
              const uploadResponse = await fetch('https://kasse-backend.onrender.com/upload', {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                  image: supermarketPicture, // Send the base64 data URI
                }),
              });

              const uploadData = await uploadResponse.json();

              // 3. Check if the upload was successful and get the new URL
              if (uploadResponse.ok && uploadData.imageURL) {
                finalImageUrl = uploadData.imageURL; // Get the public URL from your backend's response
                console.log("Image uploaded successfully:", finalImageUrl);
              } else {
                // Handle cases where your backend fails
                console.error("Backend image upload failed:", uploadData);
                Alert.alert("Error", "Image upload failed. Please try again.");
                return; // Stop the registration
              }
            }

            const docRef=await addDoc(collection(db,"supermarket"),
            {
              sname:supermarketName,
              adminId:authAdmin.uid,
              streetAddress,
              state,
              pinCode,
              gstin: gstin,
              desc:description,
              supermarketImgUrl:finalImageUrl,
              dateCreated:new Date()
            }

            )

            const adminDoc= doc (db,"users",authAdmin.uid)
            await updateDoc(adminDoc,{
              supermarketId:docRef.id
            })

            console.log("Document written with id : ",docRef)
            
            console.log('Success', 'Supermarket registered successfully!');
            if(Platform.OS=='web'){
              router.replace("/");
            }
            else{
            Alert.alert("You have successfully registered please login");
            }
            router.replace("/");
       }
       catch (error) {
      console.log("Error", "Could not register supermarket.");
      console.error(error);
    }
  };
  console.log("profile : ",AdminProfileData);

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={()=>router.back()}>
            <Ionicons name="arrow-back" size={24} color="#000" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Register Supermarket</Text>
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

          <View style={styles.inputGroup}>
          <Text style={styles.label}>GSTIN</Text>
          <TextInput
            style={styles.input}
            placeholder="Enter 15-digit GSTIN"
            placeholderTextColor="#999"
            value={gstin}
            onChangeText={setGstin}
            maxLength={15} // GSTIN is 15 characters
            autoCapitalize="characters" // GSTIN is usually uppercase
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
              {supermarketPicture ? (
                <Image source={{ uri: supermarketPicture }} style={styles.uploadedImage} />
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
              <Text style={styles.uploadButtonText}>Upload</Text>
            </TouchableOpacity>
          </View>

          {/* Register Button */}
          <TouchableOpacity style={styles.registerButton} onPress={handleRegister}>
            <Text style={styles.registerButtonText}>Register</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

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