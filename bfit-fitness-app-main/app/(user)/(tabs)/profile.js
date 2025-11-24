import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  TextInput,
  StyleSheet,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
  Image,
  ScrollView,
} from 'react-native';
import { auth, db } from '../../../firebaseConfig';
import { doc, getDoc, updateDoc } from 'firebase/firestore';
import { signOut } from 'firebase/auth';
import { useRouter } from 'expo-router';

const UserProfileScreen = () => {
  const [userData, setUserData] = useState(null);
  const [age, setAge] = useState('');
  const [weight, setWeight] = useState('');
  const [height, setHeight] = useState('');
  const [loading, setLoading] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const fetchUserData = async () => {
      try {
        const userId = auth.currentUser?.uid;
        const userRef = doc(db, 'users', userId);
        const userSnap = await getDoc(userRef);
        const data = userSnap.data();

        setUserData(data);
        setAge(data.age?.toString() ?? '');
        setWeight(data.weight?.toString() ?? '');
        setHeight(data.height?.toString() ?? '');
      } catch (error) {
        console.error('Error fetching user data:', error);
        Alert.alert('Error', 'Could not load profile.');
      } finally {
        setLoading(false);
      }
    };

    fetchUserData();
  }, []);

  const handleSave = async () => {
    try {
      const userId = auth.currentUser?.uid;
      const userRef = doc(db, 'users', userId);
      await updateDoc(userRef, {
        age: parseInt(age),
        weight: parseFloat(weight),
        height: parseFloat(height),
      });
      Alert.alert('Success', 'Profile updated!');
    } catch (error) {
      console.error('Error updating profile:', error);
      Alert.alert('Error', 'Could not update profile.');
    }
  };

  const handleLogout = () => {
    signOut(auth)
      .then(() => router.replace('/'))
      .catch((error) => {
        console.error('Logout Error:', error);
        Alert.alert('Logout Error', error.message);
      });
  };

  if (loading) {
    return (
      <View style={styles.loader}>
        <ActivityIndicator size="large" color="#F37307" />
      </View>
    );
  }

  return (
    <ScrollView contentContainerStyle={styles.scrollContainer}>
      <View style={styles.header}>
        <Image source={require('../../../assets/images/logo.png')} style={styles.logo} />
        <Text style={styles.appName}>B-FIT</Text>
      </View>

      <Text style={styles.pageTitle}>My Profile</Text>

      <View style={styles.card}>
        <Text style={styles.label}>Name</Text>
        <Text style={styles.value}>{userData?.fullName ?? 'N/A'}</Text>

        <Text style={styles.label}>Email</Text>
        <Text style={styles.value}>{userData?.email ?? 'N/A'}</Text>

        <Text style={styles.label}>Age</Text>
        <TextInput style={styles.input} value={age} onChangeText={setAge} keyboardType="numeric" />

        <Text style={styles.label}>Weight (kg)</Text>
        <TextInput style={styles.input} value={weight} onChangeText={setWeight} keyboardType="numeric" />

        <Text style={styles.label}>Height (cm)</Text>
        <TextInput style={styles.input} value={height} onChangeText={setHeight} keyboardType="numeric" />

        <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
          <Text style={styles.saveText}>Save Changes</Text>
        </TouchableOpacity>
      </View>

      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <Text style={styles.logoutText}>LOGOUT</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  scrollContainer: {
    padding: 30,
    backgroundColor: '#fff',
    alignItems: 'center',
  },
  loader: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    marginBottom: 10,
  },
  logo: {
    width: 50,
    height: 50,
    marginRight: 10,
     marginTop: 15,
  },
  appName: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#F37307',
    marginTop: 12,
  },
  pageTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#212121',
    marginBottom: 20,
    alignSelf: 'center',
  },
  card: {
    width: '100%',
    backgroundColor: '#f9f9f9',
    borderRadius: 15,
    padding: 20,
    shadowColor: '#000',
    shadowOpacity: 0.05,
    shadowRadius: 5,
    elevation: 3,
    marginBottom: 30,
  },
  label: { fontSize: 14, color: '#777', marginTop: 10 },
  value: { fontSize: 16, fontWeight: '500', color: '#333', marginBottom: 10 },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 10,
    padding: 12,
    fontSize: 16,
    backgroundColor: '#fff',
    marginBottom: 10,
  },
  saveButton: {
    backgroundColor: '#f5cb10ff',
    paddingVertical: 12,
    borderRadius: 25,
    marginTop: 20,
    alignItems: 'center',
  },
  saveText: { color: '#fff', fontSize: 16, fontWeight: 'bold' },
  logoutButton: {
    backgroundColor: '#e63333ff',
    paddingVertical: 12,
    borderRadius: 25,
    alignItems: 'center',
    width: '100%',
  },
  logoutText: { color: '#fff', fontSize: 16, fontWeight: 'bold' },
});

export default UserProfileScreen;