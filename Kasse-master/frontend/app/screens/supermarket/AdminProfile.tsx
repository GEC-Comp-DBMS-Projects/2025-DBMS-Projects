// app/screens/supermarket/AdminProfileScreen.tsx
import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  SafeAreaView,
  Image,
  Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from "expo-router";
import { signOut } from 'firebase/auth';
import { auth } from '@/firebase'; // Import your firebase auth instance
import { useAdminContext } from './context/adminContext'; // Adjust path if needed

// --- Constants ---
const PRIMARY_AMBER = '#FFBF00';
const CARD_BG = '#FFFFFF';
const LIGHT_BG = '#F7F7F7';
const TEXT_COLOR = '#333';
const LIGHT_TEXT_COLOR = '#666';
const BORDER_COLOR = '#E0E0E0';
const LOGOUT_RED = '#DC2626';

export default function AdminProfileScreen() {
  const router = useRouter();
  const { AdminProfileData, authAdmin } = useAdminContext(); // Get admin data and auth user

  const handleLogout = async () => {
    try {
          await signOut(auth);
          router.navigate("/");
        } catch (error) {
          console.error('Error signing out:', error);
          console.log('Error', 'Failed to logout. Please try again.');
        }
  };

  // Fallback image if profile picture URL is missing
  const profilePicSource : any = AdminProfileData?.profilePictureURL
    ? AdminProfileData?.profilePictureURL 
    : 'https://picsum.photos/150' ; // Ensure you have a default avatar image

  return (
    <SafeAreaView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
          <Ionicons name="arrow-back" size={24} color="#000" />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Profile</Text>
        <View style={styles.placeholder} />
      </View>

      {/* Profile Content */}
      <View style={styles.content}>
        <Image
          source={{uri: profilePicSource}}
          style={styles.profileImage}
          onError={(e) => console.log("Failed to load profile image:", e.nativeEvent.error)}
        />
        <Text style={styles.usernameText}>
          {AdminProfileData?.username || 'Admin User'}
        </Text>
        <Text style={styles.emailText}>
          {authAdmin?.email || 'email@example.com'}
        </Text>

        {/* Logout Button */}
        <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
          <Ionicons name="log-out-outline" size={22} color={LOGOUT_RED} />
          <Text style={styles.logoutButtonText}>Logout</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

// --- Stylesheet ---
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: LIGHT_BG,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 16,
    backgroundColor: CARD_BG,
    borderBottomWidth: 1,
    borderBottomColor: BORDER_COLOR,
  },
  backButton: {
    width: 40,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: TEXT_COLOR,
  },
  placeholder: {
    width: 40,
  },
  content: {
    flex: 1,
    alignItems: 'center',
    paddingTop: 40,
    paddingHorizontal: 20,
  },
  profileImage: {
    width: 120,
    height: 120,
    borderRadius: 60, // Makes it circular
    borderWidth: 3,
    borderColor: PRIMARY_AMBER,
    marginBottom: 20,
    backgroundColor: '#eee', // Placeholder bg color
  },
  usernameText: {
    fontSize: 22,
    fontWeight: 'bold',
    color: TEXT_COLOR,
    marginBottom: 8,
  },
  emailText: {
    fontSize: 16,
    color: LIGHT_TEXT_COLOR,
    marginBottom: 40,
  },
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: CARD_BG,
    paddingVertical: 12,
    paddingHorizontal: 30,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: LOGOUT_RED,
    marginTop: 'auto', // Pushes button towards the bottom
    marginBottom: 40,
  },
  logoutButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: LOGOUT_RED,
    marginLeft: 8,
  },
});