import { useNavigation } from "@react-navigation/native";
import React, { useState } from "react";
import { View, ScrollView, Text, TouchableOpacity, Image } from "react-native";

function DetailScreen({ route }:any) {

    console.log(route)
  const [isFavorited, setIsFavorited] = useState(false);
  const navigation = useNavigation<any>()
  
  return (
    <ScrollView className="flex-1 bg-white">
      {/* Header Image with Overlay */}
      <View className="relative">
        <Image 
          source={{ uri: route.params.place.image }}
          className="w-full h-64"
        />
        <View className="absolute top-9 left-5 right-5 flex-row justify-between">
          <TouchableOpacity 
            onPress={() => navigation.navigate('Home')}
            className="w-10 h-10 bg-white rounded-full items-center justify-center shadow-md"
          >
            <Text className="text-xl">←</Text>
          </TouchableOpacity>
          <View className="flex-row gap-3">
            <TouchableOpacity className="w-10 h-10 bg-white rounded-full items-center justify-center shadow-md">
              <Text className="text-base">↗️</Text>
            </TouchableOpacity>
            <TouchableOpacity 
              onPress={() => setIsFavorited(!isFavorited)}
              className="w-10 h-10 bg-white rounded-full items-center justify-center shadow-md"
            >
              <Text className="text-lg">{isFavorited ? '❤️' : '🤍'}</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>

      {/* Content */}
      <View className="px-5 py-5">
        {/* Title and Rating */}
        <View className="flex-row justify-between items-start mb-2">
          <View className="flex-1">
            <Text className="text-2xl font-bold text-black">{route.params.place.name}</Text>
            <Text className="text-sm text-gray-600 mt-1">{route.params.place.location}</Text>
          </View>
          <View className="flex-row items-center gap-1">
            <Text className="text-base">⭐</Text>
            <Text className="text-base font-bold text-black">{route.params.place.rating}</Text>
            <Text className="text-sm text-gray-600">(169 reviews)</Text>
          </View>
        </View>

        {/* Tags */}
        <View className="flex-row items-center gap-3 mb-4">
          <View className="bg-green-50 px-3 py-1.5 rounded-xl flex-row items-center gap-1.5">
            <Text className="text-xs font-semibold text-green-600">{route.params.place.tag}</Text>
          </View>
          <View className="flex-row items-center gap-1.5">
            <View className={`w-2 h-2 rounded-full bg-${route.params.place.tagColor}-500`} />
            <Text className="text-xs text-gray-600">{route.params.place.crowdLevel}</Text>
          </View>
        </View>

        {/* Description */}
        <Text className="text-sm text-gray-700 leading-5 mb-6">
         {route.params.place.description}
        </Text>

        {/* Action Buttons */}
        <View className="flex-row gap-3 mb-6">
          {/* <TouchableOpacity className="flex-1 bg-blue-500 rounded-xl py-3.5 flex-row items-center justify-center gap-2">
            <Text className="text-base">🧭</Text>
            <Text className="text-white font-semibold text-base">Get Directions</Text>
          </TouchableOpacity>
          <TouchableOpacity className="flex-1 bg-white border border-gray-300 rounded-xl py-3.5 flex-row items-center justify-center gap-2">
            <Text className="text-base">🕐</Text>
            <Text className="text-gray-700 font-semibold text-base">Add to Plan</Text>
          </TouchableOpacity> */}
        </View>

        {/* Opening Hours */}
        <View className="mb-6">
          <Text className="text-lg font-bold text-black mb-3">Opening Hours</Text>
          <View className="bg-gray-50 rounded-xl p-4">
            <View className="flex-row justify-between items-center mb-3">
              <Text className="text-sm text-gray-700">Mon-Fri</Text>
              <Text className="text-sm font-semibold text-gray-900">8:00 AM - 7:30 PM</Text>
            </View>
            <View className="flex-row justify-between items-center">
              <Text className="text-sm text-gray-700">Sat-Sun</Text>
              <Text className="text-sm font-semibold text-gray-900">8:00 AM - 7:30 PM</Text>
            </View>
          </View>
        </View>

        {/* Amenities */}
        <View className="mb-6">
          <Text className="text-lg font-bold text-black mb-3">Amenities</Text>
          <View className="bg-gray-50 rounded-xl p-4">
            <View className="flex-row justify-between mb-4">
              <View className="flex-row items-center gap-2 flex-1">
                <Text className="text-base">📶</Text>
                <Text className="text-sm text-gray-700">Free Wifi</Text>
              </View>
              <View className="flex-row items-center gap-2 flex-1">
                <Text className="text-base">💳</Text>
                <Text className="text-sm text-gray-700">Cards Accepted</Text>
              </View>
            </View>
            <View className="flex-row justify-between">
              <View className="flex-row items-center gap-2 flex-1">
                <Text className="text-base">🅿️</Text>
                <Text className="text-sm text-gray-700">No parking</Text>
              </View>
              <View className="flex-row items-center gap-2 flex-1">
                <Text className="text-base">👨‍👩‍👧‍👦</Text>
                <Text className="text-sm text-gray-700">Family friendly</Text>
              </View>
            </View>
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

export default DetailScreen