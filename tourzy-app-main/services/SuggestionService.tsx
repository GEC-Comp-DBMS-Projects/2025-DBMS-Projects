import { useEffect, useState } from 'react';
import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

// Configure notification handler
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});

export interface Suggestion {
  place: string;
  description: string;
  reasonForSuggestion: string;
  distanceFromCurrent: number;
  duration: string;
  type: string;
  tags: string[];
}

export interface SuggestionData {
  decision: string;
  reason: string;
  notification: string;
  suggestions: Suggestion[];
}

const WEBHOOK_URL = 'https://n8n.srv1034714.hstgr.cloud/webhook/dd43dd17-772e-4f1e-9de2-09ed42e5df34';
const POLLING_INTERVAL = 30000; // Poll every 30 seconds

export const useSuggestionListener = () => {
  const [suggestions, setSuggestions] = useState<SuggestionData | null>(null);
  const [isListening, setIsListening] = useState(false);

  // Request notification permissions
  const requestPermissions = async () => {
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    
    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }
    
    if (finalStatus !== 'granted') {
      console.log('Failed to get notification permissions');
      return false;
    }
    
    return true;
  };

  // Send local notification
  const sendNotification = async (message: string) => {
    try {
      await Notifications.scheduleNotificationAsync({
        content: {
          title: '🎯 Travel Suggestion',
          body: message,
          sound: true,
          priority: Notifications.AndroidNotificationPriority.HIGH,
        },
        trigger: null, // Show immediately
      });
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  };

  // Poll webhook for suggestions
  const pollWebhook = async () => {
    try {
      const response = await fetch(WEBHOOK_URL, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error('Failed to fetch suggestions');
      }

      const data = await response.json();
      
      // Check if data has the expected structure
      if (data.output && data.output.notification) {
        console.log('Received suggestion:', data.output);
        
        // Send notification
        await sendNotification(data.output.notification);
        
        // Update state
        setSuggestions(data.output);
        
        return data.output;
      }
      
      return null;
    } catch (error) {
      console.error('Error polling webhook:', error);
      return null;
    }
  };

  // Start listening
  const startListening = async () => {
    const hasPermission = await requestPermissions();
    if (!hasPermission) {
      console.log('Notification permission denied');
      return;
    }

    setIsListening(true);
    console.log('Started listening for suggestions...');

    // Initial poll
    await pollWebhook();

    // Set up polling interval
    const intervalId = setInterval(async () => {
      if (isListening) {
        await pollWebhook();
      }
    }, POLLING_INTERVAL);

    return () => {
      clearInterval(intervalId);
      setIsListening(false);
    };
  };

  // Stop listening
  const stopListening = () => {
    setIsListening(false);
    console.log('Stopped listening for suggestions');
  };

  // Clear suggestions
  const clearSuggestions = () => {
    setSuggestions(null);
  };

  return {
    suggestions,
    isListening,
    startListening,
    stopListening,
    clearSuggestions,
  };
};

