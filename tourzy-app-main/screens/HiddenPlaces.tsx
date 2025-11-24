import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  Image,
  TextInput,
  StatusBar,
  ImageBackground,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialIcons } from '@expo/vector-icons';
import { auth } from '../firebase';

// Hidden places data with ultra-rare spots
const hiddenPlacesData = [
  {
    id: 1,
    name: 'Cabo de Rama',
    location: '1 hr from capital city Panjim',
    rating: 4.5,
    description: 'Cabo de Rama is a historic fort and a secluded beach in South Goa, India, known for its panoramic views and rich history.',
    image: 'https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=400',
    visitors: '< 1000/month',
    rarity: 'Ultra Rare',
  },
  {
    id: 2,
    name: 'Galgibaga Beach',
    location: '1 hr from capital city Panjim',
    rating: 4.2,
    description: 'A peaceful South Goa beach known for its turtle nesting sites and pristine environment.',
    image: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
    visitors: '< 500/month',
    rarity: 'Rare',
  },
  {
    id: 3,
    name: 'Arvalem Caves',
    location: '45 min from capital city Panjim',
    rating: 4.3,
    description: 'Ancient rock-cut caves dating back to the 6th century, featuring Buddhist sculptures and inscriptions.',
    image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
    visitors: '< 800/month',
    rarity: 'Rare',
  },
  {
    id: 4,
    name: 'Netravali Bubble Lake',
    location: '1.5 hr from capital city Panjim',
    rating: 4.7,
    description: 'A mysterious lake where bubbles rise when you clap or make noise - a unique natural phenomenon.',
    image: 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=400',
    visitors: '< 600/month',
    rarity: 'Ultra Rare',
  },
];

function HiddenPlaces() {
  const navigation = useNavigation<any>();
  const [activeTab, setActiveTab] = useState('Hidden');
  const [searchQuery, setSearchQuery] = useState('');

  const ultraRareCount = hiddenPlacesData.filter(p => p.rarity === 'Ultra Rare').length;
  const totalPlacesCount = hiddenPlacesData.length;

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />
      
      <ScrollView className="flex-1" showsVerticalScrollIndicator={false} bounces={true}>
        {/* Header */}
        <View className="bg-white px-5 pt-12 pb-5 shadow-sm">
          <View className="flex-row justify-between items-center mb-5">
            <View>
              <View className="flex-row items-center">
              <Image 
                source={require('../assets/tourzy-logo.png')}
                style={{ width: 100, height: 20 }}
              />
              </View>
              <Text className="text-xs text-gray-600 mt-1">Farmagudi, Goa</Text>
            </View>
            <View className="flex-row gap-4 items-center">
              <TouchableOpacity>
                <Ionicons name="notifications-outline" size={24} color="#666" />
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => navigation.navigate('Home')}
                className="w-10 h-10 bg-blue-500 rounded-full items-center justify-center"
              >
                <Ionicons name="home" size={20} color="#fff" />
              </TouchableOpacity>
            </View>
          </View>

          {/* Search Bar */}
          <View className="flex-row gap-2">
            <View className="flex-1 flex-row items-center bg-gray-100 rounded-xl px-4 py-3">
              <Ionicons name="search" size={18} color="#9ca3af" />
              <TextInput
                placeholder="Search for places, experiences..."
                placeholderTextColor="#9CA3AF"
                value={searchQuery}
                onChangeText={setSearchQuery}
                className="flex-1 ml-2 text-sm text-gray-700"
              />
            </View>
            <TouchableOpacity className="bg-blue-500 rounded-xl px-4 justify-center items-center">
              <Ionicons name="options-outline" size={18} color="#fff" />
            </TouchableOpacity>
          </View>
        </View>

        {/* Tabs */}
        <View className="bg-white mt-1 py-4 shadow-sm">
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            className="px-3"
          >
            {['Discover', 'Crowd', 'Prices', 'Hidden'].map((tab) => (
              <TouchableOpacity
                key={tab}
                onPress={() => {
                  setActiveTab(tab);
                  if (tab === 'Discover') {
                    navigation.navigate('Home');
                  }else if (tab === 'Hidden') {
                    navigation.navigate('Hidden');
                  }
                  else if (tab === 'Crowd') {
                    navigation.navigate('crowd');
                  }
                  else if (tab === 'Prices') {
                    navigation.navigate('priceGuide');
                  }
                  else if (tab === 'Discover') {
                    navigation.navigate('crowd');
                  }
                  else if (tab === 'Prices') {
                    navigation.navigate('priceGuide');
                  } 
                }}
                className={`rounded-full px-5 py-2.5 mr-2 flex-row items-center ${
                  activeTab === tab
                    ? 'bg-blue-500'
                    : 'bg-white border border-gray-200'
                }`}
              >
                <Ionicons 
                  name={
                    tab === 'Discover' ? 'compass' :
                    tab === 'Crowd' ? 'people' :
                    tab === 'Prices' ? 'wallet' : 'eye'
                  }
                  size={18}
                  color={activeTab === tab ? '#fff' : '#666'}
                />
                <Text
                  className={`font-semibold ml-2 ${
                    activeTab === tab ? 'text-white' : 'text-gray-600'
                  }`}
                >
                  {tab}
                </Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        {/* Hidden Places Hero Section */}
        <View className="px-5 py-4">
          <View className="rounded-3xl overflow-hidden shadow-2xl" style={{ position: 'relative' }}>
            <Image 
              source={{ uri: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800' }}
              style={{ position: 'absolute', width: '100%', height: '100%', opacity: 0.2, borderRadius: 24 }}
              resizeMode="cover"
            />
            <LinearGradient
              colors={['#1e3a8a', '#7c3aed']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={{ padding: 24, alignItems: 'center' }}
            >
              <View className="items-center">
                <View className="w-20 h-20 bg-yellow-400 rounded-full items-center justify-center mb-4 shadow-xl">
                  <Ionicons name="eye" size={40} color="#fff" />
                </View>
                <Text className="text-white text-3xl font-bold mb-2 text-center">Hidden Gems</Text>
                <Text className="text-white text-center text-sm px-6 opacity-95 mb-4">
                  Discover ultra-rare spots known only to locals
                </Text>
                
                {/* Mini Stats */}
                <View className="flex-row gap-6 mt-2">
                  <View className="items-center">
                    <Text className="text-yellow-300 text-2xl font-bold">{ultraRareCount}</Text>
                    <Text className="text-white text-xs opacity-90">Ultra Rare</Text>
                  </View>
                  <View className="w-px h-10 bg-white opacity-30" />
                  <View className="items-center">
                    <Text className="text-yellow-300 text-2xl font-bold">{totalPlacesCount}</Text>
                    <Text className="text-white text-xs opacity-90">Locations</Text>
                  </View>
                </View>
              </View>
            </LinearGradient>
          </View>
        </View>

        {/* Quick Access Filters */}
        <View className="px-5 py-3">
          <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row gap-2">
            <TouchableOpacity className="bg-blue-600 rounded-full px-5 py-2.5 flex-row items-center shadow-md">
              <Ionicons name="flame" size={16} color="#fff" style={{ marginRight: 6 }} />
              <Text className="text-white text-sm font-bold">All Places</Text>
            </TouchableOpacity>
          </ScrollView>
        </View>

        {/* Featured Location - Large Card */}
        <View className="px-5 pt-6 pb-4">
          <View className="flex-row items-center justify-between mb-4">
            <View className="flex-row items-center">
              <Ionicons name="flame" size={24} color="#f59e0b" style={{ marginRight: 6 }} />
              <Text className="text-2xl font-bold text-gray-900">Most Exclusive</Text>
            </View>
            <View className="bg-orange-100 rounded-full px-3 py-1">
              <Text className="text-orange-600 text-xs font-bold">FEATURED</Text>
            </View>
          </View>
          
          <TouchableOpacity
            className="rounded-3xl overflow-hidden shadow-2xl"
            activeOpacity={0.95}
          >
            <ImageBackground
              source={{ uri: hiddenPlacesData[0].image }}
              className="h-72"
              imageStyle={{ borderRadius: 24 }}
            >
              <LinearGradient
                colors={['transparent', 'rgba(0,0,0,0.9)']}
                style={{ flex: 1, justifyContent: 'flex-end', padding: 20 }}
              >
                {/* Ultra Rare Badge */}
                <View className="absolute top-4 left-4">
                  <LinearGradient
                    colors={['#f59e0b', '#ef4444']}
                    start={{ x: 0, y: 0 }}
                    end={{ x: 1, y: 0 }}
                    style={{ borderRadius: 20, paddingHorizontal: 12, paddingVertical: 6, flexDirection: 'row', alignItems: 'center' }}
                  >
                    <Ionicons name="sparkles" size={12} color="#fff" style={{ marginRight: 4 }} />
                    <Text className="text-white text-xs font-bold">ULTRA RARE</Text>
                  </LinearGradient>
                </View>

                {/* Rating Badge */}
                <View className="absolute top-4 right-4 bg-black/50 rounded-2xl px-3 py-2 flex-row items-center">
                  <Ionicons name="star" size={16} color="#fbbf24" />
                  <Text className="text-white text-base font-bold ml-1">{hiddenPlacesData[0].rating}</Text>
                </View>

                <View>
                  <Text className="text-white text-2xl font-bold mb-1">{hiddenPlacesData[0].name}</Text>
                  <View className="flex-row items-center mb-3">
                    <Ionicons name="location" size={14} color="#fff" />
                    <Text className="text-white/90 text-sm ml-1">{hiddenPlacesData[0].location}</Text>
                  </View>
                  
                  <View className="flex-row items-center justify-between">
                    <View className="flex-row items-center bg-white/20 rounded-xl px-3 py-2">
                      <Ionicons name="people" size={14} color="#fff" />
                      <Text className="text-white text-xs font-medium ml-2">{hiddenPlacesData[0].visitors}</Text>
                    </View>
                    
                    {/* <TouchableOpacity>
                      <LinearGradient
                        colors={['#3b82f6', '#8b5cf6']}
                        start={{ x: 0, y: 0 }}
                        end={{ x: 1, y: 0 }}
                        style={{ borderRadius: 12, paddingHorizontal: 20, paddingVertical: 12, flexDirection: 'row', alignItems: 'center' }}
                      >
                        <Text className="text-white text-sm font-bold mr-2">View Details</Text>
                        <Ionicons name="arrow-forward" size={16} color="#fff" />
                      </LinearGradient>
                    </TouchableOpacity> */}
                  </View>
                </View>
              </LinearGradient>
            </ImageBackground>
          </TouchableOpacity>
        </View>

        {/* Grid Layout - Other Hidden Places */}
        <View className="px-5 pt-4 pb-6">
          <View className="flex-row items-center mb-4">
            <MaterialIcons name="diamond" size={24} color="#3b82f6" style={{ marginRight: 6 }} />
            <Text className="text-xl font-bold text-gray-900">More Hidden Spots</Text>
          </View>
          
          {/* First Row - Two Cards */}
          <View className="flex-row gap-3 mb-3">
            {hiddenPlacesData.slice(1, 3).map((place, index) => (
              <TouchableOpacity
                key={place.id}
                className="flex-1 rounded-2xl overflow-hidden shadow-lg"
                activeOpacity={0.9}
              >
                <ImageBackground
                  source={{ uri: place.image }}
                  className="h-44"
                  imageStyle={{ borderRadius: 16 }}
                >
                  <LinearGradient
                    colors={['transparent', 'rgba(0,0,0,0.85)']}
                    style={{ flex: 1, justifyContent: 'space-between', padding: 12 }}
                  >
                    {/* Rarity Badge */}
                    <View className="self-start">
                      <View className="bg-blue-500 rounded-full px-2.5 py-1 flex-row items-center">
                        <MaterialIcons name="diamond" size={10} color="#fff" style={{ marginRight: 3 }} />
                        <Text className="text-white text-xs font-bold">Rare</Text>
                      </View>
                    </View>

                    {/* Info */}
                    <View>
                      <Text className="text-white text-base font-bold mb-0.5">{place.name}</Text>
                      <View className="flex-row items-center justify-between">
                        <View className="bg-white/20 rounded-lg px-2 py-1 flex-row items-center">
                          <Ionicons name="star" size={12} color="#fbbf24" />
                          <Text className="text-white text-xs font-bold ml-1">{place.rating}</Text>
                        </View>
                        {/* <TouchableOpacity className="bg-white rounded-lg px-3 py-1">
                          <Text className="text-blue-600 text-xs font-bold">View</Text>
                        </TouchableOpacity> */}
                      </View>
                    </View>
                  </LinearGradient>
                </ImageBackground>
              </TouchableOpacity>
            ))}
          </View>

          {/* Second Row - Single Wide Card */}
          {hiddenPlacesData.slice(3, 4).map((place) => (
            <TouchableOpacity
              key={place.id}
              className="rounded-2xl overflow-hidden shadow-lg mb-3"
              activeOpacity={0.9}
            >
              <ImageBackground
                source={{ uri: place.image }}
                className="h-52"
                imageStyle={{ borderRadius: 16 }}
              >
                <LinearGradient
                  colors={['rgba(0,0,0,0.3)', 'rgba(0,0,0,0.9)']}
                  style={{ flex: 1, justifyContent: 'space-between', padding: 16 }}
                >
                  {/* Top Section */}
                  <View className="flex-row items-start justify-between">
                    <LinearGradient
                      colors={['#f59e0b', '#ef4444']}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 0 }}
                      style={{ borderRadius: 20, paddingHorizontal: 12, paddingVertical: 6, flexDirection: 'row', alignItems: 'center' }}
                    >
                      <Ionicons name="sparkles" size={12} color="#fff" style={{ marginRight: 4 }} />
                      <Text className="text-white text-xs font-bold">ULTRA RARE</Text>
                    </LinearGradient>
                    
                    <View className="bg-black/50 rounded-xl px-3 py-1.5 flex-row items-center">
                      <Ionicons name="star" size={14} color="#fbbf24" />
                      <Text className="text-white text-sm font-bold ml-1">{place.rating}</Text>
                    </View>
                  </View>

                  {/* Bottom Section */}
                  <View>
                    <Text className="text-white text-xl font-bold mb-1">{place.name}</Text>
                    <Text className="text-white/90 text-xs mb-3">{place.description}</Text>
                    
                    <View className="flex-row items-center justify-between">
                      <View className="bg-white/20 rounded-lg px-3 py-2 flex-row items-center">
                        <Ionicons name="people" size={12} color="#fff" />
                        <Text className="text-white text-xs font-medium ml-2">{place.visitors}</Text>
                      </View>
                      
                      {/* <TouchableOpacity>
                        <LinearGradient
                          colors={['#8b5cf6', '#ec4899']}
                          start={{ x: 0, y: 0 }}
                          end={{ x: 1, y: 0 }}
                          style={{ borderRadius: 10, paddingHorizontal: 16, paddingVertical: 10, flexDirection: 'row', alignItems: 'center' }}
                        >
                          <Text className="text-white text-sm font-bold mr-2">Explore</Text>
                          <Ionicons name="arrow-forward" size={14} color="#fff" />
                        </LinearGradient>
                      </TouchableOpacity> */}
                    </View>
                  </View>
                </LinearGradient>
              </ImageBackground>
            </TouchableOpacity>
          ))}

          {/* Info Section */}
          <View className="bg-yellow-50 border border-yellow-200 rounded-2xl p-4 mt-4 flex-row items-start">
            <View className="w-10 h-10 bg-yellow-200 rounded-full items-center justify-center mr-3">
              <Ionicons name="bulb" size={20} color="#f59e0b" />
            </View>
            <View className="flex-1">
              <Text className="text-yellow-900 text-sm font-bold mb-1">Pro Tip</Text>
              <Text className="text-yellow-800 text-xs leading-5">
                Visit hidden places early morning or late evening for the best experience with fewer crowds!
              </Text>
            </View>
          </View>
        </View>

        {/* Bottom Spacing */}
        <View className="h-6" />
      </ScrollView>
    </View>
  );
}

export default HiddenPlaces;