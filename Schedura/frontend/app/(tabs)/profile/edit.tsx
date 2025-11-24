import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, TouchableOpacity, ScrollView, StatusBar, Alert, ActivityIndicator, Image } from 'react-native';
import SafeBoundingView from '@/components/SafeBoundingView';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useUser } from '@clerk/clerk-expo';
import { getUserInfo } from '@/supabase/controllers/user.controller';
import { useTheme } from '@/contexts/ThemeContext';

const EditProfileScreen = () => {
  const { colors, isDark } = useTheme();
  const router = useRouter();
  const { user: authUser } = useUser();
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [bio, setBio] = useState('');
  const [location, setLocation] = useState('');
  const [avatarUri, setAvatarUri] = useState<string | null>(null);

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchProfile = async () => {
    setLoading(true);
    try {
      const data = await getUserInfo(authUser?.id!);
      setName(data?.name || '');
      setEmail(data?.email || '');
      setPhone(data?.phone || '');
      setBio(data?.bio || '');
      setLocation(data?.location || '');
      setAvatarUri(authUser?.imageUrl || null);
    } catch (error) {
      console.error('Error fetching profile:', error);
    }
    setLoading(false);
  };

  const pickImage = async () => {
    Alert.alert(
      'Change Profile Picture',
      'This feature will be available soon. You can update your profile picture from your account settings.',
      [{ text: 'OK' }]
    );
  };

  const handleSave = async () => {
    if (!name.trim()) {
      Alert.alert('Error', 'Name is required');
      return;
    }

    setSaving(true);
    try {
      // Here you would update the user profile in Supabase
      // await updateUserProfile(authUser?.id!, { name, phone, bio, location });
      
      // Simulate save delay
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      Alert.alert('Success', 'Profile updated successfully', [
        { text: 'OK', onPress: () => router.back() }
      ]);
    } catch (error) {
      Alert.alert('Error', 'Failed to update profile');
    }
    setSaving(false);
  };

  if (loading) {
    return (
      <SafeBoundingView className="flex-1 items-center justify-center" style={{ backgroundColor: colors.background }}>
        <ActivityIndicator size="large" color={colors.accent} />
      </SafeBoundingView>
    );
  }

  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.backgroundSecondary }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
      
      {/* Header */}
      <View className="px-6 py-4 flex-row items-center justify-between border-b" style={{ backgroundColor: colors.card, borderBottomColor: colors.border }}>
        <TouchableOpacity onPress={() => router.back()} className="p-2">
          <Ionicons name="arrow-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <Text className="text-xl font-bold" style={{ color: colors.text }}>Edit Profile</Text>
        <TouchableOpacity 
          onPress={handleSave}
          disabled={saving}
          className="p-2"
        >
          {saving ? (
            <ActivityIndicator size="small" color={colors.accent} />
          ) : (
            <Text className="text-base font-semibold" style={{ color: colors.link }}>Save</Text>
          )}
        </TouchableOpacity>
      </View>

      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* Avatar Section */}
        <View className="py-8 items-center border-b" style={{ backgroundColor: colors.card, borderBottomColor: colors.border }}>
          <TouchableOpacity onPress={pickImage} className="relative">
            {avatarUri ? (
              <Image 
                source={{ uri: avatarUri }} 
                className="w-32 h-32 rounded-full"
                style={{ backgroundColor: colors.backgroundSecondary }}
              />
            ) : (
              <View className="w-32 h-32 rounded-full items-center justify-center" style={{ backgroundColor: colors.backgroundSecondary }}>
                <Ionicons name="person" size={48} color={colors.textSecondary} />
              </View>
            )}
            <View className="absolute bottom-0 right-0 p-2 rounded-full" style={{ backgroundColor: colors.link }}>
              <Ionicons name="camera" size={20} color="white" />
            </View>
          </TouchableOpacity>
          <Text className="text-sm mt-3" style={{ color: colors.textSecondary }}>Tap to change photo</Text>
        </View>

        {/* Form Section */}
        <View className="px-6 py-6">
          {/* Name */}
          <View className="mb-6">
            <Text className="text-sm font-semibold mb-2" style={{ color: colors.text }}>Full Name</Text>
            <View className="flex-row items-center rounded-xl px-4 py-3 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <Ionicons name="person-outline" size={20} color={colors.textSecondary} />
              <TextInput
                value={name}
                onChangeText={setName}
                placeholder="Enter your name"
                placeholderTextColor={colors.textSecondary}
                className="flex-1 ml-3 text-base"
                style={{ color: colors.text }}
              />
            </View>
          </View>

          {/* Email */}
          <View className="mb-6">
            <Text className="text-sm font-semibold mb-2" style={{ color: colors.text }}>Email</Text>
            <View className="flex-row items-center rounded-xl px-4 py-3 border" style={{ backgroundColor: colors.backgroundSecondary, borderColor: colors.border }}>
              <Ionicons name="mail-outline" size={20} color={colors.textSecondary} />
              <TextInput
                value={email}
                editable={false}
                placeholder="Email"
                placeholderTextColor={colors.textSecondary}
                className="flex-1 ml-3 text-base"
                style={{ color: colors.textSecondary }}
              />
            </View>
            <Text className="text-xs mt-1" style={{ color: colors.textSecondary }}>Email cannot be changed</Text>
          </View>

          {/* Phone */}
          <View className="mb-6">
            <Text className="text-sm font-semibold mb-2" style={{ color: colors.text }}>Phone Number</Text>
            <View className="flex-row items-center rounded-xl px-4 py-3 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <Ionicons name="call-outline" size={20} color={colors.textSecondary} />
              <TextInput
                value={phone}
                onChangeText={setPhone}
                placeholder="+1 (555) 000-0000"
                placeholderTextColor={colors.textSecondary}
                keyboardType="phone-pad"
                className="flex-1 ml-3 text-base"
                style={{ color: colors.text }}
              />
            </View>
          </View>

          {/* Location */}
          <View className="mb-6">
            <Text className="text-sm font-semibold mb-2" style={{ color: colors.text }}>Location</Text>
            <View className="flex-row items-center rounded-xl px-4 py-3 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <Ionicons name="location-outline" size={20} color={colors.textSecondary} />
              <TextInput
                value={location}
                onChangeText={setLocation}
                placeholder="City, Country"
                placeholderTextColor={colors.textSecondary}
                className="flex-1 ml-3 text-base"
                style={{ color: colors.text }}
              />
            </View>
          </View>

          {/* Bio */}
          <View className="mb-6">
            <Text className="text-sm font-semibold mb-2" style={{ color: colors.text }}>Bio</Text>
            <View className="rounded-xl px-4 py-3 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <TextInput
                value={bio}
                onChangeText={setBio}
                placeholder="Tell us about yourself..."
                placeholderTextColor={colors.textSecondary}
                multiline
                numberOfLines={4}
                textAlignVertical="top"
                className="text-base"
                style={{ color: colors.text }}
              />
            </View>
            <Text className="text-xs mt-1" style={{ color: colors.textSecondary }}>{bio.length}/150 characters</Text>
          </View>

          {/* Save Button (Mobile) */}
          <TouchableOpacity
            onPress={handleSave}
            disabled={saving}
            className="rounded-xl py-4 items-center mt-4"
            style={{ backgroundColor: colors.accent }}
          >
            {saving ? (
              <ActivityIndicator size="small" color="white" />
            ) : (
              <Text className="text-base font-semibold" style={{ color: colors.primary }}>Save Changes</Text>
            )}
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeBoundingView>
  );
};

export default EditProfileScreen;
