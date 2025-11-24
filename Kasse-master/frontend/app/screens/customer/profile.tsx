import React from 'react';
import { View, Text, Pressable, ScrollView, Image } from 'react-native';
import { ChevronLeft, ChevronRight, User, ShoppingBag, List, Settings, Tag, HelpCircle, Info, LogOut } from 'lucide-react-native';
import { router } from 'expo-router';
import { getAuth, signOut } from 'firebase/auth';

// Initialize auth instance (adjust if you have a custom Firebase app)
const auth = getAuth();

const ProfilePage = () => {
  const user = auth.currentUser;

  const handleLogout = async () => {
    try {
      await signOut(auth);
      router.replace('../app'); // Adjust to your login route
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const MenuItem = ({ icon: Icon, label, onPress }: { icon: any; label: string; onPress: () => void }) => (
    <Pressable
      onPress={onPress}
      className="flex-row items-center justify-between py-4 border-b border-gray-100"
    >
      <View className="flex-row items-center">
        <Icon size={20} color="#666" />
        <Text className="ml-3 text-base text-gray-800">{label}</Text>
      </View>
      <ChevronRight size={20} color="#999" />
    </Pressable>
  );

  return (
    <View className="flex-1 bg-gray-50">
      {/* Header with Profile Info */}
      <View className="bg-amber-400 px-4 pt-12 pb-8">
        <Pressable onPress={() => router.back()} className="mb-4">
          <ChevronLeft size={24} color="#000" />
        </Pressable>
        
        <View className="flex-row items-center">
          <View className="w-20 h-20 bg-white rounded-full items-center justify-center">
            {user?.photoURL ? (
              <Image 
                source={{ uri: user.photoURL }} 
                className="w-20 h-20 rounded-full"
              />
            ) : (
              <View className="w-20 h-20 bg-green-500 rounded-full items-center justify-center">
                <Text className="text-white text-2xl font-bold">
                  {user?.displayName?.charAt(0).toUpperCase() || user?.email?.charAt(0).toUpperCase() || 'U'}
                </Text>
              </View>
            )}
          </View>
          
          <View className="ml-4">
            <Text className="text-lg font-semibold text-black">Hello!</Text>
            <Text className="text-2xl font-bold text-black">
              {user?.displayName || user?.email?.split('@')[0] || 'User'}
            </Text>
          </View>
        </View>
      </View>

      <ScrollView className="flex-1 px-4">
        {/* My Account Section */}
        <View className="bg-white rounded-lg mt-4 px-4 py-2">
          <Text className="text-lg font-bold text-gray-900 mb-2">My Account</Text>
          
          <MenuItem
            icon={User}
            label="Edit Profile"
            onPress={() => {
              // Navigate to edit profile
              console.log('Edit Profile');
            }}
          />
          
          <MenuItem
            icon={ShoppingBag}
            label="Past Orders"
            onPress={() => {
              router.push('/screens/customer/orderHistory');
            }}
          />
          
          <MenuItem
            icon={List}
            label="Shopping Lists"
            onPress={() => {
              // Navigate to shopping lists
              router.navigate('/screens/customer/ShoppingList')
              console.log('Shopping Lists');
            }}
          />
          
          <MenuItem
            icon={Settings}
            label="Settings"
            onPress={() => {
              // Navigate to settings
              console.log('Settings');
            }}
          />
          
          <MenuItem
            icon={Tag}
            label="Coupons"
            onPress={() => {
              // Navigate to coupons
              console.log('Coupons');
            }}
          />
        </View>

        {/* Other Information Section */}
        <View className="bg-white rounded-lg mt-4 px-4 py-2 mb-4">
          <Text className="text-lg font-bold text-gray-900 mb-2">Other Information</Text>
          
          <MenuItem
            icon={HelpCircle}
            label="Help & Support"
            onPress={() => {
              // Navigate to help
              console.log('Help & Support');
            }}
          />
          
          <MenuItem
            icon={Info}
            label="About us"
            onPress={() => {
              // Navigate to about
              console.log('About us');
            }}
          />
        </View>

        {/* Logout Button */}
        <Pressable
          onPress={handleLogout}
          className="flex-row items-center py-4 px-4"
        >
          <LogOut size={20} color="#EF4444" />
          <Text className="ml-2 text-base text-red-500 font-semibold">LOG OUT →</Text>
        </Pressable>
      </ScrollView>
    </View>
  );
};

export default ProfilePage;