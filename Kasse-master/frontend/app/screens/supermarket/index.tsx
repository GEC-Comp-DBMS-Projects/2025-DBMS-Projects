import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

// Note: This page is the entry screen for the Supermarket Admin flow.
// It assumes this file is located at app/screens/supermarket/index.tsx

export default function SupermarketAdminScreen() {
  const router = useRouter();
  
  // Custom colors to maintain brand consistency
  const PRIMARY_AMBER = '#FFBF00';
  const LIGHT_AMBER_BG = '#FFDDA0';

  // Custom styling for button shadows
  const buttonShadow = {
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 4,
    elevation: 4,
  };

  return (
    <View className="flex-1 bg-white p-6">
      
      {/* Custom Header Row */}
      <View className="flex-row items-center justify-between pt-4 pb-12">
        {/* Back Button */}
        <TouchableOpacity onPress={() => router.back()}>
          <Icon name="arrow-left" size={24} color="black" />
        </TouchableOpacity>

        {/* Title */}
        <Text className="text-xl font-bold text-black">
          Supermarket Admin
        </Text>

        {/* Info Icon */}
        <TouchableOpacity>
          <Icon name="information-outline" size={24} color="black" />
        </TouchableOpacity>
      </View>

      {/* Main Content Area */}
      <View className="items-center justify-start ">
        
        {/* Large Main Heading */}
        <Text className="text-3xl font-extrabold text-black text-center mb-4">
          Manage your store
        </Text>

        {/* Description Text */}
        <Text className="text-base text-gray-700 text-center mb-10 leading-relaxed">
          Manage your store with our user-friendly admin tools. Register your supermarket or log in to oversee inventory, track sales, and enable seamless self-checkout for your customers.
        </Text>

        {/* 1. Register Button (Primary Action) */}
        <TouchableOpacity
          className="w-full py-4 rounded-xl items-center justify-center mb-4"
          style={{ backgroundColor: PRIMARY_AMBER, ...buttonShadow }}
          onPress={() => { router.navigate("/screens/supermarket/(auth)/signup")}}
        >
          <Text className="text-lg font-bold text-black">
            Register Supermarket
          </Text>
        </TouchableOpacity>

        {/* 2. Login Button (Secondary Action) */}
        <TouchableOpacity
          className="w-full py-4 rounded-xl items-center justify-center  "
          style={{ backgroundColor: LIGHT_AMBER_BG, ...buttonShadow }}
          onPress={() => { router.navigate("/screens/supermarket/(auth)/signin") }}
        >
          <Text className="text-lg font-bold text-gray-800">
            Login to Admin Panel
          </Text>
        </TouchableOpacity>
        
      </View>
    </View>
  );
}
