

import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { useRouter,useFocusEffect } from 'expo-router';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { LinearGradient } from 'expo-linear-gradient';
import {auth} from "@/firebase";
import { signOut } from 'firebase/auth';

export default function WelcomeScreen() {
  const router = useRouter();

  const GOLD_YELLOW = '#FFBF00';
  
  const gradientColors = [
    '#FFBF00',
    '#F4F6B6',
    '#F4F6B6', 
    '#FFBF00',
  ] as const;
  
  const gradientLocations = [0, 0.18, 0.79, 1] as const;

  const handleCustomerPress = () => {
    router.replace("/signup" as any);
  };
  
  const cardShadow = {
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.25,
    shadowRadius: 10,
    elevation: 8,
  };


  useFocusEffect(
    React.useCallback(() => {
      // Do something when the screen is focused
      signOut(auth).then(()=>{
        console.log("admin signed out")
        
      }).catch((error) => {
        // You can optionally handle any sign-out errors here
        console.error("Failed to sign out on welcome screen:", error);
      })
      return () => {
        // Do something when the screen is unfocused
        // Useful for cleanup functions
      };
    }, [])
  );


  return (
    <LinearGradient
      colors={gradientColors}
      locations={gradientLocations}
      className="flex-1 items-center justify-center p-4"
    >
      <View 
        className="w-full max-w-sm rounded-3xl bg-white px-8 py-16 items-center"
        style={cardShadow}
      >
        <Text 
          className="text-7xl font-extrabold font-[Inter] mb-10"
          style={{ color:'#ffbf00', textShadowColor: 'rgba(0, 0, 0, 0.3)', textShadowOffset: {width: 2, height: 2}, textShadowRadius: 3 }}
        >
          KASSE
        </Text>
        <Text className="text-lg text-center mb-10 text-gray-600">
          Please select your role to continue
        </Text>


        <TouchableOpacity
          className="w-full py-3 px-4 rounded-xl flex-row items-center justify-start space-x-3 mb-16"
          style={{ backgroundColor: '#FFDDA0', ...cardShadow, borderColor: '#f0e580ff', borderWidth: 1 }}
          onPress={() => router.push('./screens/supermarket')}
        >
          <View 
            className="p-3 rounded-full"
            style={{ backgroundColor: 'white', borderColor: 'white', borderWidth: 1 }}
          >
            <Icon name="cart-variant" size={28} color={GOLD_YELLOW} />
          </View>
         <View className="flex-1 items-center justify-center">   
          <View className="flex-col items-center justify-center">
            <Text className="text-lg font-bold text-black">Supermarket</Text>
            <Text className="text-lg font-bold text-black">  Admin</Text>
          </View>
          </View>
        </TouchableOpacity>

        <TouchableOpacity
          className="w-full py-3 px-4 rounded-xl flex-row items-center justify-start space-x-3 shadow-md"
          style={{ backgroundColor: '#FFDDA0', ...cardShadow, borderColor: '#f0e580ff', borderWidth: 1 }}
          onPress={() => router.push('./screens/customer')}
        >
          <View 
            className="p-3 rounded-full"
            style={{ backgroundColor: 'white', borderColor: 'white', borderWidth: 1 }}
          >
            <Icon name="shopping-outline" size={28} color={GOLD_YELLOW} />
          </View>
          <View className="flex-1 items-center justify-center"> 
          <Text className="text-xl font-bold text-black">Customer</Text>
           </View>
        </TouchableOpacity>
      </View>

      
    </LinearGradient>
  );
}
