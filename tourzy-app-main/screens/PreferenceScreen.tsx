import React, { useEffect, useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView, SafeAreaView, StatusBar, Dimensions, Animated, ActivityIndicator } from 'react-native';
import Svg, { Circle } from 'react-native-svg';
import { auth, db } from '../firebase';
import { addDoc, collection, getDocs, query, where, deleteDoc, doc } from 'firebase/firestore';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

// Dotted background component
function DottedBackground() {
  const dots = [];
  const rows = 50;
  const cols = 12;
  const dotSpacing = 35;
  
  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      dots.push(
        <Circle
          key={`${row}-${col}`}
          cx={col * dotSpacing + 20}
          cy={row * dotSpacing + 20}
          r="1.5"
          fill="#9CA3AF"
          opacity="0.3"
        />
      );
    }
  }
  
  return (
    <Svg 
      style={{ 
        position: 'absolute', 
        width: '100%', 
        height: '100%',
        top: 0,
        left: 0
      }}
    >
      {dots}
    </Svg>
  );
}
import AsyncStorage from "@react-native-async-storage/async-storage";
import { useNavigation } from '@react-navigation/native';

export default function ChooseTerrainScreen() {
  const [selectedTerrains, setSelectedTerrains] = useState([]);
  const [selectedActivities, setSelectedActivities] = useState([]);
const [user, setUser] = useState<any>(null);

const [loading, setLoading] = useState(false);

const navigation = useNavigation()
 const getUserFromStorage = async () => {
  try {
    const jsonValue = await AsyncStorage.getItem("user"); // or "userData" based on what you used

    if (jsonValue) {
    
      return auth.currentUser?.uid;
    } else {
      console.log("⚠️ No user data found in AsyncStorage");
      return null;
    }
  } catch (error) {
    console.error("❌ Error fetching user from storage:", error);
    return null;
  }
};

useEffect(() => {
  getUserFromStorage();
}, []);
  
  const terrains = [
    { id: 1, name: 'urban' },
    { id: 2, name: 'coastal' },
    { id: 3, name: 'hilly' },
    { id: 4, name: 'islet' },
    { id: 5, name: 'rural' },
  ];

  const activities = [
    { id: 1, name: 'swimmin' },
    { id: 2, name: 'surfing' },
    { id: 3, name: 'water sports' },
    { id: 4, name: 'trekking' },
    { id: 5, name: 'camping' },
    { id: 6, name: 'cycling' },
    { id: 7, name: 'kayaking' },
    { id: 8, name: 'paragliding' },
    { id: 9, name: 'snorkeling' },
    { id: 10, name: 'fishing' },
    { id: 11, name: 'wildlife safari' },
    { id: 12, name: 'photography' },
  ];
  
  const toggleTerrain = (terrainId) => {
    if (selectedTerrains.includes(terrainId)) {
      setSelectedTerrains(selectedTerrains.filter(id => id !== terrainId));
    } else {
      setSelectedTerrains([...selectedTerrains, terrainId]);
    }
  };

  const toggleActivity = (activityId) => {
    if (selectedActivities.includes(activityId)) {
      setSelectedActivities(selectedActivities.filter(id => id !== activityId));
    } else {
      setSelectedActivities([...selectedActivities, activityId]);
    }
  };
  
  const isTerrainSelected = (terrainId) => selectedTerrains.includes(terrainId);
  const isActivitySelected = (activityId) => selectedActivities.includes(activityId);

  const handleProceed = async () => {



    const selectedTerrainsData = terrains.filter(t => selectedTerrains.includes(t.id));
    const selectedActivitiesData = activities.filter(a => selectedActivities.includes(a.id));

    const result = {
      terrains: selectedTerrainsData.map(t => t.name),
      activities: selectedActivitiesData.map(a => a.name),
      totalSelections: {
        terrains: selectedTerrains.length,
        activities: selectedActivities.length
      },
      timestamp: new Date().toISOString(),
      fullData: {
        terrains: selectedTerrainsData,
        activities: selectedActivitiesData
      }
    };

    console.log('=== USER SELECTIONS ===');
    console.log(JSON.stringify(result, null, 2));
    console.log('=====================');
    setLoading(true);
    const data = fetch('https://n8n.srv1034714.hstgr.cloud/webhook/2fedf289-4390-409e-a793-33992b5fc315', {
      method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(result),
    })


    const response = await data;
    const json = await response.json();
    console.log('Response from server:', json);
    await uploadPlaces(json.output.places);
    setLoading(false);
    navigation.navigate('Home');
  };

  


async function uploadPlaces(places: any[]) {
    const placesRef = collection(db, "prefered_places");
    const userId = auth.currentUser?.uid;

    try {
        // First, delete all existing preferred places for this user
        const existingPlacesQuery = query(placesRef, where('userId', '==', userId));
        const existingPlacesSnapshot = await getDocs(existingPlacesQuery);
        
        console.log(`🗑️ Deleting ${existingPlacesSnapshot.docs.length} existing places...`);
        for (const docSnapshot of existingPlacesSnapshot.docs) {
            await deleteDoc(doc(db, "prefered_places", docSnapshot.id));
        }
        
        // Then, upload new places
        console.log(`📤 Uploading ${places.length} new places...`);
        for (const place of places) {
            await addDoc(placesRef, { ...place, userId });
            console.log(`Uploaded: ${place.name}`);
        }
        console.log("✅ All places uploaded successfully!");
    } catch (error) {
        console.error("❌ Error uploading places:", error);
    }
}

  
  // Calculate card width based on screen width
  const cardWidth = (SCREEN_WIDTH - 65) / 3; // 3 cards with proper spacing
  
  const totalSelected = selectedTerrains.length + selectedActivities.length;
  if (loading){
    return (
      <SafeAreaView className="flex-1 bg-gray-200 justify-center items-center">
       <Text className="text-lg font-semibold text-gray-700">Ai is thinking...</Text>
      <ActivityIndicator size="large" color="#2563EB" className="mt-4" />
      </SafeAreaView>
    );
  }
  
  return (
    <SafeAreaView className="flex-1 bg-gray-200">
      <StatusBar barStyle="dark-content" />
      <View className="flex-1 relative">
        {/* Dotted Background */}
        <DottedBackground />
        
        {/* Content */}
        <ScrollView 
          className="flex-1"
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{ paddingBottom: 100 }}
        >
          <View className="px-5">
            {/* Header */}
            <View className="flex-row justify-between items-center mt-10 mb-8">
              <Text className="text-2xl font-bold text-black">
                Choose your terrain
              </Text>
              <View className="bg-gray-300 px-4 py-2 rounded-full">
                <Text className="text-sm font-semibold text-gray-700">
                  {selectedTerrains.length} Selected
                </Text>
              </View>
            </View>
            
            {/* Terrain Cards Grid */}
            <View className="flex-row flex-wrap mb-10" style={{ gap: 12 }}>
              {terrains.map((terrain) => {
                const selected = isTerrainSelected(terrain.id);
                return (
                  <View
                    key={terrain.id}
                    style={{
                      width: cardWidth,
                      aspectRatio: 0.85,
                      backgroundColor: '#fff',
                      borderRadius: 20,
                      padding: 16,
                      shadowColor: '#000',
                      shadowOffset: { width: 0, height: 4 },
                      shadowOpacity: 0.08,
                      shadowRadius: 12,
                      elevation: 4,
                      justifyContent: 'space-between',
                      borderWidth: selected ? 2.5 : 0,
                      borderColor: selected ? '#10B981' : 'transparent'
                    }}
                  >
                    {/* Terrain Name */}
                    <View className="flex-1 justify-center">
                      <Text className="text-base font-semibold text-black text-center">
                        {terrain.name}
                      </Text>
                    </View>
                    
                    {/* Select Button */}
                    <TouchableOpacity
                      onPress={() => toggleTerrain(terrain.id)}
                      className="rounded-lg py-2 px-1 items-center"
                      style={{
                        backgroundColor: selected ? '#10B981' : '#2563EB',
                      }}
                      activeOpacity={0.7}
                    >
                      <Text className="text-white text-xs font-semibold">
                        {selected ? 'Selected' : 'Select'}
                      </Text>
                    </TouchableOpacity>
                  </View>
                );
              })}
            </View>

            {/* Activities Section */}
            <View className="mb-8">
              {/* Activities Header */}
              <View className="flex-row justify-between items-center mb-6">
                <Text className="text-2xl font-bold text-black">
                  Choose activities
                </Text>
                <View className="bg-gray-300 px-4 py-2 rounded-full">
                  <Text className="text-sm font-semibold text-gray-700">
                    {selectedActivities.length} Selected
                  </Text>
                </View>
              </View>

              {/* Activities Cards Grid */}
              <View className="flex-row flex-wrap" style={{ gap: 12 }}>
                {activities.map((activity) => {
                  const selected = isActivitySelected(activity.id);
                  return (
                    <View
                      key={activity.id}
                      style={{
                        width: cardWidth,
                        aspectRatio: 0.85,
                        backgroundColor: '#fff',
                        borderRadius: 20,
                        padding: 16,
                        shadowColor: '#000',
                        shadowOffset: { width: 0, height: 4 },
                        shadowOpacity: 0.08,
                        shadowRadius: 12,
                        elevation: 4,
                        justifyContent: 'space-between',
                        borderWidth: selected ? 2.5 : 0,
                        borderColor: selected ? '#10B981' : 'transparent'
                      }}
                    >
                      {/* Activity Content */}
                      <View className="flex-1 justify-center items-center">
                        {/* <Text className="text-3xl mb-2">{activity.emoji}</Text> */}
                        <Text className="text-sm font-semibold text-black text-center">
                          {activity.name}
                        </Text>
                      </View>
                      
                      {/* Select Button */}
                      <TouchableOpacity
                        onPress={() => toggleActivity(activity.id)}
                        className="rounded-lg py-2 px-1 items-center"
                        style={{
                          backgroundColor: selected ? '#10B981' : '#2563EB',
                        }}
                        activeOpacity={0.7}
                      >
                        <Text className="text-white text-xs font-semibold">
                          {selected ? 'Selected' : 'Select'}
                        </Text>
                      </TouchableOpacity>
                    </View>
                  );
                })}
              </View>
            </View>
          </View>
        </ScrollView>
        
        {/* Fixed Bottom Button Container */}
        <View 
          className="absolute bottom-0 left-0 right-0 bg-gray-200 px-5 pb-6 pt-4"
          style={{
            shadowColor: '#000',
            shadowOffset: { width: 0, height: -4 },
            shadowOpacity: 0.1,
            shadowRadius: 8,
            elevation: 10,
          }}
        >
          <TouchableOpacity
            onPress={handleProceed}
            className="bg-blue-600 py-4 rounded-2xl items-center"
            style={{
              shadowColor: '#2563EB',
              shadowOffset: { width: 0, height: 6 },
              shadowOpacity: 0.25,
              shadowRadius: 12,
              elevation: 8,
            }}
            activeOpacity={0.85}
          >
            <Text className="text-white text-lg font-bold">
              {loading ? "Ai is thinking..." : `Proceed to next ${totalSelected > 0 && `(${totalSelected} selected)`}`}
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
}