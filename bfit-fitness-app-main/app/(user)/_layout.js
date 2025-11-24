import React from 'react';
import { Stack, useRouter } from 'expo-router'; // Import Stack and useRouter
import { FontAwesome5 } from '@expo/vector-icons';
import { TouchableOpacity } from 'react-native';

export default function UserStackLayout() {
  const router = useRouter();
  return (
    // Use Stack as the main navigator for this section
    <Stack
      screenOptions={{
        headerStyle: { backgroundColor: '#F37307' },
        headerTintColor: '#fff',
        headerTitleStyle: { fontWeight: 'bold' },
        // Add a back button that uses the router
        headerLeft: (props) => (
            props.canGoBack ? (
                <TouchableOpacity onPress={() => router.back()} style={{ marginLeft: 15 }}>
                    <FontAwesome5 name="arrow-left" size={20} color="#fff" />
                </TouchableOpacity>
            ) : null
        )
      }}
    >
      {/* Define the main Tabs screen within the Stack */}
      {/* This name MUST match the folder name: (tabs) */}
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} /> 
      
      {/* Define the detail screens directly in the Stack */}
      {/* Headers will be automatically shown for these */}
      <Stack.Screen name="bmi" options={{ title: 'BMI Calculator' }} />
      <Stack.Screen name="workouts" options={{ title: 'Workout History' }} />
      <Stack.Screen name="calories" options={{ title: 'Calorie Tracking' }} />
      <Stack.Screen name="progress" options={{ title: 'Weekly Progress' }} />
      
      {/* Add other potential detail screens for the user section here */}

    </Stack>
  );
}

