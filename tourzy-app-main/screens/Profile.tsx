import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  Image,
  TextInput,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';
import { auth, db } from '../firebase';
import { doc, getDoc, updateDoc, collection, query, where, getDocs, serverTimestamp } from 'firebase/firestore';

interface UserData {
  name: string;
  email: string;
  phoneNumber?: string;
  bio?: string;
  location?: string;
  preferences?: string[];
  visitedPlaces?: number;
  savedPlaces?: number;
  posts?: number;
}

function Profile() {
  const navigation = useNavigation<any>();
  const [userData, setUserData] = useState<UserData | null>(null);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  
  // Edit fields
  const [editName, setEditName] = useState('');
  const [editPhone, setEditPhone] = useState('');
  const [editBio, setEditBio] = useState('');
  const [editLocation, setEditLocation] = useState('');

  useEffect(() => {
    loadUserData();
  }, []);

  const loadUserData = async () => {
    try {
      const user = auth.currentUser;
      if (!user) {
        navigation.navigate('userLogin');
        return;
      }

      const userDoc = await getDoc(doc(db, 'users', user.uid));
      if (userDoc.exists()) {
        const data = userDoc.data();
        
        // Count user's posts
        const postsQuery = query(
          collection(db, 'posts'),
          where('userId', '==', user.uid)
        );
        const postsSnapshot = await getDocs(postsQuery);
        
        const userData: UserData = {
          name: data.name || 'Traveler',
          email: user.email || '',
          phoneNumber: data.phoneNumber,
          bio: data.bio,
          location: data.location,
          preferences: data.preferences || [],
          visitedPlaces: data.visitedPlaces?.length || 0,
          savedPlaces: data.savedPlaces?.length || 0,
          posts: postsSnapshot.size,
        };
        
        setUserData(userData);
        setEditName(userData.name);
        setEditPhone(userData.phoneNumber || '');
        setEditBio(userData.bio || '');
        setEditLocation(userData.location || '');
      }
    } catch (error) {
      console.error('Error loading user data:', error);
      Alert.alert('Error', 'Failed to load profile data');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const user = auth.currentUser;
      if (!user) return;

      await updateDoc(doc(db, 'users', user.uid), {
        name: editName,
        phoneNumber: editPhone,
        bio: editBio,
        location: editLocation,
        updatedAt: serverTimestamp(),
      });

      setUserData({
        ...userData!,
        name: editName,
        phoneNumber: editPhone,
        bio: editBio,
        location: editLocation,
      });

      setEditing(false);
      Alert.alert('Success', 'Profile updated successfully');
    } catch (error) {
      console.error('Error updating profile:', error);
      Alert.alert('Error', 'Failed to update profile');
    } finally {
      setSaving(false);
    }
  };

  const handleSignOut = async () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Sign Out',
          style: 'destructive',
          onPress: async () => {
            try {
              await auth.signOut();
              navigation.navigate('userLogin');
            } catch (error) {
              console.error('Error signing out:', error);
            }
          },
        },
      ]
    );
  };

  if (loading) {
    return (
      <View className="flex-1 bg-gray-50 items-center justify-center">
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Loading profile...</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="light-content" backgroundColor="#3b82f6" />
      
      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* Header with Gradient */}
        <View>
          <LinearGradient
            colors={['#3b82f6', '#8b5cf6']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={{ paddingTop: 48, paddingBottom: 80, paddingHorizontal: 20 }}
          >
            <View className="flex-row items-center justify-between mb-6">
              <TouchableOpacity onPress={() => navigation.goBack()}>
                <Ionicons name="arrow-back" size={24} color="#fff" />
              </TouchableOpacity>
              <Text className="text-white text-xl font-bold">My Profile</Text>
              <TouchableOpacity onPress={handleSignOut}>
                <Ionicons name="log-out-outline" size={24} color="#fff" />
              </TouchableOpacity>
            </View>
          </LinearGradient>
        </View>

        {/* Profile Card */}
        <View className="px-5 -mt-16">
          <View className="bg-white rounded-3xl p-6 shadow-xl">
            <View className="items-center mb-6">
              <View className="w-24 h-24 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full items-center justify-center mb-4 shadow-lg">
                <Text className="text-white text-4xl font-bold">
                  {userData?.name.charAt(0).toUpperCase()}
                </Text>
              </View>
              
              {editing ? (
                <View className="w-full">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Name</Text>
                  <TextInput
                    value={editName}
                    onChangeText={setEditName}
                    placeholder="Your name"
                    className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900 mb-3"
                  />
                </View>
              ) : (
                <Text className="text-2xl font-bold text-gray-900 mb-1">{userData?.name}</Text>
              )}
              
              <Text className="text-sm text-gray-500">{userData?.email}</Text>
            </View>

            {/* Stats */}
            <View className="flex-row justify-around mb-6 pb-6 border-b border-gray-100">
              <View className="items-center">
                <Text className="text-2xl font-bold text-blue-600">{userData?.posts || 0}</Text>
                <Text className="text-xs text-gray-500 mt-1">Posts</Text>
              </View>
              <View className="items-center">
                <Text className="text-2xl font-bold text-purple-600">{userData?.visitedPlaces || 0}</Text>
                <Text className="text-xs text-gray-500 mt-1">Visited</Text>
              </View>
              <View className="items-center">
                <Text className="text-2xl font-bold text-pink-600">{userData?.savedPlaces || 0}</Text>
                <Text className="text-xs text-gray-500 mt-1">Saved</Text>
              </View>
            </View>

            {/* Contact Info */}
            {editing ? (
              <>
                <View className="mb-4">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Phone Number</Text>
                  <TextInput
                    value={editPhone}
                    onChangeText={setEditPhone}
                    placeholder="Your phone number"
                    keyboardType="phone-pad"
                    className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                  />
                </View>
                
                <View className="mb-4">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Location</Text>
                  <TextInput
                    value={editLocation}
                    onChangeText={setEditLocation}
                    placeholder="Your location"
                    className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                  />
                </View>
                
                <View className="mb-4">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Bio</Text>
                  <TextInput
                    value={editBio}
                    onChangeText={setEditBio}
                    placeholder="Tell us about yourself"
                    multiline
                    numberOfLines={4}
                    className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                    style={{ textAlignVertical: 'top' }}
                  />
                </View>

                <View className="flex-row gap-3">
                  <TouchableOpacity
                    onPress={() => setEditing(false)}
                    className="flex-1 bg-gray-100 rounded-xl py-3"
                  >
                    <Text className="text-gray-700 text-center font-bold">Cancel</Text>
                  </TouchableOpacity>
                  
                  <TouchableOpacity
                    onPress={handleSave}
                    disabled={saving}
                    className="flex-1 rounded-xl overflow-hidden"
                  >
                    <LinearGradient
                      colors={saving ? ['#9ca3af', '#6b7280'] : ['#3b82f6', '#8b5cf6']}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 0 }}
                      style={{ paddingVertical: 12, alignItems: 'center' }}
                    >
                      {saving ? (
                        <ActivityIndicator color="#fff" />
                      ) : (
                        <Text className="text-white font-bold">Save</Text>
                      )}
                    </LinearGradient>
                  </TouchableOpacity>
                </View>
              </>
            ) : (
              <>
                {userData?.phoneNumber && (
                  <View className="flex-row items-center mb-3">
                    <Ionicons name="call" size={20} color="#6b7280" />
                    <Text className="text-gray-700 ml-3">{userData.phoneNumber}</Text>
                  </View>
                )}
                
                {userData?.location && (
                  <View className="flex-row items-center mb-3">
                    <Ionicons name="location" size={20} color="#6b7280" />
                    <Text className="text-gray-700 ml-3">{userData.location}</Text>
                  </View>
                )}
                
                {userData?.bio && (
                  <View className="mb-4 p-4 bg-gray-50 rounded-xl">
                    <Text className="text-gray-700 text-sm leading-5">{userData.bio}</Text>
                  </View>
                )}

                <TouchableOpacity
                  onPress={() => setEditing(true)}
                  className="bg-blue-500 rounded-xl py-3"
                >
                  <Text className="text-white text-center font-bold">Edit Profile</Text>
                </TouchableOpacity>
              </>
            )}
          </View>
        </View>

        {/* Quick Actions */}
        <View className="px-5 pt-5 pb-4">
          <Text className="text-lg font-bold text-gray-900 mb-3">Quick Actions</Text>
          
          <TouchableOpacity
            onPress={() => navigation.navigate('social')}
            className="bg-white rounded-2xl p-4 mb-3 shadow-sm flex-row items-center"
          >
            <View className="w-12 h-12 bg-purple-100 rounded-full items-center justify-center mr-4">
              <Ionicons name="images" size={24} color="#8b5cf6" />
            </View>
            <View className="flex-1">
              <Text className="text-base font-bold text-gray-900 mb-1">My Posts</Text>
              <Text className="text-xs text-gray-500">{userData?.posts || 0} posts shared</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => navigation.navigate('preference')}
            className="bg-white rounded-2xl p-4 mb-3 shadow-sm flex-row items-center"
          >
            <View className="w-12 h-12 bg-blue-100 rounded-full items-center justify-center mr-4">
              <Ionicons name="settings" size={24} color="#3b82f6" />
            </View>
            <View className="flex-1">
              <Text className="text-base font-bold text-gray-900 mb-1">Preferences</Text>
              <Text className="text-xs text-gray-500">Update travel preferences</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => navigation.navigate('itinerary')}
            className="bg-white rounded-2xl p-4 shadow-sm flex-row items-center"
          >
            <View className="w-12 h-12 bg-green-100 rounded-full items-center justify-center mr-4">
              <Ionicons name="calendar" size={24} color="#16a34a" />
            </View>
            <View className="flex-1">
              <Text className="text-base font-bold text-gray-900 mb-1">My Itinerary</Text>
              <Text className="text-xs text-gray-500">View travel plans</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
          </TouchableOpacity>
        </View>

        {/* Sign Out Button */}
        <View className="px-5 pb-6">
          <TouchableOpacity
            onPress={handleSignOut}
            className="bg-red-50 border-2 border-red-200 rounded-2xl p-4 flex-row items-center justify-center"
          >
            <Ionicons name="log-out-outline" size={20} color="#dc2626" />
            <Text className="text-red-600 font-bold ml-2">Sign Out</Text>
          </TouchableOpacity>
        </View>

        {/* Bottom Spacing */}
        <View className="h-6" />
      </ScrollView>
    </View>
  );
}

export default Profile;

