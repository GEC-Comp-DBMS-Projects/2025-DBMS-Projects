import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Image,
  StatusBar,
  ActivityIndicator,
  Platform,
  Alert,
  Modal,
  TextInput,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { auth, db } from '../firebase';
import { doc, setDoc, getDoc, collection, serverTimestamp } from 'firebase/firestore';
import * as Notifications from 'expo-notifications';
import * as Location from 'expo-location';
import { Ionicons, MaterialIcons, FontAwesome5, MaterialCommunityIcons } from '@expo/vector-icons';
import { getPriceAlerts } from '../utils/priceAlerts';

// Configure how notifications should be displayed
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: false,
  }),
});

/**
 * Smart Itinerary Screen
 * 
 * This screen uses TWO different webhooks:
 * 1. ITINERARY CREATION: https://n8n.srv1034714.hstgr.cloud/webhook/dd43dd17-772e-4f1e-9de2-09ed42e5df34
 *    - Used for initial itinerary generation
 *    - Returns full day-by-day itinerary with activities
 * 
 * 2. SUGGESTIONS: https://n8n.srv1034714.hstgr.cloud/webhook/suggestions-endpoint
 *    - Used for real-time suggestions AFTER itinerary is created
 *    - Returns suggestions based on current location/time
 *    - TODO: Replace with your actual suggestions webhook URL
 */

// Sample API response structure
const sampleApiResponse = [
  {
    output: {
      "Day 1": [
        {
          place: "Padaria Prazeres, Panjim",
          description: "Start your day with freshly baked goods and a cozy vibe at this Portuguese-inspired bakery.",
          type: "food",
          time: "8:00 AM",
          duration: "1 hr",
          cost: 400,
          distanceFromPrev: 0
        },
        {
          place: "Fontainhas (Latin Quarter) Exploration",
          description: "Wander through the vibrant, colorful streets of Goa's old Latin Quarter. Hidden Gem.",
          type: "activity",
          time: "9:30 AM",
          duration: "2 hrs",
          cost: 0,
          distanceFromPrev: 1
        },
        {
          place: "Kokni Kanteen Goa, Panjim",
          description: "Savor authentic Goan local food in a traditional setting. Known for delicious seafood.",
          type: "food",
          time: "1:30 PM",
          duration: "1.5 hrs",
          cost: 800,
          distanceFromPrev: 1.5
        },
        {
          place: "Cafe Bhonsle, Panjim",
          description: "Experience an old-school classic for Goan snacks and refreshing tea or coffee.",
          type: "food",
          time: "4:00 PM",
          duration: "1 hr",
          cost: 300,
          distanceFromPrev: 0.8
        },
        {
          place: "Miramar Beach Sunset",
          description: "Enjoy a quiet sunset walk and find a peaceful spot to watch the sun dip below the horizon.",
          type: "activity",
          time: "5:30 PM",
          duration: "1.5 hrs",
          cost: 0,
          distanceFromPrev: 2
        },
        {
          place: "Viva Panjim, Fontainhas",
          description: "Dine in a charming heritage home, known for delectable local Goan cuisine.",
          type: "food",
          time: "8:00 PM",
          duration: "1.5 hrs",
          cost: 900,
          distanceFromPrev: 2.5
        }
      ],
      "Day 2": [
        {
          place: "Perfect Cup, Panjim",
          description: "A highly-rated cafe known for its breakfast options, perfect for an early start.",
          type: "food",
          time: "8:00 AM",
          duration: "1 hr",
          cost: 450,
          distanceFromPrev: 0
        },
        {
          place: "Divar Island Exploration by Bike",
          description: "Take a ferry to Divar Island. Explore picturesque villages and old churches by bike. Hidden Gem.",
          type: "activity",
          time: "9:30 AM",
          duration: "3 hrs",
          cost: 50,
          distanceFromPrev: 8
        },
        {
          place: "Dr. Salim Ali Bird Sanctuary",
          description: "Visit this tranquil mangrove habitat, home to various bird species.",
          type: "activity",
          time: "3:00 PM",
          duration: "2 hrs",
          cost: 100,
          distanceFromPrev: 7
        },
        {
          place: "Mum's Kitchen, Panjim",
          description: "Indulge in traditional Goan cuisine prepared with authentic recipes.",
          type: "food",
          time: "8:30 PM",
          duration: "1.5 hrs",
          cost: 1000,
          distanceFromPrev: 5
        }
      ],
      "Day 3": [
        {
          place: "BLD, Panjim",
          description: "Well-regarded spot for a hearty breakfast to kickstart your day.",
          type: "food",
          time: "8:00 AM",
          duration: "1 hr",
          cost: 400,
          distanceFromPrev: 0
        },
        {
          place: "Our Lady of the Immaculate Conception Church",
          description: "Visit this iconic white church in Panjim, a beautiful architectural marvel.",
          type: "activity",
          time: "9:30 AM",
          duration: "1 hr",
          cost: 0,
          distanceFromPrev: 1
        },
        {
          place: "Reis Magos Fort",
          description: "Explore this historic fort offering splendid views. Less crowded. Hidden Gem.",
          type: "activity",
          time: "11:00 AM",
          duration: "1.5 hrs",
          cost: 50,
          distanceFromPrev: 7
        },
        {
          place: "The Black Sheep Bistro, Panjim",
          description: "Enjoy contemporary European dining with fresh, local ingredients.",
          type: "food",
          time: "8:00 PM",
          duration: "2 hrs",
          cost: 1200,
          distanceFromPrev: 9
        }
      ],
      "Day 4": [
        {
          place: "Kayaking in Mandovi River Backwaters",
          description: "Experience kayaking through serene backwaters of Mandovi River.",
          type: "activity",
          time: "9:30 AM",
          duration: "2.5 hrs",
          cost: 1000,
          distanceFromPrev: 15
        },
        {
          place: "Explore Panjim's Graffiti Art",
          description: "Treasure hunt for vibrant street art scattered across Panjim. Hidden Gem.",
          type: "activity",
          time: "12:30 PM",
          duration: "1.5 hrs",
          cost: 0,
          distanceFromPrev: 8
        },
        {
          place: "Dias Beach Relaxation",
          description: "Secluded and quiet spot perfect for relaxing by the sea. Hidden Gem.",
          type: "activity",
          time: "5:30 PM",
          duration: "1.5 hrs",
          cost: 0,
          distanceFromPrev: 6
        }
      ]
    }
  }
];

// Helper function to transform API response to component format
const transformApiData = (apiResponse: any) => {
  // Handle both array format and direct object format
  const outputData = Array.isArray(apiResponse) ? apiResponse[0].output : apiResponse.output;
  
  if (!outputData) {
    console.error('Invalid API response format:', apiResponse);
    throw new Error('Invalid data format');
  }
  
  // Get day keys and sort them properly (Day 1, Day 2, etc.)
  const dayKeys = Object.keys(outputData).sort((a, b) => {
    const numA = parseInt(a.replace('Day ', ''));
    const numB = parseInt(b.replace('Day ', ''));
    return numA - numB;
  });
  
  return {
    title: 'Goa Trip',
    totalDays: dayKeys.length,
    days: dayKeys.map((dayKey, index) => ({
      day: index + 1,
      dayName: dayKey,
      activities: outputData[dayKey].map((activity: any, actIndex: number) => {
        const time = activity.time || '12:00 PM';
        const period = getTimePeriod(time);
        
        return {
          id: `day${index + 1}_${actIndex}`,
          time: time,
          period: period,
          title: activity.place || 'Unknown Place',
          place: activity.place || 'Unknown Place', // Keep place field for webhook requests
          description: activity.description || '',
          duration: activity.duration || '1 hr',
          price: activity.cost === 0 ? 'Free' : `₹${activity.cost}`,
          category: activity.type === 'food' ? 'Food' : 'Activity',
          image: getImageForType(activity.type, activity.place),
          isHiddenGem: (activity.description || '').includes('Hidden Gem'),
          distance: activity.distanceFromPrev || 0,
          isDone: false // Initialize all activities as not done
        };
      })
    }))
  };
};

// Helper to determine time period
const getTimePeriod = (time: string) => {
  try {
    const hour = parseInt(time.split(':')[0]);
    const isPM = time.toUpperCase().includes('PM');
    const isAM = time.toUpperCase().includes('AM');
    
    let hour24 = hour;
    if (isPM && hour !== 12) {
      hour24 = hour + 12;
    } else if (isAM && hour === 12) {
      hour24 = 0;
    }
    
    if (hour24 >= 5 && hour24 < 12) return 'Morning';
    if (hour24 >= 12 && hour24 < 17) return 'Afternoon';
    return 'Evening';
  } catch (error) {
    console.error('Error parsing time:', time, error);
    return 'Morning';
  }
};

// Helper to get image based on type
const getImageForType = (type: string, place: string) => {
  const images: any = {
    food: [
      'https://images.unsplash.com/photo-1533920379810-6bedac961555?w=400',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
    ],
    activity: place.toLowerCase().includes('beach') || place.toLowerCase().includes('sunset')
      ? 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400'
      : place.toLowerCase().includes('fort') || place.toLowerCase().includes('church')
      ? 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=400'
      : place.toLowerCase().includes('kayak') || place.toLowerCase().includes('island')
      ? 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400'
      : 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400'
  };
  
  if (type === 'food') {
    return images.food[Math.floor(Math.random() * images.food.length)];
  }
  return images.activity;
};

// Transform the sample data
const dummyItinerary = transformApiData(sampleApiResponse);

// Time period colors
const periodColors: any = {
  Morning: { bg: 'bg-yellow-50', text: 'text-yellow-700', iconName: 'sunny', iconSet: 'Ionicons' },
  Afternoon: { bg: 'bg-orange-50', text: 'text-orange-700', iconName: 'sunny', iconSet: 'Ionicons' },
  Evening: { bg: 'bg-purple-50', text: 'text-purple-700', iconName: 'moon', iconSet: 'Ionicons' },
};

// Category colors
const categoryColors: any = {
  Food: { bg: 'bg-red-500', iconName: 'restaurant', iconSet: 'Ionicons' },
  Activity: { bg: 'bg-blue-500', iconName: 'bicycle', iconSet: 'Ionicons' },
  Heritage: { bg: 'bg-amber-600', iconName: 'landmark', iconSet: 'FontAwesome5' },
  Adventure: { bg: 'bg-green-500', iconName: 'terrain', iconSet: 'MaterialIcons' },
  Beach: { bg: 'bg-blue-500', iconName: 'beach', iconSet: 'MaterialIcons' },
  Nature: { bg: 'bg-emerald-500', iconName: 'leaf', iconSet: 'Ionicons' },
  Experience: { bg: 'bg-purple-500', iconName: 'theater', iconSet: 'MaterialCommunityIcons' },
  Wellness: { bg: 'bg-pink-500', iconName: 'spa', iconSet: 'MaterialIcons' },
};

// Helper to render icon based on iconSet
const renderIcon = (iconData: any, size: number, color: string) => {
  if (!iconData) return null;
  const { iconSet, iconName } = iconData;
  
  switch (iconSet) {
    case 'Ionicons':
      return <Ionicons name={iconName} size={size} color={color} />;
    case 'MaterialIcons':
      return <MaterialIcons name={iconName} size={size} color={color} />;
    case 'FontAwesome5':
      return <FontAwesome5 name={iconName} size={size} color={color} />;
    case 'MaterialCommunityIcons':
      return <MaterialCommunityIcons name={iconName} size={size} color={color} />;
    default:
      return null;
  }
};

function SmartItinerary() {
  const navigation = useNavigation<any>();
  const [selectedDay, setSelectedDay] = useState(1);
  const [hasItinerary, setHasItinerary] = useState(false); // Start with empty state
  const [isLoading, setIsLoading] = useState(false);
  const [isCheckingFirebase, setIsCheckingFirebase] = useState(true); // Check Firebase on mount
  const [itineraryData, setItineraryData] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);
  const [isFetchingSuggestions, setIsFetchingSuggestions] = useState(false);
  const [expandedPriceAlert, setExpandedPriceAlert] = useState<string | null>(null);
  
  // Preferences Modal State
  const [showPreferencesModal, setShowPreferencesModal] = useState(false);
  const [isFetchingLocation, setIsFetchingLocation] = useState(false);
  const [currentLocation, setCurrentLocation] = useState<string>('');
  const [locationCoords, setLocationCoords] = useState<{latitude: number, longitude: number} | null>(null);
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [totalDays, setTotalDays] = useState('3');
  const [budget, setBudget] = useState('8000');
  const [travelers, setTravelers] = useState('2');
  const [interests, setInterests] = useState<string[]>([]);
  const [travelPace, setTravelPace] = useState('moderate');
  const [travelMode, setTravelMode] = useState('bike');
  const [avoidCrowds, setAvoidCrowds] = useState(true);

  const currentDayData = itineraryData?.days.find((d: any) => d.day === selectedDay);

  // Request notification permissions on mount
  useEffect(() => {
    registerForPushNotificationsAsync();
  }, []);

  // Fetch itinerary from Firebase on mount
  useEffect(() => {
    loadItineraryFromFirebase();
  }, []);

  // Listen for notification taps
  useEffect(() => {
    const subscription = Notifications.addNotificationResponseReceivedListener(response => {
      const suggestionData = response.notification.request.content.data.suggestionData;
      if (suggestionData) {
        navigation.navigate('suggestions', { suggestionData });
      }
    });

    return () => subscription.remove();
  }, [navigation]);

  // Debug modal state
  useEffect(() => {
    console.log('showPreferencesModal changed to:', showPreferencesModal);
  }, [showPreferencesModal]);

  // Register for push notifications
  async function registerForPushNotificationsAsync() {
    let token;
    if (Platform.OS === 'android') {
      await Notifications.setNotificationChannelAsync('default', {
        name: 'default',
        importance: Notifications.AndroidImportance.MAX,
        vibrationPattern: [0, 250, 250, 250],
        lightColor: '#FF231F7C',
      });
    }

    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }
    if (finalStatus !== 'granted') {
      console.log('Failed to get push token for push notification!');
      return;
    }
  }

  // Load itinerary from Firebase
  const loadItineraryFromFirebase = async () => {
    setIsCheckingFirebase(true);
    
    try {
      const user = auth.currentUser;
      if (!user) {
        console.log('No user logged in');
        setIsCheckingFirebase(false);
        return;
      }

      const itineraryRef = doc(db, 'users', user.uid, 'itinerary', 'current');
      const itinerarySnap = await getDoc(itineraryRef);

      if (itinerarySnap.exists()) {
        const data = itinerarySnap.data();
        console.log('Loaded itinerary from Firebase:', data);
        setItineraryData(data.itinerary);
        setHasItinerary(true);
      } else {
        console.log('No itinerary found in Firebase');
        setHasItinerary(false);
      }
    } catch (err) {
      console.error('Error loading itinerary from Firebase:', err);
      setError('Failed to load itinerary. Please try again.');
    } finally {
      setIsCheckingFirebase(false);
    }
  };

  // Save itinerary to Firebase
  const saveItineraryToFirebase = async (itinerary: any) => {
    try {
      const user = auth.currentUser;
      if (!user) {
        console.log('No user logged in, cannot save itinerary');
        return;
      }

      const itineraryRef = doc(db, 'users', user.uid, 'itinerary', 'current');
      await setDoc(itineraryRef, {
        itinerary,
        createdAt: serverTimestamp(),
        updatedAt: serverTimestamp(),
        userId: user.uid,
      });

      console.log('Itinerary saved to Firebase successfully');
    } catch (err) {
      console.error('Error saving itinerary to Firebase:', err);
      throw err;
    }
  };

  // Delete itinerary from Firebase
  const deleteItineraryFromFirebase = async () => {
    try {
      const user = auth.currentUser;
      if (!user) {
        console.log('No user logged in');
        return;
      }

      const itineraryRef = doc(db, 'users', user.uid, 'itinerary', 'current');
      await setDoc(itineraryRef, {
        itinerary: null,
        deletedAt: serverTimestamp(),
        userId: user.uid,
      });

      console.log('Itinerary deleted from Firebase');
      setItineraryData(null);
      setHasItinerary(false);
    } catch (err) {
      console.error('Error deleting itinerary from Firebase:', err);
      setError('Failed to delete itinerary. Please try again.');
    }
  };

  // Handle adding a suggestion to the itinerary
  const handleAddSuggestionToItinerary = async (suggestion: any, day: number, position: number) => {
    try {
      if (!itineraryData) return;

      console.log(`Adding suggestion to Day ${day} at position ${position}`, suggestion);

      // Deep clone the itinerary data
      const updatedItinerary = JSON.parse(JSON.stringify(itineraryData));
      const dayData = updatedItinerary.days.find((d: any) => d.day === day);
      
      if (!dayData) {
        throw new Error(`Day ${day} not found`);
      }

      // Get the activities for time calculation
      const activities = dayData.activities;
      let calculatedTime = '9:00 AM'; // Default start time
      
      // Calculate time based on position
      if (position > 0 && position < activities.length) {
        // Insert between two activities - calculate middle time
        const prevActivity = activities[position - 1];
        const nextActivity = activities[position];
        calculatedTime = calculateMiddleTime(prevActivity.time, nextActivity.time);
      } else if (position === 0 && activities.length > 0) {
        // Insert at beginning - 30 mins before first activity
        calculatedTime = subtractMinutes(activities[0].time, 30);
      } else if (position === activities.length && activities.length > 0) {
        // Insert at end - add duration to last activity time
        const lastActivity = activities[activities.length - 1];
        calculatedTime = addDuration(lastActivity.time, lastActivity.duration);
      }

      // Transform suggestion to activity format
      const newActivity = {
        id: `activity-${Date.now()}`,
        place: suggestion.place,
        title: suggestion.place, // Add title field for display
        description: suggestion.description,
        category: suggestion.type === 'food' ? 'Food' : 'Activity',
        time: calculatedTime,
        duration: suggestion.duration || '1 hr',
        cost: suggestion.cost !== undefined ? `₹${suggestion.cost}` : '₹0',
        price: suggestion.cost !== undefined ? `₹${suggestion.cost}` : '₹0', // Add price field for display
        distance: suggestion.distanceFromCurrent || 0,
        period: getTimePeriodFromTime(calculatedTime),
        image: getImageForType(suggestion.type, suggestion.place),
        isHiddenGem: suggestion.tags?.some((tag: string) => 
          tag.toLowerCase().includes('hidden') || tag.toLowerCase().includes('gem')
        ) || false,
        isDone: false, // Add done status field
      };

      // Insert the new activity
      activities.splice(position, 0, newActivity);

      // Update itinerary state
      setItineraryData(updatedItinerary);

      // Save to Firebase
      await saveItineraryToFirebase(updatedItinerary);

      console.log('Suggestion added successfully!');
      return true;
    } catch (err) {
      console.error('Error adding suggestion to itinerary:', err);
      setError('Failed to add suggestion. Please try again.');
      return false;
    }
  };

  // Helper: Calculate middle time between two times
  const calculateMiddleTime = (time1: string, time2: string): string => {
    try {
      const minutes1 = parseTimeToMinutes(time1);
      const minutes2 = parseTimeToMinutes(time2);
      const middleMinutes = Math.floor((minutes1 + minutes2) / 2);
      return formatMinutesToTime(middleMinutes);
    } catch (err) {
      return '12:00 PM';
    }
  };

  // Helper: Convert time string to minutes since midnight
  const parseTimeToMinutes = (timeStr: string): number => {
    const match = timeStr.match(/(\d+):(\d+)\s*(AM|PM)/i);
    if (!match) return 540; // Default 9:00 AM
    
    let hours = parseInt(match[1]);
    const minutes = parseInt(match[2]);
    const period = match[3].toUpperCase();
    
    if (period === 'PM' && hours !== 12) hours += 12;
    if (period === 'AM' && hours === 12) hours = 0;
    
    return hours * 60 + minutes;
  };

  // Helper: Convert minutes to time string
  const formatMinutesToTime = (totalMinutes: number): string => {
    let hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    const period = hours >= 12 ? 'PM' : 'AM';
    
    if (hours > 12) hours -= 12;
    if (hours === 0) hours = 12;
    
    return `${hours}:${minutes.toString().padStart(2, '0')} ${period}`;
  };

  // Helper: Subtract minutes from time
  const subtractMinutes = (timeStr: string, minutesToSubtract: number): string => {
    const totalMinutes = parseTimeToMinutes(timeStr);
    const newMinutes = Math.max(0, totalMinutes - minutesToSubtract);
    return formatMinutesToTime(newMinutes);
  };

  // Helper: Add duration to time
  const addDuration = (timeStr: string, duration: string): string => {
    const totalMinutes = parseTimeToMinutes(timeStr);
    const durationMatch = duration.match(/(\d+(?:\.\d+)?)/);
    const durationHours = durationMatch ? parseFloat(durationMatch[1]) : 1;
    const newMinutes = totalMinutes + Math.floor(durationHours * 60);
    return formatMinutesToTime(newMinutes);
  };

  // Helper: Get time period from time string
  const getTimePeriodFromTime = (timeStr: string): string => {
    const minutes = parseTimeToMinutes(timeStr);
    if (minutes < 720) return 'Morning'; // Before 12 PM
    if (minutes < 1020) return 'Afternoon'; // Before 5 PM
    return 'Evening';
  };

  // Toggle activity done status
  const toggleActivityDone = async (day: number, activityIndex: number) => {
    try {
      if (!itineraryData) return;

      console.log(`Toggling done status for Day ${day}, position ${activityIndex}`);

      // Deep clone the itinerary data
      const updatedItinerary = JSON.parse(JSON.stringify(itineraryData));
      const dayData = updatedItinerary.days.find((d: any) => d.day === day);
      
      if (!dayData) {
        throw new Error(`Day ${day} not found`);
      }

      const activity = dayData.activities[activityIndex];
      if (!activity) {
        throw new Error(`Activity at position ${activityIndex} not found`);
      }

      // Toggle the done status
      activity.isDone = !activity.isDone;

      // Update itinerary state
      setItineraryData(updatedItinerary);

      // Save to Firebase
      await saveItineraryToFirebase(updatedItinerary);

      console.log(`Activity marked as ${activity.isDone ? 'done' : 'not done'}`);
    } catch (err) {
      console.error('Error toggling activity status:', err);
      Alert.alert('Error', 'Failed to update activity status. Please try again.');
    }
  };

  // Delete activity from itinerary
  const handleDeleteActivity = (day: number, activityIndex: number) => {
    if (!itineraryData) return;

    // Find the activity to show in confirmation
    const dayData = itineraryData.days.find((d: any) => d.day === day);
    if (!dayData) return;
    
    const activity = dayData.activities[activityIndex];
    if (!activity) return;

    // Show confirmation dialog
    Alert.alert(
      'Delete Activity',
      `Are you sure you want to delete "${activity.title || activity.place}"?\n\nThis action cannot be undone.`,
      [
        {
          text: 'Cancel',
          style: 'cancel',
        },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              console.log(`Deleting activity at Day ${day}, position ${activityIndex}`);

              // Deep clone the itinerary data
              const updatedItinerary = JSON.parse(JSON.stringify(itineraryData));
              const updatedDayData = updatedItinerary.days.find((d: any) => d.day === day);
              
              if (!updatedDayData) {
                throw new Error(`Day ${day} not found`);
              }

              // Remove the activity
              updatedDayData.activities.splice(activityIndex, 1);

              // Update itinerary state
              setItineraryData(updatedItinerary);

              // Save to Firebase
              await saveItineraryToFirebase(updatedItinerary);

              console.log('Activity deleted successfully!');
            } catch (err) {
              console.error('Error deleting activity:', err);
              Alert.alert('Error', 'Failed to delete activity. Please try again.');
            }
          },
        },
      ]
    );
  };

  // Helper: Get current time in 12-hour format
  const getCurrentTime = () => {
    const now = new Date();
    let hours = now.getHours();
    const minutes = now.getMinutes();
    const period = hours >= 12 ? 'PM' : 'AM';
    
    hours = hours % 12 || 12;
    const minutesStr = minutes.toString().padStart(2, '0');
    
    return `${hours}:${minutesStr} ${period}`;
  };

  // Helper: Find latest done activity and next undone activity
  const getActivityContext = () => {
    if (!itineraryData) return null;

    let latestDoneActivity = null;
    let nextUndoneActivity = null;
    let foundLatestDone = false;

    // Iterate through all days and activities
    for (const day of itineraryData.days) {
      for (const activity of day.activities) {
        if (activity.isDone) {
          latestDoneActivity = activity;
          foundLatestDone = true;
        } else if (foundLatestDone && !nextUndoneActivity) {
          // Found the next undone activity after the latest done one
          nextUndoneActivity = activity;
          break;
        } else if (!foundLatestDone && !nextUndoneActivity) {
          // If no done activities yet, use the first undone as next
          nextUndoneActivity = activity;
        }
      }
      if (nextUndoneActivity) break;
    }

    return { latestDoneActivity, nextUndoneActivity };
  };

  // Fetch suggestions from separate webhook (for real-time suggestions)
  const fetchSuggestions = async () => {
    setIsFetchingSuggestions(true);
    
    try {
      // This is a DIFFERENT endpoint from the itinerary creation webhook
      const SUGGESTIONS_WEBHOOK_URL = 'https://n8n.srv1034714.hstgr.cloud/webhook/dd43dd17-772e-4f1e-9de2-09ed42e5df34';
      
      // Get activity context
      const context = getActivityContext();
      
      // Build request body
      const requestBody = {
        currentLocation: {
          name: context?.latestDoneActivity?.title || 'Starting Location',
          place: context?.latestDoneActivity?.place || 'farmagudi, goa'
        },
        // currentTime: getCurrentTime(),
        currentTime: "10:00 AM",
        nextPlannedPlace: {
          name: context?.nextUndoneActivity?.title || 'No planned activity',
          type: context?.nextUndoneActivity?.category?.toLowerCase() || 'activity'
        },
        userPreferences: {
          interests: ['beaches', 'culture', 'food'],
          energyLevel: 'medium',
          foodPreference: 'non-veg',
          budget: 'moderate'
        },
        weather: 'sunny',
        lastPlaceFeedback: context?.latestDoneActivity ? 'loved' : 'neutral',
        travelMode: 'walk'
      };

      console.log('Fetching suggestions from:', SUGGESTIONS_WEBHOOK_URL);
      console.log('Request body:', JSON.stringify(requestBody, null, 2));
      
      const response = await fetch(SUGGESTIONS_WEBHOOK_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      });

      if (!response.ok) {
        throw new Error('Failed to fetch suggestions');
      }

      const data = await response.json();
      console.log('Received suggestion data:', data);
      
      if (data.output) {
        const suggestionData = data.output;
        
        // Send a local notification with the notification field
        await Notifications.scheduleNotificationAsync({
          content: {
            title: '🎯 New Smart Suggestion!',
            body: suggestionData.notification || 'We have a new suggestion for you!',
            data: { suggestionData },
            sound: true,
          },
          trigger: null, // Show immediately
        });

        // Also navigate directly to the suggestions screen with current itinerary
        navigation.navigate('suggestions', { 
          suggestionData,
          currentItinerary: itineraryData,
          onAddToItinerary: handleAddSuggestionToItinerary,
        });
      }
    } catch (err) {
      console.error('Error fetching suggestions:', err);
      setError('Failed to fetch suggestions. Please try again.');
    } finally {
      setIsFetchingSuggestions(false);
    }
  };

  // Get current location
  const getCurrentLocation = async () => {
    setIsFetchingLocation(true);
    try {
      console.log('Requesting location permissions...');
      const { status } = await Location.requestForegroundPermissionsAsync();
      console.log('Permission status:', status);
      
      if (status !== 'granted') {
        Alert.alert('Permission Denied', 'Location permission is required to generate itinerary. You can manually enter your location or enable permissions in settings.');
        setIsFetchingLocation(false);
        return false;
      }

      console.log('Getting current position...');
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.Balanced,
      });
      console.log('Location obtained:', location.coords);

      console.log('Reverse geocoding...');
      const reverseGeocode = await Location.reverseGeocodeAsync({
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
      });
      console.log('Reverse geocode result:', reverseGeocode);

      if (reverseGeocode.length > 0) {
        const address = reverseGeocode[0];
        const locationString = [
          address.city || address.subregion,
          address.region || address.country,
        ]
          .filter(Boolean)
          .join(', ');
        
        console.log('Location string:', locationString);
        setCurrentLocation(locationString || 'Unknown Location');
        setLocationCoords({
          latitude: location.coords.latitude,
          longitude: location.coords.longitude
        });
      } else {
        // If reverse geocoding fails, still use the coordinates
        setCurrentLocation('Your Location');
        setLocationCoords({
          latitude: location.coords.latitude,
          longitude: location.coords.longitude
        });
      }
      setIsFetchingLocation(false);
      return true;
    } catch (error) {
      console.error('Error getting location:', error);
      setIsFetchingLocation(false);
      Alert.alert(
        'Location Error', 
        'Failed to get your location. Please check your location settings and try again.',
        [
          { text: 'Cancel', style: 'cancel' },
          { text: 'Retry', onPress: () => getCurrentLocation() }
        ]
      );
      return false;
    }
  };

  // Function to fetch itinerary from webhook (initial creation)
  const fetchItinerary = async () => {
    setIsLoading(true);
    setError(null);
    setShowPreferencesModal(false);
    
    try {
      // Prepare request body
      const requestBody = {
        userId: auth.currentUser?.uid || 'user_001',
        currentLocation: {
          latitude: locationCoords?.latitude,
          longitude: locationCoords?.longitude,
          placeName: currentLocation
       
        },
      
         
          totalDays: parseInt(totalDays),
      
        preferences: {
          interests: interests,
          travelPace: travelPace,
          travelMode: travelMode,
          timePreference: 'early_riser'
        },
        budget: {
          total: parseInt(budget),
          currency: 'INR'
        },
        groupInfo: {
          travellers: parseInt(travelers),
          type: 'friends'
        },
        constraints: {
          maxTravelPerDayKm: 60,
          avoidCrowdedPlaces: avoidCrowds
        }
      };

      console.log('Sending itinerary request:', requestBody);

      // POST request to webhook
      const response = await fetch('https://n8n.srv1034714.hstgr.cloud/webhook/bdc363bd-2762-444f-a02a-537fcef7ba83', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      });

      if (!response.ok) {
        throw new Error('Failed to fetch itinerary');
      }

      const data = await response.json();
      console.log('Received itinerary data:', data);
      
      // Transform the API data
      const transformedData = transformApiData(data);
      console.log('Transformed itinerary data:', transformedData);
      console.log('First activity:', transformedData.days[0]?.activities[0]);
      
      // Save to Firebase
      await saveItineraryToFirebase(transformedData);
      
      setItineraryData(transformedData);
      setHasItinerary(true);
    } catch (err) {
      console.error('Error fetching itinerary:', err);
      setError('Failed to generate itinerary. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  // Open preferences modal and get location
  const openPreferencesModal = async () => {
    console.log('openPreferencesModal called');
    // Show modal immediately
    console.log('Setting showPreferencesModal to true');
    setShowPreferencesModal(true);
    console.log('Modal state should be true now');
    // Then fetch location in the background
    await getCurrentLocation();
  };

  // Loading State - Checking Firebase
  if (isCheckingFirebase) {
    return (
      <View className="flex-1 bg-gray-50 items-center justify-center">
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Loading your itinerary...</Text>
      </View>
    );
  }

  // Empty State - No Itinerary Yet
  if (!hasItinerary || !itineraryData) {
    return (
      <View className="flex-1 bg-gray-50">
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        
        <ScrollView className="flex-1">
          {/* Header */}
          <View className="bg-white px-5 pt-5 pb-3 shadow-sm">
            <View className="flex-row justify-between items-center mb-5">
              <View>
                <View className="flex-row items-center">
                 <Image 
                  source={require('../assets/tourzy-logo.png')}
                  style={{ width: 100, height: 20 }}
                />
                </View>
               
              </View>
              {/* <View className="flex-row gap-3 items-center">
                <TouchableOpacity className="w-10 h-10 bg-gray-100 rounded-full items-center justify-center">
                  <Text className="text-lg">🔔</Text>
                </TouchableOpacity>
                <TouchableOpacity 
                  onPress={() => {auth.signOut(); navigation.navigate('SignIn');}}
                  className="w-10 h-10 bg-blue-500 rounded-full items-center justify-center shadow-md"
                >
                  <Text className="text-base">👤</Text>
                </TouchableOpacity>
              </View> */}
            </View>
          </View>

          {/* Empty State */}
          <View className="flex-1 px-5 py-12 items-center justify-center">
            <View className="items-center">
              {/* Illustration */}
              <View className="w-40 h-40 bg-blue-100 rounded-full items-center justify-center mb-6 shadow-lg">
                <Text className="text-7xl">🗺️</Text>
              </View>
              
              <Text className="text-gray-900 text-2xl font-bold mb-3 text-center">
                Plan Your Perfect Trip
              </Text>
              <Text className="text-gray-600 text-sm text-center mb-8 px-6 leading-6">
                Create a personalized itinerary based on your location and preferences. 
                We'll suggest the best places to visit, eat, and explore!
              </Text>
              
              {/* Features */}
              <View className="w-full mb-8 flex-row">
                <View className="bg-white rounded-2xl p-4 mb-3 shadow-sm flex-row items-center">
                  <View className="w-12 h-12 bg-blue-100 rounded-full items-center justify-center mr-4">
                    <Ionicons name="location" size={24} color="#3b82f6" />
                  </View>
                  <View className="flex-1">
                    <Text className="text-gray-900 font-bold text-sm mb-1">Location Based</Text>
                    <Text className="text-gray-600 text-xs">Places near you and easy to reach</Text>
                  </View>
                </View>
                
                <View className="bg-white rounded-2xl p-4 mb-3 shadow-sm flex-row items-center">
                  <View className="w-12 h-12 bg-purple-100 rounded-full items-center justify-center mr-4">
                    <Ionicons name="time" size={24} color="#a855f7" />
                  </View>
                  <View className="flex-1">
                    <Text className="text-gray-900 font-bold text-sm mb-1">Time Optimized</Text>
                    <Text className="text-gray-600 text-xs">Perfect timing for each activity</Text>
                  </View>
                </View>
                
                <View className="bg-white rounded-2xl p-4 shadow-sm flex-row items-center">
                  <View className="w-12 h-12 bg-green-100 rounded-full items-center justify-center mr-4">
                    <Ionicons name="ribbon" size={24} color="#16a34a" />
                  </View>
                  <View className="flex-1">
                    <Text className="text-gray-900 font-bold text-sm mb-1">Personalized</Text>
                    <Text className="text-gray-600 text-xs">Based on your preferences</Text>
                  </View>
                </View>
              </View>
              
              {/* Error Message */}
              {error && (
                <View className="bg-red-50 border border-red-200 rounded-2xl p-4 mb-4">
                  <Text className="text-red-800 text-sm text-center">{error}</Text>
                </View>
              )}

              {/* CTA Button */}
              <TouchableOpacity 
                onPress={openPreferencesModal}
                disabled={isLoading}
                className="w-full"
                activeOpacity={0.8}
              >
                <LinearGradient
                  colors={isLoading ? ['#9ca3af', '#6b7280'] : ['#3b82f6', '#8b5cf6']}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 0 }}
                  style={{ borderRadius: 16, padding: 18, alignItems: 'center', shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 8, elevation: 5, flexDirection: 'row', justifyContent: 'center' }}
                >
                  {isLoading ? (
                    <ActivityIndicator color="white" style={{ marginRight: 8 }} />
                  ) : (
                    <Ionicons name="rocket" size={18} color="#fff" style={{ marginRight: 8 }} />
                  )}
                  <Text className="text-white text-base font-bold">
                    {isLoading ? 'Generating Itinerary...' : 'Create My Itinerary'}
                  </Text>
                </LinearGradient>
              </TouchableOpacity>
            </View>
          </View>
        </ScrollView>

        {/* Preferences Modal */}
        <Modal
          visible={showPreferencesModal}
          animationType="slide"
          transparent={true}
          onRequestClose={() => setShowPreferencesModal(false)}
        >
          <View style={{ flex: 1, backgroundColor: 'rgba(0, 0, 0, 0.5)', justifyContent: 'flex-end' }}>
            <View style={{ backgroundColor: '#fff', borderTopLeftRadius: 24, borderTopRightRadius: 24, maxHeight: '90%' }}>
              <ScrollView showsVerticalScrollIndicator={false}>
                <View className="p-6">
                  {/* Header */}
                  <View className="flex-row items-center justify-between mb-6">
                    <Text className="text-2xl font-bold text-gray-900">Plan Your Trip</Text>
                    <TouchableOpacity onPress={() => setShowPreferencesModal(false)}>
                      <Ionicons name="close-circle" size={28} color="#9ca3af" />
                    </TouchableOpacity>
                  </View>

                  {/* Current Location */}
                  <View className="mb-4">
                    <View className="flex-row items-center justify-between mb-2">
                      <Text className="text-sm font-semibold text-gray-700">
                        📍 Current Location
                      </Text>
                      {!isFetchingLocation && !currentLocation && (
                        <TouchableOpacity onPress={getCurrentLocation}>
                          <Text className="text-blue-500 text-xs font-semibold">Retry</Text>
                        </TouchableOpacity>
                      )}
                    </View>
                    {isFetchingLocation ? (
                      <View className="bg-blue-50 rounded-xl px-4 py-3 flex-row items-center">
                        <ActivityIndicator size="small" color="#3b82f6" style={{ marginRight: 8 }} />
                        <Text className="text-gray-600">Fetching your location...</Text>
                      </View>
                    ) : currentLocation ? (
                      <View className="bg-blue-50 rounded-xl px-4 py-3 flex-row items-center">
                        <Ionicons name="pin" size={18} color="#3b82f6" style={{ marginRight: 8 }} />
                        <Text className="text-gray-900">{currentLocation}</Text>
                      </View>
                    ) : (
                      <TextInput
                        value={currentLocation}
                        onChangeText={(text) => {
                          setCurrentLocation(text);
                          // Set default coordinates if manual entry
                          if (!locationCoords) {
                            setLocationCoords({ latitude: 15.2993, longitude: 74.1240 }); // Default Goa
                          }
                        }}
                        placeholder="Enter your location (e.g., Panjim, Goa)"
                        className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                      />
                    )}
                  </View>

                  {/* Trip Duration */}
                  <View className="mb-4">
                    <Text className="text-sm font-semibold text-gray-700 mb-2">Trip Duration (Days) *</Text>
                    <TextInput
                      value={totalDays}
                      onChangeText={setTotalDays}
                      placeholder="e.g., 3"
                      keyboardType="numeric"
                      className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                    />
                  </View>

                  {/* Budget */}
                  <View className="mb-4">
                    <Text className="text-sm font-semibold text-gray-700 mb-2">Budget (INR) *</Text>
                    <TextInput
                      value={budget}
                      onChangeText={setBudget}
                      placeholder="e.g., 8000"
                      keyboardType="numeric"
                      className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                    />
                  </View>

                  {/* Number of Travelers */}
                  <View className="mb-4">
                    <Text className="text-sm font-semibold text-gray-700 mb-2">Number of Travelers *</Text>
                    <TextInput
                      value={travelers}
                      onChangeText={setTravelers}
                      placeholder="e.g., 2"
                      keyboardType="numeric"
                      className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                    />
                  </View>

                  {/* Interests */}
                  <View className="mb-4">
                    <Text className="text-sm font-semibold text-gray-700 mb-2">Interests</Text>
                    <View className="flex-row flex-wrap gap-2">
                      {['beaches', 'local_food', 'hidden_gems', 'adventure', 'culture', 'nightlife'].map((interest) => (
                        <TouchableOpacity
                          key={interest}
                          onPress={() => {
                            if (interests.includes(interest)) {
                              setInterests(interests.filter(i => i !== interest));
                            } else {
                              setInterests([...interests, interest]);
                            }
                          }}
                          className={`rounded-full px-4 py-2 ${
                            interests.includes(interest) ? 'bg-blue-500' : 'bg-gray-200'
                          }`}
                        >
                          <Text className={`text-sm font-semibold ${
                            interests.includes(interest) ? 'text-white' : 'text-gray-700'
                          }`}>
                            {interest.replace('_', ' ')}
                          </Text>
                        </TouchableOpacity>
                      ))}
                    </View>
                  </View>

                  {/* Travel Pace */}
                  <View className="mb-4">
                    <Text className="text-sm font-semibold text-gray-700 mb-2">Travel Pace</Text>
                    <View className="flex-row gap-2">
                      {['slow', 'moderate', 'fast'].map((pace) => (
                        <TouchableOpacity
                          key={pace}
                          onPress={() => setTravelPace(pace)}
                          className={`flex-1 rounded-xl px-4 py-3 ${
                            travelPace === pace ? 'bg-blue-500' : 'bg-gray-200'
                          }`}
                        >
                          <Text className={`text-sm font-semibold text-center ${
                            travelPace === pace ? 'text-white' : 'text-gray-700'
                          }`}>
                            {pace}
                          </Text>
                        </TouchableOpacity>
                      ))}
                    </View>
                  </View>

                  {/* Travel Mode */}
                  <View className="mb-4">
                    <Text className="text-sm font-semibold text-gray-700 mb-2">Travel Mode</Text>
                    <View className="flex-row gap-2">
                      {['bike', 'car', 'public'].map((mode) => (
                        <TouchableOpacity
                          key={mode}
                          onPress={() => setTravelMode(mode)}
                          className={`flex-1 rounded-xl px-4 py-3 flex-row items-center justify-center ${
                            travelMode === mode ? 'bg-blue-500' : 'bg-gray-200'
                          }`}
                        >
                          <Ionicons 
                            name={mode === 'bike' ? 'bicycle' : mode === 'car' ? 'car' : 'bus'}
                            size={18}
                            color={travelMode === mode ? '#fff' : '#374151'}
                            style={{ marginRight: 4 }}
                          />
                          <Text className={`text-sm font-semibold ${
                            travelMode === mode ? 'text-white' : 'text-gray-700'
                          }`}>
                            {mode}
                          </Text>
                        </TouchableOpacity>
                      ))}
                    </View>
                  </View>

                  {/* Avoid Crowds */}
                  <View className="mb-6">
                    <TouchableOpacity
                      onPress={() => setAvoidCrowds(!avoidCrowds)}
                      className="flex-row items-center justify-between bg-gray-50 rounded-xl px-4 py-3"
                    >
                      <View className="flex-row items-center">
                        <Ionicons name="people-outline" size={20} color="#374151" style={{ marginRight: 8 }} />
                        <Text className="text-sm font-semibold text-gray-700">Avoid Crowded Places</Text>
                      </View>
                      <View className={`w-12 h-6 rounded-full ${avoidCrowds ? 'bg-blue-500' : 'bg-gray-300'}`}>
                        <View className={`w-6 h-6 rounded-full bg-white shadow ${avoidCrowds ? 'ml-6' : 'ml-0'}`} />
                      </View>
                    </TouchableOpacity>
                  </View>

                  {/* Generate Button */}
                  <TouchableOpacity 
                    onPress={fetchItinerary}
                    disabled={isLoading || isFetchingLocation || !totalDays || !budget || !travelers || !currentLocation}
                    className="w-full"
                  >
                    <LinearGradient
                      colors={(isLoading || isFetchingLocation || !totalDays || !budget || !travelers || !currentLocation) ? ['#9ca3af', '#6b7280'] : ['#3b82f6', '#8b5cf6']}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 0 }}
                      style={{ borderRadius: 16, padding: 18, alignItems: 'center', flexDirection: 'row', justifyContent: 'center' }}
                    >
                      {isLoading ? (
                        <>
                          <ActivityIndicator color="#fff" size="small" />
                          <Text className="text-white font-bold text-base ml-2">Generating...</Text>
                        </>
                      ) : isFetchingLocation ? (
                        <>
                          <ActivityIndicator color="#fff" size="small" />
                          <Text className="text-white font-bold text-base ml-2">Getting Location...</Text>
                        </>
                      ) : (
                        <>
                          <Ionicons name="sparkles" size={20} color="#fff" style={{ marginRight: 8 }} />
                          <Text className="text-white font-bold text-base">Generate Itinerary</Text>
                        </>
                      )}
                    </LinearGradient>
                  </TouchableOpacity>
                  
                  {!currentLocation && !isFetchingLocation && (
                    <Text className="text-gray-500 text-xs text-center mt-2">
                      Please enter your location or tap Retry to fetch automatically
                    </Text>
                  )}
                </View>
              </ScrollView>
            </View>
          </View>
        </Modal>
      </View>
    );
  }

  // Main Itinerary View
  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />
      
      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View className="bg-white px-5 pt-12 pb-5 shadow-sm">
          <View className="flex-row justify-between items-center mb-5">
            <TouchableOpacity onPress={() => navigation.goBack()}>
              <Ionicons name="arrow-back" size={24} color="#000" />
            </TouchableOpacity>
            <View className="flex-1 items-center">
              <Text className="text-lg font-bold text-gray-900">Smart Itinerary</Text>
            </View>
            <View className="flex-row items-center" style={{ gap: 8 }}>
              {itineraryData && (
                <TouchableOpacity 
                  onPress={fetchSuggestions}
                  disabled={isFetchingSuggestions}
                  className="w-10 h-10 bg-blue-500 rounded-full items-center justify-center shadow-md"
                >
                  <Ionicons 
                    name={isFetchingSuggestions ? "hourglass-outline" : "bulb"} 
                    size={20} 
                    color="#fff" 
                  />
                </TouchableOpacity>
              )}
              {itineraryData && (
                <TouchableOpacity 
                  onPress={deleteItineraryFromFirebase}
                  className="w-10 h-10 bg-red-500 rounded-full items-center justify-center shadow-md"
                >
                  <Ionicons name="trash-outline" size={20} color="#fff" />
                </TouchableOpacity>
              )}
            </View>
          </View>
        </View>

        {/* Trip Overview Card */}
        {itineraryData && (
          <View className="px-5 pt-5 pb-4">
            <View className="rounded-3xl overflow-hidden shadow-xl">
              <LinearGradient
                colors={['#3b82f6', '#8b5cf6']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={{ padding: 24 }}
              >
                <View className="flex-row items-center justify-between mb-4">
                  <View className="flex-1 pr-4">
                    <Text className="text-white text-2xl font-bold mb-2">{itineraryData.title}</Text>
                    <Text className="text-white text-sm">
                      {itineraryData.totalDays} Day Trip • Personalized for You
                    </Text>
                  </View>
                  <View className="bg-blue-400 rounded-2xl px-4 py-3 items-center">
                    <Text className="text-white text-xs mb-1">Total Days</Text>
                    <Text className="text-white text-2xl font-bold">{itineraryData.totalDays}</Text>
                  </View>
                </View>
              </LinearGradient>
            </View>
          </View>
        )}

        {/* Day Tabs */}
        {itineraryData && (
          <View className="px-5 pb-4">
            <ScrollView 
              horizontal 
              showsHorizontalScrollIndicator={false}
              contentContainerStyle={{ flexDirection: 'row', gap: 8 }}
            >
              {itineraryData.days.map((dayData: any) => (
                <TouchableOpacity
                  key={dayData.day}
                  onPress={() => setSelectedDay(dayData.day)}
                  className={`rounded-xl px-6 py-3 ${
                    selectedDay === dayData.day
                      ? 'bg-blue-500 shadow-md'
                      : 'bg-white border border-gray-200'
                  }`}
                >
                  <Text
                    className={`text-sm font-bold ${
                      selectedDay === dayData.day ? 'text-white' : 'text-gray-700'
                    }`}
                  >
                    Day {dayData.day}
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </View>
        )}

        {/* Day Activities */}
        {currentDayData && (
          <View className="px-5 pb-6">
            {/* Date Header */}
            <View className="flex-row items-center mb-4">
              <View className="w-1 h-6 bg-blue-500 rounded-full mr-3" />
              <Text className="text-sm text-gray-600">{currentDayData.dayName}</Text>
              <Text className="text-xs text-gray-400 ml-2">• {currentDayData.activities.length} activities</Text>
            </View>

            {/* Activities */}
            {currentDayData.activities.map((activity: any, index: number) => {
              const periodStyle = periodColors[activity.period] || periodColors.Morning;
              const categoryStyle = categoryColors[activity.category] || categoryColors.Activity;

              return (
                <View key={activity.id} className="mb-4">
                  {/* Time Header */}
                  <View className="flex-row items-center mb-2 flex-wrap" style={{ gap: 8 }}>
                    <Text className="text-sm font-bold text-gray-900">{activity.time}</Text>
                    <View className={`${periodStyle.bg} rounded-full px-3 py-1 flex-row items-center`}>
                      {renderIcon(periodStyle, 14, periodStyle.text.includes('yellow') ? '#a16207' : periodStyle.text.includes('orange') ? '#c2410c' : '#6b21a8')}
                      <Text className={`text-xs font-semibold ${periodStyle.text} ml-1`}>
                        {activity.period}
                      </Text>
                    </View>
                    <View className={`${categoryStyle.bg} rounded-full px-3 py-1 flex-row items-center`}>
                      {renderIcon(categoryStyle, 14, '#fff')}
                      <Text className="text-white text-xs font-bold ml-1">{activity.category}</Text>
                    </View>
                    {activity.isHiddenGem && (
                      <View className="bg-yellow-400 rounded-full px-3 py-1 flex-row items-center">
                        <Ionicons name="diamond" size={12} color="#713f12" />
                        <Text className="text-yellow-900 text-xs font-bold ml-1">Hidden Gem</Text>
                      </View>
                    )}
                    {activity.isDone && (
                      <View className="bg-green-500 rounded-full px-3 py-1 flex-row items-center">
                        <Ionicons name="checkmark-circle" size={12} color="#fff" />
                        <Text className="text-white text-xs font-bold ml-1">Completed</Text>
                      </View>
                    )}
                  </View>

                  {/* Activity Card */}
                  <TouchableOpacity 
                    className={`rounded-2xl overflow-hidden shadow-lg ${activity.isDone ? 'bg-gray-100' : 'bg-white'}`}
                    style={activity.isDone ? { opacity: 0.7 } : {}}
                  >
                    <View className="flex-row">
                      <View className="relative">
                        <Image
                          source={{ uri: activity.image }}
                          style={{ width: 100, height: 140, borderTopLeftRadius: 16, borderBottomLeftRadius: 16 }}
                          resizeMode="cover"
                        />
                        {activity.isDone && (
                          <View 
                            className="absolute inset-0 bg-green-500 items-center justify-center"
                            style={{ 
                              borderTopLeftRadius: 16, 
                              borderBottomLeftRadius: 16,
                              opacity: 0.8 
                            }}
                          >
                            {/* <Text className="text-white text-3xl">✓</Text> */}
                          </View>
                        )}
                      </View>
                      <View className="flex-1 p-4">
                        <View className="flex-row items-start justify-between mb-2">
                          <View className="flex-1 pr-2">
                            <Text 
                              className={`text-base font-bold mb-1 ${activity.isDone ? 'text-gray-500' : 'text-gray-900'}`}
                              style={activity.isDone ? { textDecorationLine: 'line-through' } : {}}
                            >
                              {activity.title}
                            </Text>
                            <Text className="text-xs text-gray-500 mb-2 leading-4" numberOfLines={2}>
                              {activity.description}
                            </Text>
                          </View>
                          <View className="flex-row" style={{ gap: 8 }}>
                            <TouchableOpacity 
                              className={`w-8 h-8 rounded-lg items-center justify-center ${
                                activity.isDone ? 'bg-gray-200' : 'bg-green-50'
                              }`}
                              onPress={() => toggleActivityDone(selectedDay, index)}
                            >
                              <Ionicons 
                                name={activity.isDone ? "refresh" : "checkmark"} 
                                size={16} 
                                color={activity.isDone ? "#666" : "#16a34a"} 
                              />
                            </TouchableOpacity>
                            <TouchableOpacity 
                              className="w-8 h-8 bg-red-50 rounded-lg items-center justify-center"
                              onPress={() => handleDeleteActivity(selectedDay, index)}
                            >
                              <Ionicons name="trash-outline" size={16} color="#dc2626" />
                            </TouchableOpacity>
                          </View>
                        </View>
                        
                        <View className="flex-row items-center flex-wrap" style={{ gap: 8 }}>
                          <View className="bg-blue-50 rounded-lg px-2 py-1 flex-row items-center">
                            <Ionicons name="time-outline" size={12} color="#1d4ed8" />
                            <Text className="text-xs text-blue-700 font-semibold ml-1">{activity.duration}</Text>
                          </View>
                          <View className="bg-green-50 rounded-lg px-2 py-1 flex-row items-center">
                            <Ionicons name="wallet-outline" size={12} color="#16a34a" />
                            <Text className="text-xs text-green-700 font-semibold ml-1">{activity.price}</Text>
                          </View>
                          {activity.distance > 0 && (
                            <View className="bg-purple-50 rounded-lg px-2 py-1 flex-row items-center">
                              <Ionicons name="car-outline" size={12} color="#7c3aed" />
                              <Text className="text-xs text-purple-700 font-semibold ml-1">{activity.distance} km</Text>
                            </View>
                          )}
                        </View>
                      </View>
                    </View>
                  </TouchableOpacity>

                  {/* Price Alerts & Scam Warnings */}
                  {(() => {
                    const priceData = getPriceAlerts(
                      activity.place || activity.title,
                      activity.description || '',
                      activity.category || 'Activity'
                    );
                    const isExpanded = expandedPriceAlert === activity.id;

                    return (
                      <View className="mt-2">
                        <TouchableOpacity
                          onPress={() => setExpandedPriceAlert(isExpanded ? null : activity.id)}
                          className="bg-amber-50 border-2 border-amber-200 rounded-2xl p-3 flex-row items-center justify-between"
                        >
                          <View className="flex-row items-center flex-1">
                            <View className="w-10 h-10 bg-amber-500 rounded-full items-center justify-center mr-3">
                              <Ionicons name="wallet" size={20} color="#fff" />
                            </View>
                            <View className="flex-1">
                              <Text className="text-amber-900 font-bold text-sm">Price Alerts & Scams</Text>
                              <Text className="text-amber-700 text-xs">
                                {priceData.scams.length} warnings • {priceData.items.length} items
                              </Text>
                            </View>
                          </View>
                          <Ionicons
                            name={isExpanded ? "chevron-up" : "chevron-down"}
                            size={20}
                            color="#92400e"
                          />
                        </TouchableOpacity>

                        {isExpanded && (
                          <View className="bg-white rounded-2xl mt-2 p-4 shadow-md">
                            {/* Scam Warnings */}
                            {priceData.scams.length > 0 && (
                              <View className="mb-4">
                                <View className="flex-row items-center mb-3">
                                  <Ionicons name="alert-circle" size={20} color="#dc2626" />
                                  <Text className="text-red-900 font-bold ml-2">⚠️ Scam Warnings</Text>
                                </View>
                                {priceData.scams.map((scam, idx) => (
                                  <View
                                    key={idx}
                                    className={`mb-3 p-3 rounded-xl ${
                                      scam.severity === 'high'
                                        ? 'bg-red-50 border-2 border-red-200'
                                        : scam.severity === 'medium'
                                        ? 'bg-orange-50 border-2 border-orange-200'
                                        : 'bg-yellow-50 border-2 border-yellow-200'
                                    }`}
                                  >
                                    <View className="flex-row items-start">
                                      <View
                                        className={`w-8 h-8 rounded-full items-center justify-center mr-2 ${
                                          scam.severity === 'high'
                                            ? 'bg-red-500'
                                            : scam.severity === 'medium'
                                            ? 'bg-orange-500'
                                            : 'bg-yellow-500'
                                        }`}
                                      >
                                        <Ionicons name={scam.icon as any} size={16} color="#fff" />
                                      </View>
                                      <View className="flex-1">
                                        <Text
                                          className={`font-bold text-sm mb-1 ${
                                            scam.severity === 'high'
                                              ? 'text-red-900'
                                              : scam.severity === 'medium'
                                              ? 'text-orange-900'
                                              : 'text-yellow-900'
                                          }`}
                                        >
                                          {scam.title}
                                        </Text>
                                        <Text
                                          className={`text-xs leading-4 ${
                                            scam.severity === 'high'
                                              ? 'text-red-700'
                                              : scam.severity === 'medium'
                                              ? 'text-orange-700'
                                              : 'text-yellow-700'
                                          }`}
                                        >
                                          {scam.description}
                                        </Text>
                                      </View>
                                    </View>
                                  </View>
                                ))}
                              </View>
                            )}

                            {/* Price Items */}
                            {priceData.items.length > 0 && (
                              <View className="mb-4">
                                <View className="flex-row items-center mb-3">
                                  <Ionicons name="pricetag" size={20} color="#059669" />
                                  <Text className="text-green-900 font-bold ml-2">💰 Fair Prices</Text>
                                </View>
                                {priceData.items.map((item, idx) => (
                                  <View
                                    key={idx}
                                    className="mb-2 p-3 bg-gray-50 rounded-xl"
                                  >
                                    <View className="flex-row items-start justify-between mb-1">
                                      <View className="flex-row items-center flex-1">
                                        <Ionicons name={item.icon as any} size={16} color="#666" />
                                        <Text className="text-gray-900 font-semibold text-sm ml-2 flex-1">
                                          {item.item}
                                        </Text>
                                      </View>
                                    </View>
                                    <View className="flex-row items-center justify-between ml-6">
                                      <View>
                                        <Text className="text-green-700 font-bold text-sm">
                                          ✓ Fair: {item.fairPrice}
                                        </Text>
                                        {item.scamPrice && (
                                          <Text className="text-red-600 font-bold text-xs line-through">
                                            ✗ Scam: {item.scamPrice}
                                          </Text>
                                        )}
                                      </View>
                                    </View>
                                    {item.warning && (
                                      <View className="ml-6 mt-2 bg-yellow-50 rounded-lg p-2">
                                        <Text className="text-yellow-800 text-xs">
                                          💡 {item.warning}
                                        </Text>
                                      </View>
                                    )}
                                  </View>
                                ))}
                              </View>
                            )}

                            {/* Tips */}
                            {priceData.tips.length > 0 && (
                              <View>
                                <View className="flex-row items-center mb-3">
                                  <Ionicons name="bulb" size={20} color="#3b82f6" />
                                  <Text className="text-blue-900 font-bold ml-2">💡 Pro Tips</Text>
                                </View>
                                {priceData.tips.map((tip, idx) => (
                                  <View key={idx} className="flex-row items-start mb-2">
                                    <Text className="text-blue-600 mr-2">•</Text>
                                    <Text className="text-gray-700 text-xs leading-5 flex-1">
                                      {tip}
                                    </Text>
                                  </View>
                                ))}
                              </View>
                            )}
                          </View>
                        )}
                      </View>
                    );
                  })()}
                </View>
              );
            })}

            {/* Add Activity Button */}
            <TouchableOpacity className="bg-white border-2 border-dashed border-blue-300 rounded-2xl p-4 items-center mt-2">
              <View className="w-12 h-12 bg-blue-100 rounded-full items-center justify-center mb-2">
                <Text className="text-2xl">➕</Text>
              </View>
              <Text className="text-blue-600 text-sm font-bold">Add Activity</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Action Buttons */}
        {itineraryData && (
          <View className="px-5 pb-6">
            {/* Get Suggestions Button */}
            <TouchableOpacity 
              onPress={fetchSuggestions}
              disabled={isFetchingSuggestions}
              className="mb-3"
            >
              <LinearGradient
                colors={isFetchingSuggestions ? ['#9ca3af', '#6b7280'] : ['#8b5cf6', '#ec4899']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 0 }}
                style={{ borderRadius: 16, paddingVertical: 16, paddingHorizontal: 24, alignItems: 'center', shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.3, shadowRadius: 8, elevation: 5 }}
              >
                <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                  {isFetchingSuggestions && <ActivityIndicator color="white" style={{ marginRight: 8 }} />}
                  <Text className="text-white text-sm font-bold">
                    {isFetchingSuggestions ? 'Getting Suggestions...' : '💡 Get Smart Suggestions'}
                  </Text>
                </View>
              </LinearGradient>
            </TouchableOpacity>

            {/* Regenerate Button */}
            <TouchableOpacity 
              onPress={openPreferencesModal}
              disabled={isLoading}
              className="bg-white border-2 border-blue-500 rounded-2xl p-4 items-center flex-row justify-center"
            >
              <Ionicons name="refresh" size={18} color="#2563eb" style={{ marginRight: 8 }} />
              <Text className="text-blue-600 text-sm font-bold">
                {isLoading ? 'Regenerating...' : 'Regenerate Itinerary'}
              </Text>
            </TouchableOpacity>
            
            {error && (
              <View className="bg-red-50 border border-red-200 rounded-2xl p-3 mt-3">
                <Text className="text-red-800 text-xs text-center">{error}</Text>
              </View>
            )}
          </View>
        )}

        {/* Bottom Spacing */}
        <View className="h-6" />
      </ScrollView>

      {/* Preferences Modal */}
      <Modal
        visible={showPreferencesModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowPreferencesModal(false)}
      >
        <View style={{ flex: 1, backgroundColor: 'rgba(0, 0, 0, 0.5)', justifyContent: 'flex-end' }}>
          <View style={{ backgroundColor: '#fff', borderTopLeftRadius: 24, borderTopRightRadius: 24, maxHeight: '90%' }}>
            <ScrollView showsVerticalScrollIndicator={false}>
              <View className="p-6">
                {/* Header */}
                <View className="flex-row items-center justify-between mb-6">
                  <Text className="text-2xl font-bold text-gray-900">Plan Your Trip</Text>
                  <TouchableOpacity onPress={() => setShowPreferencesModal(false)}>
                    <Ionicons name="close-circle" size={28} color="#9ca3af" />
                  </TouchableOpacity>
                </View>

                {/* Current Location */}
                <View className="mb-4">
                  <View className="flex-row items-center justify-between mb-2">
                    <Text className="text-sm font-semibold text-gray-700">
                      📍 Current Location
                    </Text>
                    {!isFetchingLocation && !currentLocation && (
                      <TouchableOpacity onPress={getCurrentLocation}>
                        <Text className="text-blue-500 text-xs font-semibold">Retry</Text>
                      </TouchableOpacity>
                    )}
                  </View>
                  {isFetchingLocation ? (
                    <View className="bg-blue-50 rounded-xl px-4 py-3 flex-row items-center">
                      <ActivityIndicator size="small" color="#3b82f6" style={{ marginRight: 8 }} />
                      <Text className="text-gray-600">Fetching your location...</Text>
                    </View>
                  ) : currentLocation ? (
                    <View className="bg-blue-50 rounded-xl px-4 py-3 flex-row items-center">
                      <Ionicons name="pin" size={18} color="#3b82f6" style={{ marginRight: 8 }} />
                      <Text className="text-gray-900">{currentLocation}</Text>
                    </View>
                  ) : (
                    <TextInput
                      value={currentLocation}
                      onChangeText={(text) => {
                        setCurrentLocation(text);
                        // Set default coordinates if manual entry
                        if (!locationCoords) {
                          setLocationCoords({ latitude: 15.2993, longitude: 74.1240 }); // Default Goa
                        }
                      }}
                      placeholder="Enter your location (e.g., Panjim, Goa)"
                      className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                    />
                  )}
                </View>

                {/* Trip Duration */}
                <View className="mb-4">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Trip Duration (Days) *</Text>
                  <TextInput
                    value={totalDays}
                    onChangeText={setTotalDays}
                    placeholder="e.g., 3"
                    keyboardType="numeric"
                    className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                  />
                </View>

                {/* Budget */}
                <View className="mb-4">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Budget (INR) *</Text>
                  <TextInput
                    value={budget}
                    onChangeText={setBudget}
                    placeholder="e.g., 8000"
                    keyboardType="numeric"
                    className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                  />
                </View>

                {/* Number of Travelers */}
                <View className="mb-4">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Number of Travelers *</Text>
                  <TextInput
                    value={travelers}
                    onChangeText={setTravelers}
                    placeholder="e.g., 2"
                    keyboardType="numeric"
                    className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                  />
                </View>

                {/* Interests */}
                <View className="mb-4">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Interests</Text>
                  <View className="flex-row flex-wrap gap-2">
                    {['beaches', 'local_food', 'hidden_gems', 'adventure', 'culture', 'nightlife'].map((interest) => (
                      <TouchableOpacity
                        key={interest}
                        onPress={() => {
                          if (interests.includes(interest)) {
                            setInterests(interests.filter(i => i !== interest));
                          } else {
                            setInterests([...interests, interest]);
                          }
                        }}
                        className={`rounded-full px-4 py-2 ${
                          interests.includes(interest) ? 'bg-blue-500' : 'bg-gray-200'
                        }`}
                      >
                        <Text className={`text-sm font-semibold ${
                          interests.includes(interest) ? 'text-white' : 'text-gray-700'
                        }`}>
                          {interest.replace('_', ' ')}
                        </Text>
                      </TouchableOpacity>
                    ))}
                  </View>
                </View>

                {/* Travel Pace */}
                <View className="mb-4">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Travel Pace</Text>
                  <View className="flex-row gap-2">
                    {['slow', 'moderate', 'fast'].map((pace) => (
                      <TouchableOpacity
                        key={pace}
                        onPress={() => setTravelPace(pace)}
                        className={`flex-1 rounded-xl px-4 py-3 ${
                          travelPace === pace ? 'bg-blue-500' : 'bg-gray-200'
                        }`}
                      >
                        <Text className={`text-sm font-semibold text-center ${
                          travelPace === pace ? 'text-white' : 'text-gray-700'
                        }`}>
                          {pace}
                        </Text>
                      </TouchableOpacity>
                    ))}
                  </View>
                </View>

                {/* Travel Mode */}
                <View className="mb-4">
                  <Text className="text-sm font-semibold text-gray-700 mb-2">Travel Mode</Text>
                  <View className="flex-row gap-2">
                    {['bike', 'car', 'public'].map((mode) => (
                      <TouchableOpacity
                        key={mode}
                        onPress={() => setTravelMode(mode)}
                        className={`flex-1 rounded-xl px-4 py-3 flex-row items-center justify-center ${
                          travelMode === mode ? 'bg-blue-500' : 'bg-gray-200'
                        }`}
                      >
                        <Ionicons 
                          name={mode === 'bike' ? 'bicycle' : mode === 'car' ? 'car' : 'bus'}
                          size={18}
                          color={travelMode === mode ? '#fff' : '#374151'}
                          style={{ marginRight: 4 }}
                        />
                        <Text className={`text-sm font-semibold ${
                          travelMode === mode ? 'text-white' : 'text-gray-700'
                        }`}>
                          {mode}
                        </Text>
                      </TouchableOpacity>
                    ))}
                  </View>
                </View>

                {/* Avoid Crowds */}
                <View className="mb-6">
                  <TouchableOpacity
                    onPress={() => setAvoidCrowds(!avoidCrowds)}
                    className="flex-row items-center justify-between bg-gray-50 rounded-xl px-4 py-3"
                  >
                    <View className="flex-row items-center">
                      <Ionicons name="people-outline" size={20} color="#374151" style={{ marginRight: 8 }} />
                      <Text className="text-sm font-semibold text-gray-700">Avoid Crowded Places</Text>
                    </View>
                    <View className={`w-12 h-6 rounded-full ${avoidCrowds ? 'bg-blue-500' : 'bg-gray-300'}`}>
                      <View className={`w-6 h-6 rounded-full bg-white shadow ${avoidCrowds ? 'ml-6' : 'ml-0'}`} />
                    </View>
                  </TouchableOpacity>
                </View>

                {/* Generate Button */}
                <TouchableOpacity 
                  onPress={fetchItinerary}
                  disabled={isLoading || isFetchingLocation || !totalDays || !budget || !travelers || !currentLocation}
                  className="w-full"
                >
                  <LinearGradient
                    colors={(isLoading || isFetchingLocation || !totalDays || !budget || !travelers || !currentLocation) ? ['#9ca3af', '#6b7280'] : ['#3b82f6', '#8b5cf6']}
                    start={{ x: 0, y: 0 }}
                    end={{ x: 1, y: 0 }}
                    style={{ borderRadius: 16, padding: 18, alignItems: 'center', flexDirection: 'row', justifyContent: 'center' }}
                  >
                    {isLoading ? (
                      <>
                        <ActivityIndicator color="#fff" size="small" />
                        <Text className="text-white font-bold text-base ml-2">Generating...</Text>
                      </>
                    ) : isFetchingLocation ? (
                      <>
                        <ActivityIndicator color="#fff" size="small" />
                        <Text className="text-white font-bold text-base ml-2">Getting Location...</Text>
                      </>
                    ) : (
                      <>
                        <Ionicons name="sparkles" size={20} color="#fff" style={{ marginRight: 8 }} />
                        <Text className="text-white font-bold text-base">Generate Itinerary</Text>
                      </>
                    )}
                  </LinearGradient>
                </TouchableOpacity>
                
                {!currentLocation && !isFetchingLocation && (
                  <Text className="text-gray-500 text-xs text-center mt-2">
                    Please enter your location or tap Retry to fetch automatically
                  </Text>
                )}
              </View>
            </ScrollView>
          </View>
        </View>
      </Modal>
    </View>
  );
}

export default SmartItinerary;

