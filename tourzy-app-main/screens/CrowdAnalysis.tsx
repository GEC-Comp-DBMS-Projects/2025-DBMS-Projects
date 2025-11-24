import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  Dimensions,
  ActivityIndicator,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import { auth, db } from '../firebase';
import { doc, getDoc } from 'firebase/firestore';

const { width } = Dimensions.get('window');

// Map activity categories to crowd data types
const categoryMapping: any = {
  'Food': 'Restaurant',
  'Activity': 'Activity', // Will be mapped based on place name
  'Beach': 'Beach',
  'Heritage': 'Heritage',
  'Adventure': 'Adventure',
  'Nature': 'Adventure',
  'Experience': 'Market',
  'Wellness': 'Temple',
};

// Helper to detect category from place name and description
const detectCategoryFromPlace = (place: string, description: string, category: string) => {
  const lowerPlace = place.toLowerCase();
  const lowerDesc = description.toLowerCase();
  
  if (category === 'Food') return 'Restaurant';
  if (lowerPlace.includes('beach') || lowerDesc.includes('beach')) return 'Beach';
  if (lowerPlace.includes('fort') || lowerPlace.includes('church') || lowerPlace.includes('temple') || lowerDesc.includes('heritage') || lowerDesc.includes('church')) return 'Heritage';
  if (lowerPlace.includes('kayak') || lowerPlace.includes('trek') || lowerDesc.includes('adventure')) return 'Adventure';
  if (lowerPlace.includes('temple') || lowerPlace.includes('church') || lowerDesc.includes('temple')) return 'Temple';
  if (lowerPlace.includes('market') || lowerPlace.includes('shop') || lowerDesc.includes('market')) return 'Market';
  
  return 'Activity'; // Default fallback
};

// Static crowd data for different place types
const crowdData = {
  Activity: {
    icon: 'walk',
    iconSet: 'Ionicons',
    color: ['#3b82f6', '#2563eb'],
    timeOfDay: [
      { time: '9-11 AM', level: 'Medium', value: 55, color: '#f59e0b' },
      { time: '11-1 PM', level: 'High', value: 70, color: '#ef4444' },
      { time: '1-3 PM', level: 'Medium', value: 50, color: '#f59e0b' },
      { time: '3-6 PM', level: 'High', value: 75, color: '#ef4444' },
      { time: '6-8 PM', level: 'Medium', value: 45, color: '#f59e0b' },
    ],
    dayOfWeek: [
      { day: 'Mon', level: 'Low', value: 25 },
      { day: 'Tue', level: 'Low', value: 30 },
      { day: 'Wed', level: 'Medium', value: 40 },
      { day: 'Thu', level: 'Medium', value: 45 },
      { day: 'Fri', level: 'High', value: 70 },
      { day: 'Sat', level: 'Very High', value: 90 },
      { day: 'Sun', level: 'Very High', value: 85 },
    ],
    seasonality: [
      { month: 'Nov-Feb', level: 'Peak Season', value: 85, desc: 'Tourist season, expect crowds' },
      { month: 'Mar-May', level: 'High Season', value: 65, desc: 'Summer vacation busy' },
      { month: 'Jun-Oct', level: 'Moderate', value: 45, desc: 'Monsoon, fewer visitors' },
    ],
    insights: [
      'Best time: Early morning or late afternoon',
      'Weekdays are significantly less crowded',
      'Peak tourist season brings large groups',
      'Book guided activities in advance',
    ],
  },
  Beach: {
    icon: 'beach',
    iconSet: 'MaterialCommunityIcons',
    color: ['#06b6d4', '#0891b2'],
    timeOfDay: [
      { time: '6-9 AM', level: 'Low', value: 20, color: '#10b981' },
      { time: '9-12 PM', level: 'Medium', value: 50, color: '#f59e0b' },
      { time: '12-3 PM', level: 'High', value: 85, color: '#ef4444' },
      { time: '3-6 PM', level: 'Very High', value: 95, color: '#dc2626' },
      { time: '6-9 PM', level: 'Medium', value: 60, color: '#f59e0b' },
    ],
    dayOfWeek: [
      { day: 'Mon', level: 'Low', value: 30 },
      { day: 'Tue', level: 'Low', value: 25 },
      { day: 'Wed', level: 'Medium', value: 40 },
      { day: 'Thu', level: 'Medium', value: 45 },
      { day: 'Fri', level: 'High', value: 75 },
      { day: 'Sat', level: 'Very High', value: 95 },
      { day: 'Sun', level: 'Very High', value: 90 },
    ],
    seasonality: [
      { month: 'Nov-Feb', level: 'Peak Season', value: 90, desc: 'Tourist season, expect large crowds' },
      { month: 'Mar-May', level: 'High Season', value: 70, desc: 'Summer holidays, very busy' },
      { month: 'Jun-Oct', level: 'Low Season', value: 30, desc: 'Monsoon, fewer tourists' },
    ],
    insights: [
      'Best time to visit: Early morning (6-9 AM) for peaceful experience',
      'Avoid weekends during peak season',
      'Sunset hours (5-7 PM) are extremely crowded',
      'Weekdays in monsoon offer the most privacy',
    ],
  },
  Restaurant: {
    icon: 'food',
    iconSet: 'Ionicons',
    color: ['#f97316', '#ea580c'],
    timeOfDay: [
      { time: '11-1 PM', level: 'Very High', value: 90, color: '#dc2626' },
      { time: '1-3 PM', level: 'High', value: 75, color: '#ef4444' },
      { time: '3-6 PM', level: 'Low', value: 25, color: '#10b981' },
      { time: '6-8 PM', level: 'Medium', value: 55, color: '#f59e0b' },
      { time: '8-10 PM', level: 'Very High', value: 95, color: '#dc2626' },
    ],
    dayOfWeek: [
      { day: 'Mon', level: 'Low', value: 35 },
      { day: 'Tue', level: 'Low', value: 40 },
      { day: 'Wed', level: 'Medium', value: 50 },
      { day: 'Thu', level: 'Medium', value: 55 },
      { day: 'Fri', level: 'High', value: 80 },
      { day: 'Sat', level: 'Very High', value: 95 },
      { day: 'Sun', level: 'High', value: 85 },
    ],
    seasonality: [
      { month: 'Nov-Feb', level: 'Peak Season', value: 85, desc: 'Holiday season, reservations recommended' },
      { month: 'Mar-May', level: 'High Season', value: 70, desc: 'Summer vacation crowds' },
      { month: 'Jun-Oct', level: 'Moderate', value: 50, desc: 'Monsoon season, steady traffic' },
    ],
    insights: [
      'Lunch rush: 12-2 PM on weekdays',
      'Dinner peak: 7-9 PM, book in advance',
      'Tuesday-Thursday afternoons are quietest',
      'Breakfast (7-10 AM) usually less crowded',
    ],
  },
  Heritage: {
    icon: 'landmark',
    iconSet: 'FontAwesome5',
    color: ['#a855f7', '#9333ea'],
    timeOfDay: [
      { time: '9-11 AM', level: 'Medium', value: 50, color: '#f59e0b' },
      { time: '11-1 PM', level: 'High', value: 80, color: '#ef4444' },
      { time: '1-3 PM', level: 'Medium', value: 55, color: '#f59e0b' },
      { time: '3-5 PM', level: 'High', value: 75, color: '#ef4444' },
      { time: '5-6 PM', level: 'Low', value: 30, color: '#10b981' },
    ],
    dayOfWeek: [
      { day: 'Mon', level: 'Low', value: 20 },
      { day: 'Tue', level: 'Low', value: 25 },
      { day: 'Wed', level: 'Medium', value: 35 },
      { day: 'Thu', level: 'Medium', value: 40 },
      { day: 'Fri', level: 'Medium', value: 50 },
      { day: 'Sat', level: 'Very High', value: 95 },
      { day: 'Sun', level: 'Very High', value: 90 },
    ],
    seasonality: [
      { month: 'Nov-Feb', level: 'Peak Season', value: 95, desc: 'Tourist peak, very crowded' },
      { month: 'Mar-May', level: 'Moderate', value: 55, desc: 'Hot weather, moderate crowds' },
      { month: 'Jun-Oct', level: 'Low Season', value: 25, desc: 'Monsoon, minimal crowds' },
    ],
    insights: [
      'Opening hours (9-10 AM) best for photography',
      'Avoid 11 AM-2 PM during weekends',
      'Monsoon season ideal for peaceful visits',
      'Guided tours increase crowds around 11 AM',
    ],
  },
  Adventure: {
    icon: 'terrain',
    iconSet: 'MaterialIcons',
    color: ['#22c55e', '#16a34a'],
    timeOfDay: [
      { time: '6-9 AM', level: 'High', value: 70, color: '#ef4444' },
      { time: '9-12 PM', level: 'Very High', value: 90, color: '#dc2626' },
      { time: '12-3 PM', level: 'Medium', value: 50, color: '#f59e0b' },
      { time: '3-6 PM', level: 'High', value: 75, color: '#ef4444' },
      { time: '6-7 PM', level: 'Low', value: 25, color: '#10b981' },
    ],
    dayOfWeek: [
      { day: 'Mon', level: 'Low', value: 15 },
      { day: 'Tue', level: 'Low', value: 20 },
      { day: 'Wed', level: 'Low', value: 25 },
      { day: 'Thu', level: 'Medium', value: 35 },
      { day: 'Fri', level: 'High', value: 70 },
      { day: 'Sat', level: 'Very High', value: 95 },
      { day: 'Sun', level: 'Very High', value: 90 },
    ],
    seasonality: [
      { month: 'Nov-Feb', level: 'Peak Season', value: 80, desc: 'Perfect weather for adventures' },
      { month: 'Mar-May', level: 'Moderate', value: 50, desc: 'Hot but still popular' },
      { month: 'Jun-Oct', level: 'Variable', value: 40, desc: 'Monsoon, some activities closed' },
    ],
    insights: [
      'Early morning slots fill up fast on weekends',
      'Weekdays significantly less crowded',
      'Book adventure activities 2-3 days ahead',
      'Evening slots often available last minute',
    ],
  },
  Temple: {
    icon: 'flower',
    iconSet: 'MaterialCommunityIcons',
    color: ['#ec4899', '#db2777'],
    timeOfDay: [
      { time: '5-7 AM', level: 'High', value: 80, color: '#ef4444' },
      { time: '7-9 AM', level: 'Very High', value: 95, color: '#dc2626' },
      { time: '9-12 PM', level: 'Medium', value: 50, color: '#f59e0b' },
      { time: '12-5 PM', level: 'Low', value: 30, color: '#10b981' },
      { time: '5-8 PM', level: 'Very High', value: 90, color: '#dc2626' },
    ],
    dayOfWeek: [
      { day: 'Mon', level: 'High', value: 70 },
      { day: 'Tue', level: 'Very High', value: 85 },
      { day: 'Wed', level: 'Medium', value: 55 },
      { day: 'Thu', level: 'High', value: 75 },
      { day: 'Fri', level: 'Very High', value: 90 },
      { day: 'Sat', level: 'Very High', value: 95 },
      { day: 'Sun', level: 'Extreme', value: 98 },
    ],
    seasonality: [
      { month: 'Nov-Feb', level: 'Festive Season', value: 90, desc: 'Multiple festivals, expect crowds' },
      { month: 'Mar-May', level: 'High Season', value: 70, desc: 'Summer holidays bring visitors' },
      { month: 'Jun-Oct', level: 'Moderate', value: 55, desc: 'Monsoon festivals vary' },
    ],
    insights: [
      'Early morning (5-7 AM) extremely busy with devotees',
      'Afternoon (12-4 PM) relatively peaceful',
      'Festival days can be 3x more crowded',
      'Special prayer times attract large crowds',
    ],
  },
  Market: {
    icon: 'shopping',
    iconSet: 'MaterialCommunityIcons',
    color: ['#eab308', '#ca8a04'],
    timeOfDay: [
      { time: '10-12 PM', level: 'Medium', value: 55, color: '#f59e0b' },
      { time: '12-3 PM', level: 'High', value: 75, color: '#ef4444' },
      { time: '3-6 PM', level: 'Very High', value: 90, color: '#dc2626' },
      { time: '6-8 PM', level: 'Very High', value: 95, color: '#dc2626' },
      { time: '8-10 PM', level: 'Medium', value: 60, color: '#f59e0b' },
    ],
    dayOfWeek: [
      { day: 'Mon', level: 'Low', value: 30 },
      { day: 'Tue', level: 'Low', value: 35 },
      { day: 'Wed', level: 'Medium', value: 45 },
      { day: 'Thu', level: 'Medium', value: 50 },
      { day: 'Fri', level: 'High', value: 75 },
      { day: 'Sat', level: 'Very High', value: 95 },
      { day: 'Sun', level: 'Very High', value: 90 },
    ],
    seasonality: [
      { month: 'Nov-Feb', level: 'Peak Season', value: 85, desc: 'Tourist shopping season' },
      { month: 'Mar-May', level: 'High Season', value: 70, desc: 'Pre-monsoon shopping rush' },
      { month: 'Jun-Oct', level: 'Low Season', value: 40, desc: 'Monsoon, fewer shoppers' },
    ],
    insights: [
      'Morning hours (10-11 AM) best for leisure shopping',
      'Evening rush (5-7 PM) extremely crowded',
      'Weekend mornings slightly less busy than evenings',
      'Monday-Tuesday ideal for relaxed experience',
    ],
  },
};

// Helper function to get crowd level color
const getCrowdColor = (level: string) => {
  if (level === 'Low') return '#10b981';
  if (level === 'Medium') return '#f59e0b';
  if (level === 'High') return '#ef4444';
  if (level === 'Very High' || level === 'Extreme') return '#dc2626';
  return '#6b7280';
};

// Helper function to render icon
const renderIcon = (iconData: any, size: number, color: string) => {
  const { iconSet, icon } = iconData;
  
  switch (iconSet) {
    case 'Ionicons':
      return <Ionicons name={icon as any} size={size} color={color} />;
    case 'MaterialIcons':
      return <Ionicons name={icon as any} size={size} color={color} />;
    case 'MaterialCommunityIcons':
      return <MaterialCommunityIcons name={icon as any} size={size} color={color} />;
    case 'FontAwesome5':
      return <MaterialCommunityIcons name="bank" size={size} color={color} />;
    default:
      return null;
  }
};

function CrowdAnalysis() {
  const navigation = useNavigation<any>();
  const [selectedCategory, setSelectedCategory] = useState<keyof typeof crowdData | null>(null);
  const [itineraryData, setItineraryData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [availableCategories, setAvailableCategories] = useState<Array<keyof typeof crowdData>>([]);
  const [placesInCategory, setPlacesInCategory] = useState<any>({});

  // Load itinerary from Firebase
  useEffect(() => {
    loadItineraryFromFirebase();
  }, []);

  const loadItineraryFromFirebase = async () => {
    setIsLoading(true);
    
    try {
      const user = auth.currentUser;
      if (!user) {
        console.log('No user logged in');
        setIsLoading(false);
        return;
      }

      const itineraryRef = doc(db, 'users', user.uid, 'itinerary', 'current');
      const itinerarySnap = await getDoc(itineraryRef);

      if (itinerarySnap.exists()) {
        const data = itinerarySnap.data();
        console.log('Loaded itinerary from Firebase:', data);
        setItineraryData(data.itinerary);
        
        // Extract categories from itinerary
        if (data.itinerary && data.itinerary.days) {
          const categorySet = new Set<keyof typeof crowdData>();
          const placesByCategory: any = {};
          
          data.itinerary.days.forEach((day: any) => {
            day.activities.forEach((activity: any) => {
              const detectedCategory = detectCategoryFromPlace(
                activity.place || activity.title,
                activity.description || '',
                activity.category || 'Activity'
              );
              
              if (detectedCategory in crowdData) {
                categorySet.add(detectedCategory as keyof typeof crowdData);
                
                // Group places by category
                if (!placesByCategory[detectedCategory]) {
                  placesByCategory[detectedCategory] = [];
                }
                placesByCategory[detectedCategory].push({
                  name: activity.title || activity.place,
                  time: activity.time,
                  day: day.day
                });
              }
            });
          });
          
          const categoriesArray = Array.from(categorySet);
          setAvailableCategories(categoriesArray);
          setPlacesInCategory(placesByCategory);
          
          // Set default selected category
          if (categoriesArray.length > 0 && !selectedCategory) {
            setSelectedCategory(categoriesArray[0]);
          }
        }
      } else {
        console.log('No itinerary found in Firebase');
      }
    } catch (err) {
      console.error('Error loading itinerary from Firebase:', err);
    } finally {
      setIsLoading(false);
    }
  };

  // Loading state
  if (isLoading) {
    return (
      <View className="flex-1 bg-gray-50 items-center justify-center">
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Loading crowd analysis...</Text>
      </View>
    );
  }

  // No itinerary state
  if (!itineraryData || availableCategories.length === 0) {
    return (
      <View className="flex-1 bg-gray-50">
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        
        {/* Header */}
        <View className="bg-white px-5 pt-12 pb-5 shadow-sm">
          <View className="flex-row justify-between items-center">
            <TouchableOpacity onPress={() => navigation.goBack()}>
              <Ionicons name="arrow-back" size={24} color="#000" />
            </TouchableOpacity>
            <View className="flex-1 items-center">
              <Text className="text-lg font-bold text-gray-900">Crowd Analysis</Text>
            </View>
            <View style={{ width: 24 }} />
          </View>
        </View>

        {/* Empty State */}
        <View className="flex-1 px-5 py-12 items-center justify-center">
          <View className="w-32 h-32 bg-blue-100 rounded-full items-center justify-center mb-6">
            <Ionicons name="people-outline" size={64} color="#3b82f6" />
          </View>
          
          <Text className="text-gray-900 text-2xl font-bold mb-3 text-center">
            No Itinerary Found
          </Text>
          <Text className="text-gray-600 text-sm text-center mb-8 px-6 leading-6">
            Create an itinerary first to see crowd analysis for your planned destinations
          </Text>
          
          <TouchableOpacity 
            onPress={() => navigation.navigate('itinerary')}
            className="rounded-2xl overflow-hidden shadow-lg"
          >
            <LinearGradient
              colors={['#3b82f6', '#8b5cf6']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={{ padding: 18, flexDirection: 'row', alignItems: 'center', justifyContent: 'center' }}
            >
              <Ionicons name="calendar" size={20} color="#fff" style={{ marginRight: 8 }} />
              <Text className="text-white text-base font-bold">Create Itinerary</Text>
            </LinearGradient>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  const currentData = selectedCategory ? crowdData[selectedCategory] : null;
  if (!currentData) return null;

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
              <Text className="text-lg font-bold text-gray-900">Crowd Analysis</Text>
              <Text className="text-xs text-gray-500 mt-0.5">For your {itineraryData?.title || 'itinerary'}</Text>
            </View>
            <TouchableOpacity onPress={() => navigation.navigate('itinerary')}>
              <Ionicons name="calendar-outline" size={24} color="#3b82f6" />
            </TouchableOpacity>
          </View>
        </View>

        {/* Category Pills - Only show categories from itinerary */}
        <View className="px-5 pt-5 pb-4">
          <Text className="text-xs text-gray-500 mb-2 uppercase tracking-wide">
            Categories in your itinerary
          </Text>
          <ScrollView 
            horizontal 
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ gap: 8 }}
          >
            {availableCategories.map((category) => {
              const isSelected = selectedCategory === category;
              const categoryData = crowdData[category];
              const placesCount = placesInCategory[category]?.length || 0;
              
              return (
                <TouchableOpacity
                  key={category}
                  onPress={() => setSelectedCategory(category)}
                  className={`rounded-2xl px-5 py-3 ${
                    isSelected ? 'shadow-md' : 'bg-white border border-gray-200'
                  }`}
                  style={isSelected ? {
                    backgroundColor: categoryData.color[0]
                  } : {}}
                >
                  <View className="flex-row items-center">
                    {renderIcon(
                      { iconSet: categoryData.iconSet, icon: categoryData.icon },
                      18,
                      isSelected ? '#fff' : '#666'
                    )}
                    <Text
                      className={`ml-2 text-sm font-bold ${
                        isSelected ? 'text-white' : 'text-gray-700'
                      }`}
                    >
                      {category}
                    </Text>
                  </View>
                  <View 
                    className={`mt-1 rounded-full px-2 py-0.5 self-start ${
                      isSelected ? 'bg-white/30' : 'bg-gray-100'
                    }`}
                  >
                    <Text className={`text-xs font-semibold ${isSelected ? 'text-white' : 'text-gray-600'}`}>
                      {placesCount} {placesCount === 1 ? 'place' : 'places'}
                    </Text>
                  </View>
                </TouchableOpacity>
              );
            })}
          </ScrollView>
        </View>

        {/* Hero Card - Current Category Overview */}
        <View className="px-5 pb-4">
          <View className="rounded-3xl overflow-hidden shadow-xl">
            <LinearGradient
              colors={currentData.color}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={{ padding: 24 }}
            >
              <View className="flex-row items-center mb-4">
                {renderIcon(
                  { iconSet: currentData.iconSet, icon: currentData.icon },
                  40,
                  'rgba(255,255,255,0.9)'
                )}
                <View className="ml-4 flex-1">
                  <Text className="text-white text-2xl font-bold mb-1">
                    {selectedCategory} Spots
                  </Text>
                  <Text className="text-white/90 text-sm">
                    Historical crowd data & insights
                  </Text>
                </View>
              </View>
              
              <View className="bg-white/20 rounded-2xl p-4 mt-2">
                <View className="flex-row items-center mb-2">
                  <Ionicons name="information-circle" size={18} color="#fff" />
                  <Text className="text-white font-bold ml-2">Pro Tip</Text>
                </View>
                <Text className="text-white/95 text-xs leading-5">
                  {currentData.insights[0]}
                </Text>
              </View>
            </LinearGradient>
          </View>
        </View>

        {/* Places from your itinerary in this category */}
        <View className="px-5 pb-4">
          <View className="flex-row items-center mb-3">
            <View className="w-1 h-6 rounded-full mr-3" style={{ backgroundColor: currentData.color[0] }} />
            <Ionicons name="location" size={20} color="#1f2937" style={{ marginRight: 6 }} />
            <Text className="text-lg font-bold text-gray-900">Your Planned {selectedCategory} Visits</Text>
          </View>

          <View className="bg-white rounded-2xl p-4 shadow-md">
            {placesInCategory[selectedCategory!]?.map((place: any, index: number) => (
              <View 
                key={index} 
                className={`flex-row items-center py-3 ${
                  index !== placesInCategory[selectedCategory!].length - 1 ? 'border-b border-gray-100' : ''
                }`}
              >
                <View 
                  className="w-10 h-10 rounded-full items-center justify-center mr-3"
                  style={{ backgroundColor: `${currentData.color[0]}20` }}
                >
                  <Text className="font-bold text-sm" style={{ color: currentData.color[0] }}>
                    D{place.day}
                  </Text>
                </View>
                <View className="flex-1">
                  <Text className="text-sm font-bold text-gray-900 mb-0.5">{place.name}</Text>
                  <View className="flex-row items-center">
                    <Ionicons name="time-outline" size={12} color="#666" />
                    <Text className="text-xs text-gray-600 ml-1">{place.time}</Text>
                  </View>
                </View>
                <View className="bg-gray-50 rounded-lg px-3 py-1">
                  <Text className="text-xs font-semibold text-gray-700">Day {place.day}</Text>
                </View>
              </View>
            ))}
          </View>
        </View>

        {/* Time of Day Analysis */}
        <View className="px-5 pb-4">
          <View className="flex-row items-center mb-3">
            <View className="w-1 h-6 rounded-full mr-3" style={{ backgroundColor: currentData.color[0] }} />
            <Ionicons name="time" size={20} color="#1f2937" style={{ marginRight: 6 }} />
            <Text className="text-lg font-bold text-gray-900">Time of Day</Text>
          </View>

          <View className="bg-white rounded-2xl p-4 shadow-md">
            {currentData.timeOfDay.map((slot, index) => (
              <View key={index} className="mb-4 last:mb-0">
                <View className="flex-row items-center justify-between mb-2">
                  <View className="flex-row items-center flex-1">
                    <Ionicons name="alarm" size={16} color="#666" />
                    <Text className="text-sm font-bold text-gray-900 ml-2">{slot.time}</Text>
                  </View>
                  <View className="flex-row items-center">
                    <View 
                      className="w-2 h-2 rounded-full mr-2" 
                      style={{ backgroundColor: slot.color }}
                    />
                    <Text className="text-xs font-semibold text-gray-700">{slot.level}</Text>
                  </View>
                </View>
                
                {/* Progress Bar */}
                <View className="bg-gray-100 rounded-full h-3 overflow-hidden">
                  <View 
                    className="h-full rounded-full"
                    style={{ 
                      width: `${slot.value}%`,
                      backgroundColor: slot.color
                    }}
                  />
                </View>
              </View>
            ))}
          </View>
        </View>

        {/* Day of Week Analysis */}
        <View className="px-5 pb-4">
          <View className="flex-row items-center mb-3">
            <View className="w-1 h-6 rounded-full mr-3" style={{ backgroundColor: currentData.color[0] }} />
            <Ionicons name="calendar" size={20} color="#1f2937" style={{ marginRight: 6 }} />
            <Text className="text-lg font-bold text-gray-900">Day of Week</Text>
          </View>

          <View className="bg-white rounded-2xl p-4 shadow-md">
            <View className="flex-row justify-between items-end" style={{ height: 150 }}>
              {currentData.dayOfWeek.map((day, index) => {
                const barHeight = (day.value / 100) * 120;
                const barColor = getCrowdColor(day.level);
                
                return (
                  <View key={index} className="items-center flex-1" style={{ justifyContent: 'flex-end' }}>
                    <View className="items-center mb-2">
                      <View 
                        className="rounded-t-lg w-full"
                        style={{ 
                          height: barHeight,
                          backgroundColor: barColor,
                          minHeight: 20
                        }}
                      />
                    </View>
                    <Text className="text-xs font-bold text-gray-700">{day.day}</Text>
                  </View>
                );
              })}
            </View>
            
            {/* Legend */}
            <View className="flex-row flex-wrap gap-3 mt-4 pt-4 border-t border-gray-100">
              <View className="flex-row items-center">
                <View className="w-3 h-3 rounded-full bg-green-500 mr-1.5" />
                <Text className="text-xs text-gray-600">Low</Text>
              </View>
              <View className="flex-row items-center">
                <View className="w-3 h-3 rounded-full bg-yellow-500 mr-1.5" />
                <Text className="text-xs text-gray-600">Medium</Text>
              </View>
              <View className="flex-row items-center">
                <View className="w-3 h-3 rounded-full bg-orange-500 mr-1.5" />
                <Text className="text-xs text-gray-600">High</Text>
              </View>
              <View className="flex-row items-center">
                <View className="w-3 h-3 rounded-full bg-red-600 mr-1.5" />
                <Text className="text-xs text-gray-600">Very High</Text>
              </View>
            </View>
          </View>
        </View>

        {/* Seasonal Analysis */}
        <View className="px-5 pb-4">
          <View className="flex-row items-center mb-3">
            <View className="w-1 h-6 rounded-full mr-3" style={{ backgroundColor: currentData.color[0] }} />
            <MaterialCommunityIcons name="weather-partly-cloudy" size={20} color="#1f2937" style={{ marginRight: 6 }} />
            <Text className="text-lg font-bold text-gray-900">Seasonal Patterns</Text>
          </View>

          <View className="gap-3">
            {currentData.seasonality.map((season, index) => (
              <View key={index} className="bg-white rounded-2xl p-4 shadow-md">
                <View className="flex-row items-center justify-between mb-3">
                  <View className="flex-1">
                    <Text className="text-base font-bold text-gray-900 mb-1">
                      {season.month}
                    </Text>
                    <Text className="text-xs text-gray-500">{season.desc}</Text>
                  </View>
                  <View className="bg-gray-100 rounded-xl px-4 py-2">
                    <Text 
                      className="text-xs font-bold"
                      style={{ color: getCrowdColor(season.level) }}
                    >
                      {season.level}
                    </Text>
                  </View>
                </View>
                
                {/* Circular Progress */}
                <View className="items-center">
                  <View className="relative items-center justify-center">
                    <View className="bg-gray-100 rounded-full" style={{ width: 100, height: 100 }} />
                    <View 
                      className="absolute rounded-full items-center justify-center"
                      style={{ 
                        width: season.value,
                        height: season.value,
                        backgroundColor: getCrowdColor(season.level),
                        opacity: 0.8
                      }}
                    >
                      <Text className="text-white text-xl font-bold">{season.value}%</Text>
                    </View>
                  </View>
                </View>
              </View>
            ))}
          </View>
        </View>

        {/* Key Insights */}
        <View className="px-5 pb-6">
          <View className="flex-row items-center mb-3">
            <View className="w-1 h-6 rounded-full mr-3" style={{ backgroundColor: currentData.color[0] }} />
            <Ionicons name="bulb" size={20} color="#1f2937" style={{ marginRight: 6 }} />
            <Text className="text-lg font-bold text-gray-900">Key Insights</Text>
          </View>

          <View className="bg-white rounded-2xl p-4 shadow-md">
            {currentData.insights.map((insight, index) => (
              <View key={index} className="flex-row items-start mb-3 last:mb-0">
                <View 
                  className="w-6 h-6 rounded-full items-center justify-center mr-3 mt-0.5"
                  style={{ backgroundColor: `${currentData.color[0]}20` }}
                >
                  <Text className="font-bold text-xs" style={{ color: currentData.color[0] }}>
                    {index + 1}
                  </Text>
                </View>
                <Text className="flex-1 text-sm text-gray-700 leading-5">
                  {insight}
                </Text>
              </View>
            ))}
          </View>
        </View>

        {/* Bottom CTA */}
        <View className="px-5 pb-6">
          <TouchableOpacity 
            onPress={() => navigation.navigate('itinerary')}
            className="rounded-2xl overflow-hidden shadow-lg"
          >
            <LinearGradient
              colors={currentData.color}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={{ padding: 18, flexDirection: 'row', alignItems: 'center', justifyContent: 'center' }}
            >
              <Ionicons name="calendar" size={20} color="#fff" style={{ marginRight: 8 }} />
              <Text className="text-white text-base font-bold">
                View Full Itinerary
              </Text>
            </LinearGradient>
          </TouchableOpacity>
          
          <Text className="text-center text-xs text-gray-500 mt-4 px-4">
            💡 Tip: Use this data to optimize your visit times and avoid crowds
          </Text>
        </View>

        {/* Bottom Spacing */}
        <View className="h-6" />
      </ScrollView>
    </View>
  );
}

export default CrowdAnalysis;

