import React from 'react';
import { Tabs } from 'expo-router';
import { FontAwesome5 } from '@expo/vector-icons';

// This component now ONLY defines the tabs themselves
export default function UserTabLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false, // Stack navigator handles headers
        tabBarActiveTintColor: '#F37307',
        tabBarStyle: { paddingBottom: 5, paddingTop: 5, height: 60 } // Example style
      }}
    >
      <Tabs.Screen
        name="home" // Links to home.js
        options={{
          title: 'Home',
          tabBarIcon: ({ color }) => <FontAwesome5 size={24} name="home" color={color} />,
        }}
      />
      <Tabs.Screen
        name="plans" // Links to plans.js
        options={{
          title: 'Plans',
          tabBarIcon: ({ color }) => <FontAwesome5 size={24} name="clipboard-list" color={color} />,
        }}
      />
      <Tabs.Screen
        name="analysis" // Links to analysis.js
        options={{
          title: 'Analysis',
          tabBarIcon: ({ color }) => <FontAwesome5 size={24} name="chart-pie" color={color} />,
        }}
      />
      <Tabs.Screen
        name="profile" // Links to profile.js
        options={{
          title: 'Profile',
          tabBarIcon: ({ color }) => <FontAwesome5 size={24} name="user-alt" color={color} />,
        }}
      />
    </Tabs>
  );
}

