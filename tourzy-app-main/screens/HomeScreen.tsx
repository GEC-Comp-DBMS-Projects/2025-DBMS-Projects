import React, { useCallback, useEffect, useState } from 'react';
import { View, Text, Image, ScrollView, TouchableOpacity, TextInput, ImageBackground, StatusBar, ActivityIndicator } from 'react-native';
import { useFocusEffect, useNavigation } from '@react-navigation/core';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { auth, db } from '../firebase';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialIcons, FontAwesome5, Feather } from '@expo/vector-icons';
import * as Location from 'expo-location';

// const placesData = [
//   {
//     id: 1,
//     name: "Cabo De Rama",
//     location: "Canacona, Goa",
//     rating: 4.8,
//     description: "An ancient fort, an old Portuguese church, a short trek",
//     image: "https://images.unsplash.com/photo-1609920658906-8223bd289001?w=300",
//     tag: "Local Gem",
//     tagColor: "green",
//     crowdLevel: "low",
//     crowdColor: "green"
//   },
//   {
//     id: 2,
//     name: "Old Goa Church",
//     location: "Old Goa, Goa",
//     rating: 4.7,
//     description: "An ancient fort, an old Portuguese church, a short trek",
//     image: "https://images.unsplash.com/photo-1609920658906-8223bd289001?w=300",
//     tag: "Religious",
//     tagColor: "yellow",
//     crowdLevel: "medium",
//     crowdColor: "yellow"
//   },
//   {
//     id: 3,
//     name: "Cabo De Rama",
//     location: "Canacona, Goa",
//     rating: 4.9,
//     description: "An ancient fort, an old Portuguese church, a short trek",
//     image: "https://images.unsplash.com/photo-1609920658906-8223bd289001?w=300",
//     tag: "Local Gem",
//     tagColor: "green",
//     crowdLevel: "high",
//     crowdColor: "red"
//   },
//   {
//     id: 4,
//     name: "Dudhsagar Falls",
//     location: "Mollem, Goa",
//     rating: 4.6,
//     description: "Majestic four-tiered waterfall, perfect for nature lovers",
//     image: "https://images.unsplash.com/photo-1609920658906-8223bd289001?w=300",
//     tag: "Adventure",
//     tagColor: "blue",
//     crowdLevel: "high",
//     crowdColor: "red"
//   },
//   {
//     id: 5,
//     name: "Chapora Fort",
//     location: "Vagator, Goa",
//     rating: 4.5,
//     description: "Famous fort with panoramic views, featured in Bollywood",
//     image: "https://images.unsplash.com/photo-1609920658906-8223bd289001?w=300",
//     tag: "Historical",
//     tagColor: "purple",
//     crowdLevel: "medium",
//     crowdColor: "yellow"
//   },
//   {
//     id: 6,
//     name: "Palolem Beach",
//     location: "Canacona, Goa",
//     rating: 4.8,
//     description: "Crescent-shaped beach with calm waters and scenic beauty",
//     image: "https://images.unsplash.com/photo-1609920658906-8223bd289001?w=300",
//     tag: "Beach",
//     tagColor: "blue",
//     crowdLevel: "medium",
//     crowdColor: "yellow"
//   }
// ];
// Professional Icon components using @expo/vector-icons
const SearchIcon = () => (
  <Ionicons name="search" size={20} color="#999" />
);

const FilterIcon = () => (
  <Ionicons name="options-outline" size={18} color="#666" />
);

const CalendarIcon = () => (
  <Ionicons name="calendar-outline" size={18} color="#666" />
);

const BellIcon = () => (
  <Ionicons name="notifications-outline" size={20} color="#666" />
);

const UserIcon = () => (
  <Ionicons name="person-outline" size={20} color="#666" />
);

const BackIcon = () => (
  <Ionicons name="arrow-back" size={24} color="#000" />
);

const ShareIcon = () => (
  <Ionicons name="share-outline" size={20} color="#000" />
);

const HeartIcon = ({ filled }:any) => (
  <Ionicons 
    name={filled ? "heart" : "heart-outline"} 
    size={24} 
    color={filled ? "#ff0000" : "#000"} 
  />
);

const StarIcon = () => (
  <Ionicons name="star" size={14} color="#FFD700" />
);

const TrendingIcon = () => (
  <Ionicons name="trending-up" size={24} color="#3B82F6" />
);

const SavedIcon = () => (
  <Ionicons name="bookmark" size={24} color="#10B981" />
);

const VisitedIcon = () => (
  <Ionicons name="location" size={24} color="#8B5CF6" />
);

const DirectionsIcon = () => (
  <Ionicons name="navigate" size={18} color="#fff" />
);

const ClockIcon = () => (
  <Ionicons name="time-outline" size={18} color="#666" />
);

const WifiIcon = () => (
  <Ionicons name="wifi" size={18} color="#10B981" />
);

const ParkingIcon = () => (
  <MaterialIcons name="local-parking" size={18} color="#EF4444" />
);

const CardIcon = () => (
  <Ionicons name="card-outline" size={18} color="#3B82F6" />
);

const FamilyIcon = () => (
  <Ionicons name="people" size={18} color="#8B5CF6" />
);

// Enhanced image selection for places (similar to SmartItinerary)
const getStaticPlaceImage = (place: any, index: number) => {
  // If place already has a valid image URL, use it
  // if (place.image && place.image.trim() !== '' && place.image.startsWith('http')) {
  //   return place.image;
  // }

  const placeName = place.name?.toLowerCase() || '';
  const placeTag = place.tag?.toLowerCase() || '';
  const description = place.description?.toLowerCase() || '';
  
  // Beach/Coastal images
  if (placeName.includes('beach') || placeName.includes('sunset') || placeTag.includes('beach') || placeTag.includes('coastal')) {
    return 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80';
  }
  
  // Fort/Heritage/Historical
  if (placeName.includes('fort') || placeName.includes('church') || placeName.includes('cathedral') || 
      placeTag.includes('heritage') || placeTag.includes('historical') || description.includes('fort')) {
    return 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=800&q=80';
  }
  
  // Temple/Religious
  if (placeName.includes('temple') || placeName.includes('mosque') || placeName.includes('shrine') ||
      placeTag.includes('religious') || placeTag.includes('spiritual')) {
    return 'https://images.unsplash.com/photo-1609920658906-8223bd289001?w=800&q=80';
  }
  
  // Food/Restaurant/Cafe
  if (placeName.includes('restaurant') || placeName.includes('cafe') || placeName.includes('food') ||
      placeTag.includes('food') || placeTag.includes('restaurant') || placeTag.includes('cafe')) {
    const foodImages = [
      'https://images.unsplash.com/photo-1533920379810-6bedac961555?w=800&q=80',
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
    ];
    return foodImages[index % foodImages.length];
  }
  
  // Waterfall/Nature
  if (placeName.includes('falls') || placeName.includes('waterfall') || placeName.includes('river')) {
    return 'https://images.unsplash.com/photo-1432405972618-c60b0225b8f9?w=800&q=80';
  }
  
  // Adventure/Trekking/Kayaking
  if (placeName.includes('trek') || placeName.includes('kayak') || placeName.includes('island') || placeName.includes('adventure') ||
      placeTag.includes('adventure') || placeTag.includes('nature') || placeTag.includes('trek')) {
    return 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800&q=80';
  }
  
  // Market/Shopping
  if (placeName.includes('market') || placeName.includes('bazaar') || placeName.includes('shopping')) {
    return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80';
  }
  
  // Wildlife/Safari
  if (placeName.includes('wildlife') || placeName.includes('safari') || placeName.includes('sanctuary')) {
    return 'https://images.unsplash.com/photo-1564760055775-d63b17a55c44?w=800&q=80';
  }
  
  // Architecture
  if (placeTag.includes('architecture') || description.includes('architecture')) {
    return 'https://images.unsplash.com/photo-1564399579883-451a5d44ec08?w=800&q=80';
  }
  
  // Default scenic images array
  const defaultImages = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80', // Scenic mountain
    'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80', // Beach
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800&q=80', // Nature
    'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=800&q=80', // Heritage
    'https://images.unsplash.com/photo-1518509562904-e7ef99cdcc86?w=800&q=80', // Landscape
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&q=80', // Lake
  ];
  
  return defaultImages[index % defaultImages.length];
};

function HomeScreen() {
  const [placesData, setPlacesData] = useState<any[]>([]);
  const [filteredPlaces, setFilteredPlaces] = useState<any[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [currentLocation, setCurrentLocation] = useState<string>('Loading...');
  const [locationLoading, setLocationLoading] = useState(true);



  // Get current location
  const getCurrentLocation = async () => {
    try {
      setLocationLoading(true);
      
      // Request location permissions
      const { status } = await Location.requestForegroundPermissionsAsync();
      
      if (status !== 'granted') {
        setCurrentLocation('Goa, India');
        setLocationLoading(false);
        return;
      }

      // Get current position
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.Balanced,
      });

      // Reverse geocode to get address
      const reverseGeocode = await Location.reverseGeocodeAsync({
        latitude: location.coords.latitude,
        longitude: location.coords.longitude,
      });

      if (reverseGeocode.length > 0) {
        const address = reverseGeocode[0];
        const locationString = [
          address.city || address.subregion,
          address.region || address.country,
        ]
          .filter(Boolean)
          .join(', ');
        
        setCurrentLocation(locationString || 'Goa, India');
      } else {
        setCurrentLocation('Goa, India');
      }
    } catch (error) {
      console.error('Error getting location:', error);
      setCurrentLocation('Goa, India');
    } finally {
      setLocationLoading(false);
    }
  };

  const getUserFromStorage = async () => {
  try {
    const jsonValue = await AsyncStorage.getItem('user');
    if (jsonValue != null) {
      return JSON.parse(jsonValue);
    }
    return null;
  } catch (error) {
    console.error('Error fetching user from AsyncStorage:', error);
    return null;
  }
};

// Function to fetch preferred places for current user
 const getPreferredPlaces = async () => {
  try {
    
    // 1️⃣ Get user from AsyncStorage
    const uid = auth.currentUser?.uid
    console.log('Current User UID:', uid);
    if (!uid) {
      console.warn('User not found');
      return [];
    }

    // 2️⃣ Create Firestore query
    const preferredPlacesRef = collection(db, 'prefered_places');
    const q = query(preferredPlacesRef, where('userId', '==', uid));

    // 3️⃣ Execute query
    const querySnapshot = await getDocs(q);

    // 4️⃣ Map results and add static images
    const preferredPlaces = querySnapshot.docs.map((doc, index) => {
      const placeData: any = {
        id: doc.id,
        ...doc.data(),
      };
      
      // Ensure each place has an image
      if (!placeData.image || placeData.image.trim() === '') {
        placeData.image = getStaticPlaceImage(placeData, index);
      }
      
      return placeData;
    });

    console.log('Fetched preferred places:', preferredPlaces);
    return preferredPlaces;
  } catch (error) {
    console.error('Error fetching preferred places:', error);
    return [];
  }
};



 // Get location on mount
  useEffect(() => {
    getCurrentLocation();
  }, []);

 useFocusEffect(
    useCallback(() => {
      const fetchPlaces = async () => {
    const places = await getPreferredPlaces();
    console.log('Preferred Places:', places);
    setPlacesData(places);
    setFilteredPlaces(places);
    // You can set these places to state if needed
  };

  fetchPlaces();

      // optional cleanup when screen goes out of focus
      return () => {
        console.log('🚫 Screen unfocused');
      };
    }, []))

  // Filter places when search query changes
  useEffect(() => {
    if (!searchQuery.trim()) {
      setFilteredPlaces(placesData);
    } else {
      const query = searchQuery.toLowerCase();
      const filtered = placesData.filter(place =>
        place.name?.toLowerCase().includes(query) ||
        place.location?.toLowerCase().includes(query) ||
        place.tag?.toLowerCase().includes(query) ||
        place.description?.toLowerCase().includes(query)
      );
      setFilteredPlaces(filtered);
    }
  }, [searchQuery, placesData]);


  // Helper function to get tag background color
  const getTagBgColor = (color:any) => {
    const colors: any = {
      green: 'bg-green-50',
      yellow: 'bg-yellow-50',
      blue: 'bg-blue-50',
      purple: 'bg-purple-50',
      red: 'bg-red-50'
    };
    return colors[color] || 'bg-gray-50';
  };

  // Helper function to get tag text color
  const getTagTextColor = (color:any) => {
    const colors: any = {
      green: 'text-green-600',
      yellow: 'text-yellow-900',
      blue: 'text-blue-600',
      purple: 'text-purple-600',
      red: 'text-red-600'
    };
    return colors[color] || 'text-gray-600';
  };

  // Helper function to get crowd dot color
  const getCrowdDotColor = (color:any) => {
    const colors: any = {
      green: 'bg-green-500',
      yellow: 'bg-yellow-500',
      red: 'bg-red-500',
      blue: 'bg-blue-500'
    };
    return colors[color] || 'bg-gray-500';
  };

  const navigation = useNavigation<any>()

  // Split places into different sections
  const featuredPlace = filteredPlaces[0];
  const gridPlaces = filteredPlaces.slice(1, 3);
  const listPlaces = filteredPlaces.slice(3);

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />
      
      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
      {/* Header */}
      <View className="bg-white px-5 pt-7 pb-5 shadow-sm">
        <View className="flex-row justify-between items-center mb-5">
          <View>
            <View className="flex-row items-center">
              {/* <Text className="text-2xl font-bold text-blue-500">TO</Text>
              <Text className="text-2xl font-bold text-green-500">U</Text>
              <Text className="text-2xl font-bold text-red-500">R</Text>
              <Text className="text-2xl font-bold text-purple-500">Z</Text>
              <Text className="text-2xl font-bold text-yellow-500">Y</Text> */}
              <Image 
                source={require('../assets/tourzy-logo.png')}
                style={{ width: 100, height: 20 }}
              />
            </View>
            <View className="flex-row items-center mt-1">
              <Ionicons name="location" size={12} color="#666" style={{ marginRight: 2 }} />
              {locationLoading ? (
                <View className="flex-row items-center">
                  <ActivityIndicator size="small" color="#666" />
                  <Text className="text-xs text-gray-600 ml-1">Getting location...</Text>
                </View>
              ) : (
                <Text className="text-xs text-gray-600">{currentLocation}</Text>
              )}
            </View>
          </View>
          <View className="flex-row gap-3 items-center">
            <TouchableOpacity 
              onPress={() => navigation.navigate('social')}
              className="w-10 h-10 bg-purple-100 rounded-full items-center justify-center">
              <Ionicons name="images-outline" size={20} color="#8b5cf6" />
            </TouchableOpacity>
            <TouchableOpacity 
              onPress={() => navigation.navigate('Profile')}
              className="w-10 h-10 bg-blue-500 rounded-full items-center justify-center shadow-md"
            >
              <Ionicons name="person-outline" size={18} color="#fff" />
            </TouchableOpacity>
            <TouchableOpacity 
              onPress={() => {
                auth.signOut().then(() => navigation.navigate('userLogin'));
              }}
              className="w-10 h-10 bg-red-100 rounded-full items-center justify-center">
              <Ionicons name="log-out-outline" size={20} color="#ef4444" />
            </TouchableOpacity>
          </View>
        </View>
        
        {/* Search Bar */}
        <View className="flex-row gap-2">
          <View className="flex-1 flex-row items-center bg-gray-100 rounded-xl px-4 py-3.5">
            <Ionicons name="search" size={18} color="#999" />
            <TextInput
              value={searchQuery}
              onChangeText={setSearchQuery}
              placeholder="Discover amazing places..."
              placeholderTextColor="#9ca3af"
              className="flex-1 ml-2 text-gray-900"
            />
            {searchQuery ? (
              <TouchableOpacity onPress={() => setSearchQuery('')}>
                <Ionicons name="close-circle" size={20} color="#999" />
              </TouchableOpacity>
            ) : null}
          </View>
          {/* <TouchableOpacity className="bg-blue-500 rounded-xl px-4 justify-center items-center shadow-md">
            <Ionicons name="options-outline" size={18} color="#fff" />
          </TouchableOpacity> */}
        </View>
      </View>

      {/* Tabs */}
      <View className="bg-white mt-1 py-4 shadow-sm">
        <ScrollView horizontal showsHorizontalScrollIndicator={false} className="px-3">
          <TouchableOpacity className="bg-blue-500 rounded-full px-5 py-2.5 mr-2 flex-row items-center shadow-md">
            <Ionicons name="compass" size={18} color="#fff" />
            <Text className="text-white font-bold ml-2">Discover</Text>
          </TouchableOpacity>
          <TouchableOpacity 
          onPress={() => navigation.navigate('crowd')}
          className="bg-white rounded-full px-5 py-2.5 mr-2 flex-row items-center border border-gray-200">
            <Ionicons name="people-outline" size={18} color="#666" />
            <Text className="text-gray-700 font-semibold ml-2">Crowd</Text>
          </TouchableOpacity>
          <TouchableOpacity 
          onPress={() => navigation.navigate('priceGuide')}
          className="bg-white rounded-full px-5 py-2.5 mr-2 flex-row items-center border border-gray-200">
            <Ionicons name="wallet-outline" size={18} color="#666" />
            <Text className="text-gray-700 font-semibold ml-2">Prices</Text>
          </TouchableOpacity>
          <TouchableOpacity 
          onPress={() => navigation.navigate('Hidden')}
          className="bg-white rounded-full px-5 py-2.5 mr-2 flex-row items-center border border-gray-200">
            <Ionicons name="diamond-outline" size={18} color="#666" />
            <Text className="text-gray-700 font-semibold ml-2">Hidden</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>

      {/* Quick Stats Banner */}
      <View className="px-5 pt-5 pb-3">
        <View className="bg-blue-600 rounded-2xl p-4 shadow-lg" style={{ position: 'relative' }}>
          <LinearGradient
            colors={['#2563eb', '#7c3aed']}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, borderRadius: 16 }}
          />
          <View className="flex-row items-center mb-4 justify-between">
            <View className="flex-1 flex-row items-center">
              <Ionicons name="stats-chart" size={22} color="#fff" style={{ marginRight: 8 }} />
              <View>
                <Text className="text-white text-lg font-bold mb-1">Your Adventure Stats</Text>
                <Text className="text-white/80 text-xs">Track your exploration journey</Text>
              </View>
            </View>
          </View>
          
          <View className="flex-row mt-4 gap-3">
            <View className="flex-1 bg-white/20 rounded-xl p-3 items-center">
              <Text className="text-white text-2xl font-bold">{filteredPlaces.length}</Text>
              <Text className="text-white/90 text-xs mt-1">{searchQuery ? 'Found' : 'For You'}</Text>
            </View>
            <View className="flex-1 bg-white/20 rounded-xl p-3 items-center">
              <Text className="text-white text-2xl font-bold">{placesData.length}</Text>
              <Text className="text-white/90 text-xs mt-1">Total</Text>
            </View>
            <View className="flex-1 bg-white/20 rounded-xl p-3 items-center">
              <Text className="text-white text-2xl font-bold">8</Text>
              <Text className="text-white/90 text-xs mt-1">Saved</Text>
            </View>
          </View>
        </View>
      </View>

      {/* Quick Categories */}
      <View className="px-5 py-3">
        <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row gap-3">
          <TouchableOpacity 
            onPress={() => navigation.navigate('itinerary')}
            className="bg-blue-600 rounded-2xl p-4 items-center shadow-md" style={{ width: 100 }}>
            <View className="w-12 h-12 bg-white/30 rounded-full items-center justify-center mb-2">
              <Ionicons name="calendar" size={24} color="#fff" />
            </View>
            <Text className="text-white text-xs font-bold">Itinerary</Text>
          </TouchableOpacity>
          <TouchableOpacity 
            onPress={() => navigation.navigate('stores')}
            className="bg-amber-500 rounded-2xl p-4 items-center shadow-md" style={{ width: 100 }}>
            <View className="w-12 h-12 bg-white/30 rounded-full items-center justify-center mb-2">
              <Ionicons name="storefront" size={24} color="#fff" />
            </View>
            <Text className="text-white text-xs font-bold">Stores</Text>
          </TouchableOpacity>

          
          <TouchableOpacity
          onPress={() => navigation.navigate('social')}
          className="bg-green-500 rounded-2xl p-4 items-center shadow-md" style={{ width: 100 }}>
            <View className="w-12 h-12 bg-white/30 rounded-full items-center justify-center mb-2">
              <FontAwesome5 name="landmark" size={20} color="#fff" />
            </View>
            <Text className="text-white text-xs font-bold">Community</Text>
          </TouchableOpacity>
          
     
          
         
        </ScrollView>
      </View>

      {/* Featured Place - Hero Card */}
      {featuredPlace && (
        <View className="px-5 pt-4 pb-3">
          <View className="flex-row items-center justify-between mb-3">
            <View className="flex-row items-center">
              <Ionicons name="sparkles" size={20} color="#FFD700" style={{ marginRight: 6 }} />
              <Text className="text-xl font-bold text-gray-900">Featured for You</Text>
            </View>
            {/* <TouchableOpacity>
              <Text className="text-blue-500 text-sm font-semibold">See all</Text>
            </TouchableOpacity> */}
          </View>
          
          <TouchableOpacity 
            onPress={() => navigation.navigate('detail', { place: featuredPlace })}
            className="rounded-3xl overflow-hidden shadow-2xl"
            activeOpacity={0.95}
          >
            <ImageBackground
              source={{ uri: getStaticPlaceImage(featuredPlace, 0) }}
              className="h-64"
              imageStyle={{ borderRadius: 24 }}
              resizeMode="cover"
            >
              <LinearGradient
                colors={['rgba(0,0,0,0.1)', 'rgba(0,0,0,0.8)']}
                style={{ flex: 1, justifyContent: 'space-between', padding: 20 }}
              >
                {/* Top badges */}
                <View className="flex-row items-center justify-between">
                  <View className={`${getTagBgColor(featuredPlace.tagColor)} rounded-full px-3 py-1.5`}>
                    <Text className={`text-xs font-bold ${getTagTextColor(featuredPlace.tagColor)}`}>
                      {featuredPlace.tag}
                    </Text>
                  </View>
                  
                  <View className="bg-black/50 rounded-xl px-3 py-1.5 flex-row items-center">
                    <Ionicons name="star" size={14} color="#FFD700" />
                    <Text className="text-white text-sm font-bold ml-1">{featuredPlace.rating}</Text>
                  </View>
                </View>

                {/* Bottom info */}
                <View>
                  <Text className="text-white text-2xl font-bold mb-1">{featuredPlace.name}</Text>
                  <View className="flex-row items-center mb-3">
                    <Ionicons name="location" size={14} color="rgba(255,255,255,0.9)" style={{ marginRight: 4 }} />
                    <Text className="text-white/90 text-sm">{featuredPlace.location}</Text>
                  </View>
                  
                  <View className="flex-row items-center justify-between">
                    <View className="flex-row items-center bg-white/20 rounded-lg px-3 py-2">
                      <View className={`w-2 h-2 rounded-full ${getCrowdDotColor(featuredPlace.crowdColor)} mr-2`} />
                      <Text className="text-white text-xs font-medium">{featuredPlace.crowdLevel} crowd</Text>
                    </View>
                    
                    <TouchableOpacity className="bg-white rounded-xl px-5 py-2.5 shadow-md">
                      <Text className="text-blue-600 text-sm font-bold">Explore →</Text>
                    </TouchableOpacity>
                  </View>
                </View>
              </LinearGradient>
            </ImageBackground>
          </TouchableOpacity>
        </View>
      )}

      {/* Grid Layout - Two Cards */}
      {gridPlaces.length >= 2 && (
        <View className="px-5 pt-3 pb-3">
          <View className="flex-row items-center mb-3">
            <Ionicons name="map" size={20} color="#1f2937" style={{ marginRight: 6 }} />
            <Text className="text-xl font-bold text-gray-900">Explore More</Text>
          </View>
          
          <View className="flex-row gap-3">
            {gridPlaces.map((place, index) => (
              <TouchableOpacity
                key={place.id}
                onPress={() => navigation.navigate('detail', { place })}
                className="flex-1 rounded-2xl overflow-hidden shadow-lg"
                activeOpacity={0.9}
              >
                <ImageBackground
                  source={{ uri: getStaticPlaceImage(place, index + 1) }}
                  className="h-48"
                  imageStyle={{ borderRadius: 16 }}
                  resizeMode="cover"
                >
                  <LinearGradient
                    colors={['transparent', 'rgba(0,0,0,0.85)']}
                    style={{ flex: 1, justifyContent: 'space-between', padding: 12 }}
                  >
                    {/* Tag */}
                    <View className="self-start">
                      <View className={`${getTagBgColor(place.tagColor)} rounded-full px-2.5 py-1`}>
                        <Text className={`text-xs font-bold ${getTagTextColor(place.tagColor)}`}>
                          {place.tag}
                        </Text>
                      </View>
                    </View>

                    {/* Info */}
                    <View>
                      <Text className="text-white text-base font-bold mb-1">{place.name}</Text>
                      <View className="flex-row items-center justify-between">
                        <View className="bg-white/20 rounded-lg px-2 py-1 flex-row items-center">
                          <Ionicons name="star" size={12} color="#FFD700" />
                          <Text className="text-white text-xs font-bold ml-1">{place.rating}</Text>
                        </View>
                        <View className="flex-row items-center">
                          <View className={`w-1.5 h-1.5 rounded-full ${getCrowdDotColor(place.crowdColor)} mr-1`} />
                          <Text className="text-white text-xs">{place.crowdLevel}</Text>
                        </View>
                      </View>
                    </View>
                  </LinearGradient>
                </ImageBackground>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      )}

      {/* List Layout - Rest of the places */}
      {listPlaces.length > 0 && (
        <View className="px-5 pt-3 pb-6">
          <View className="flex-row items-center mb-3">
            <Ionicons name="location" size={20} color="#1f2937" style={{ marginRight: 6 }} />
            <Text className="text-xl font-bold text-gray-900">All Recommendations</Text>
          </View>
          
          {listPlaces.map((place, index) => (
            <TouchableOpacity 
              key={place.id}
              onPress={() => navigation.navigate('detail', { place })}
              className="bg-white rounded-2xl mb-3 overflow-hidden shadow-lg"
              activeOpacity={0.95}
            >
              <View className="flex-row">
                <ImageBackground
                  source={{ uri: getStaticPlaceImage(place, index + 3) }}
                  className="w-32 h-32"
                  imageStyle={{ borderTopLeftRadius: 16, borderBottomLeftRadius: 16 }}
                  resizeMode="cover"
                >
                  <LinearGradient
                    colors={['transparent', 'rgba(0,0,0,0.6)']}
                    style={{ flex: 1, justifyContent: 'flex-end', padding: 8 }}
                  >
                    <View className="bg-white/90 rounded-lg px-2 py-1 self-start flex-row items-center">
                      <Ionicons name="star" size={12} color="#FFD700" />
                      <Text className="text-xs font-bold ml-1">{place.rating}</Text>
                    </View>
                  </LinearGradient>
                </ImageBackground>
                
                <View className="flex-1 p-3 justify-between">
                  <View>
                    <Text className="text-base font-bold text-gray-900 mb-1">{place.name}</Text>
                    <View className="flex-row items-center mb-2">
                      <Ionicons name="location" size={12} color="#666" style={{ marginRight: 2 }} />
                      <Text className="text-xs text-gray-600">{place.location}</Text>
                    </View>
                    <Text className="text-xs text-gray-500 leading-4" numberOfLines={2}>
                      {place.description}
                    </Text>
                  </View>
                  
                  <View className="flex-row items-center gap-2 mt-2">
                    <View className={`${getTagBgColor(place.tagColor)} px-2.5 py-1 rounded-lg`}>
                      <Text className={`text-xs font-semibold ${getTagTextColor(place.tagColor)}`}>
                        {place.tag}
                      </Text>
                    </View>
                    <View className="flex-row items-center">
                      <View className={`w-1.5 h-1.5 rounded-full ${getCrowdDotColor(place.crowdColor)} mr-1`} />
                      <Text className="text-xs text-gray-600">{place.crowdLevel}</Text>
                    </View>
                  </View>
                </View>
              </View>
            </TouchableOpacity>
          ))}
        </View>
      )}

      {/* Empty State */}
      {placesData.length === 0 && (
        <View className="px-5 py-12 items-center">
          <View className="w-24 h-24 bg-gray-100 rounded-full items-center justify-center mb-4">
            <Ionicons name="map-outline" size={48} color="#999" />
          </View>
          <Text className="text-gray-900 text-xl font-bold mb-2">No Places Yet</Text>
          <Text className="text-gray-600 text-sm text-center mb-6">
            Set your preferences to get personalized recommendations
          </Text>
          <TouchableOpacity 
            onPress={() => navigation.navigate('preference')}
            className="bg-blue-500 rounded-full px-6 py-3 shadow-md flex-row items-center"
          >
            <Text className="text-white text-sm font-bold mr-2">Set Preferences</Text>
            <Ionicons name="settings" size={16} color="#fff" />
          </TouchableOpacity>
        </View>
      )}

      {/* No Search Results */}
      {placesData.length > 0 && filteredPlaces.length === 0 && searchQuery && (
        <View className="px-5 py-12 items-center">
          <View className="w-24 h-24 bg-gray-100 rounded-full items-center justify-center mb-4">
            <Ionicons name="search-outline" size={48} color="#999" />
          </View>
          <Text className="text-gray-900 text-xl font-bold mb-2">No Results Found</Text>
          <Text className="text-gray-600 text-sm text-center mb-6">
            No places match "{searchQuery}". Try a different search term.
          </Text>
          <TouchableOpacity 
            onPress={() => setSearchQuery('')}
            className="bg-blue-500 rounded-full px-6 py-3 shadow-md"
          >
            <Text className="text-white text-sm font-bold">Clear Search</Text>
          </TouchableOpacity>
        </View>
      )}

      {/* Bottom Spacing */}
      <View className="h-6" />
    </ScrollView>
    </View>
  );
}


export default HomeScreen