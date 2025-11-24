import React from 'react';
import { Stack, useRouter } from 'expo-router'; // Import Stack and useRouter
import { FontAwesome5 } from '@expo/vector-icons';
import { TouchableOpacity } from 'react-native';

export default function TrainerStackLayout() {
  const router = useRouter();
  return (
    <Stack
      screenOptions={{
        headerStyle: { backgroundColor: '#fff' }, // White header background
        headerTintColor: '#333', // Dark text/icons in header
        headerTitleStyle: { fontWeight: 'bold' },
        headerBackTitleVisible: false, // Hide "Back" text on iOS
        // Add a back button that uses the router
        headerLeft: (props) => (
            props.canGoBack ? (
                <TouchableOpacity onPress={() => router.back()} style={{ marginLeft: 15 }}>
                    <FontAwesome5 name="arrow-left" size={20} color="#333" />
                </TouchableOpacity>
            ) : null
        )
      }}
    >
      {/* Define the screens within the trainer section */}

      {/* Hide headers for the main tab screens as they use TrainerHeader */}
      <Stack.Screen
        name="clients"
        options={{ headerShown: false }}
      />
      <Stack.Screen
        name="workout"
        options={{ headerShown: false }} // Updated: Uses custom header now
      />
      <Stack.Screen
        name="analysis"
        options={{ headerShown: false }} // Updated: Will likely use custom header
      />

      {/* Keep the default header for the dynamic client workout detail screen */}
      <Stack.Screen
        name="client-workout/[clientId]"
        options={{ title: 'Client Workout Plan' }}
      />

      {/* --- ADDED THIS SCREEN --- */}
      <Stack.Screen
        name="add-edit-plan"
        options={{ headerShown: false }} // Uses custom header
      />
      {/* --- END ADD --- */}

      {/* Add other potential trainer detail screens here */}

    </Stack>
  );
}

