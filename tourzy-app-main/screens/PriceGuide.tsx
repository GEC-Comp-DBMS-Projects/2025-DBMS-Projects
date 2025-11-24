import React, { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import { priceDatabase } from '../utils/priceAlerts';

const categories = [
  { key: 'beach', name: 'Beach', icon: 'beach', colors: ['#06b6d4', '#0891b2'] },
  { key: 'restaurant', name: 'Restaurant', icon: 'restaurant', colors: ['#f97316', '#ea580c'] },
  { key: 'heritage', name: 'Heritage', icon: 'business', colors: ['#a855f7', '#9333ea'] },
  { key: 'market', name: 'Market', icon: 'storefront', colors: ['#eab308', '#ca8a04'] },
  { key: 'adventure', name: 'Adventure', icon: 'trail-sign', colors: ['#22c55e', '#16a34a'] },
  { key: 'temple', name: 'Temple', icon: 'flower', colors: ['#ec4899', '#db2777'] },
];

function PriceGuide() {
  const navigation = useNavigation<any>();
  const [selectedCategory, setSelectedCategory] = useState('beach');

  const currentData = priceDatabase[selectedCategory];
  const currentCategoryInfo = categories.find(c => c.key === selectedCategory);

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
              <Text className="text-lg font-bold text-gray-900">Price Guide</Text>
              <Text className="text-xs text-gray-500 mt-0.5">Fair Prices & Scam Alerts</Text>
            </View>
            <View style={{ width: 24 }} />
          </View>
        </View>

        {/* Hero Banner */}
        <View className="px-5 pt-5 pb-4">
          <View className="rounded-3xl overflow-hidden shadow-xl">
            <LinearGradient
              colors={['#ef4444', '#dc2626']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={{ padding: 24 }}
            >
              <View className="flex-row items-center mb-3">
                <View className="w-16 h-16 bg-white/30 rounded-full items-center justify-center mr-4">
                  <Ionicons name="shield-checkmark" size={32} color="#fff" />
                </View>
                <View className="flex-1">
                  <Text className="text-white text-2xl font-bold mb-1">Stay Protected</Text>
                  <Text className="text-white/90 text-sm">
                    Know fair prices & avoid scams
                  </Text>
                </View>
              </View>
              
              <View className="bg-white/20 rounded-2xl p-4">
                <Text className="text-white font-bold mb-1">💡 Pro Tip</Text>
                <Text className="text-white/95 text-xs leading-5">
                  Always bargain, carry small change, and use official services to avoid tourist traps!
                </Text>
              </View>
            </LinearGradient>
          </View>
        </View>

        {/* Category Pills */}
        <View className="px-5 pb-4">
          <Text className="text-xs text-gray-500 mb-3 uppercase tracking-wide">
            Select Category
          </Text>
          <ScrollView 
            horizontal 
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ gap: 8 }}
          >
            {categories.map((cat) => (
              <TouchableOpacity
                key={cat.key}
                onPress={() => setSelectedCategory(cat.key)}
                className={`rounded-2xl px-5 py-3 ${
                  selectedCategory === cat.key ? 'shadow-md' : 'bg-white border border-gray-200'
                }`}
                style={selectedCategory === cat.key ? {
                  backgroundColor: cat.colors[0]
                } : {}}
              >
                <View className="flex-row items-center">
                  <Ionicons 
                    name={cat.icon as any} 
                    size={18} 
                    color={selectedCategory === cat.key ? '#fff' : '#666'} 
                  />
                  <Text
                    className={`ml-2 text-sm font-bold ${
                      selectedCategory === cat.key ? 'text-white' : 'text-gray-700'
                    }`}
                  >
                    {cat.name}
                  </Text>
                </View>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        {/* Category Header */}
        {currentCategoryInfo && (
          <View className="px-5 pb-4">
            <View className="rounded-2xl overflow-hidden shadow-lg">
              <LinearGradient
                colors={currentCategoryInfo.colors}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 0 }}
                style={{ padding: 20, flexDirection: 'row', alignItems: 'center' }}
              >
                <View className="w-14 h-14 bg-white/30 rounded-full items-center justify-center mr-4">
                  <Ionicons name={currentCategoryInfo.icon as any} size={28} color="#fff" />
                </View>
                <View className="flex-1">
                  <Text className="text-white text-xl font-bold">{currentCategoryInfo.name}</Text>
                  <Text className="text-white/90 text-sm">
                    {currentData.scams.length} scams • {currentData.items.length} items
                  </Text>
                </View>
              </LinearGradient>
            </View>
          </View>
        )}

        {/* Scam Warnings Section */}
        {currentData.scams.length > 0 && (
          <View className="px-5 pb-4">
            <View className="flex-row items-center mb-3">
              <View className="w-1 h-6 bg-red-500 rounded-full mr-3" />
              <Ionicons name="alert-circle" size={20} color="#dc2626" style={{ marginRight: 6 }} />
              <Text className="text-lg font-bold text-gray-900">Scam Warnings</Text>
            </View>

            {currentData.scams.map((scam, idx) => (
              <View
                key={idx}
                className={`mb-3 rounded-2xl overflow-hidden shadow-md ${
                  scam.severity === 'high'
                    ? 'bg-red-50 border-2 border-red-300'
                    : scam.severity === 'medium'
                    ? 'bg-orange-50 border-2 border-orange-300'
                    : 'bg-yellow-50 border-2 border-yellow-300'
                }`}
              >
                <View className="p-4">
                  <View className="flex-row items-start mb-3">
                    <View
                      className={`w-12 h-12 rounded-full items-center justify-center mr-3 ${
                        scam.severity === 'high'
                          ? 'bg-red-500'
                          : scam.severity === 'medium'
                          ? 'bg-orange-500'
                          : 'bg-yellow-500'
                      }`}
                    >
                      <Ionicons name={scam.icon as any} size={24} color="#fff" />
                    </View>
                    <View className="flex-1">
                      <View className="flex-row items-center mb-1">
                        <Text
                          className={`font-bold text-base flex-1 ${
                            scam.severity === 'high'
                              ? 'text-red-900'
                              : scam.severity === 'medium'
                              ? 'text-orange-900'
                              : 'text-yellow-900'
                          }`}
                        >
                          {scam.title}
                        </Text>
                        <View
                          className={`rounded-full px-3 py-1 ${
                            scam.severity === 'high'
                              ? 'bg-red-500'
                              : scam.severity === 'medium'
                              ? 'bg-orange-500'
                              : 'bg-yellow-500'
                          }`}
                        >
                          <Text className="text-white text-xs font-bold uppercase">
                            {scam.severity}
                          </Text>
                        </View>
                      </View>
                      <Text
                        className={`text-sm leading-5 ${
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
              </View>
            ))}
          </View>
        )}

        {/* Fair Prices Section */}
        {currentData.items.length > 0 && (
          <View className="px-5 pb-4">
            <View className="flex-row items-center mb-3">
              <View className="w-1 h-6 bg-green-500 rounded-full mr-3" />
              <Ionicons name="pricetag" size={20} color="#059669" style={{ marginRight: 6 }} />
              <Text className="text-lg font-bold text-gray-900">Fair Prices</Text>
            </View>

            {currentData.items.map((item, idx) => (
              <View key={idx} className="bg-white rounded-2xl p-4 mb-3 shadow-md">
                <View className="flex-row items-start mb-3">
                  <View className="w-12 h-12 bg-green-100 rounded-full items-center justify-center mr-3">
                    <Ionicons name={item.icon as any} size={24} color="#059669" />
                  </View>
                  <View className="flex-1">
                    <Text className="text-gray-900 font-bold text-base mb-2">
                      {item.item}
                    </Text>
                    
                    <View className="mb-2">
                      <View className="flex-row items-center mb-1">
                        <Ionicons name="checkmark-circle" size={16} color="#059669" />
                        <Text className="text-green-700 font-bold text-sm ml-2">
                          Fair Price: {item.fairPrice}
                        </Text>
                      </View>
                      
                      {item.scamPrice && (
                        <View className="flex-row items-center">
                          <Ionicons name="close-circle" size={16} color="#dc2626" />
                          <Text className="text-red-600 font-bold text-sm ml-2 line-through">
                            Tourist Trap: {item.scamPrice}
                          </Text>
                        </View>
                      )}
                    </View>

                    {item.warning && (
                      <View className="bg-yellow-50 border-2 border-yellow-200 rounded-xl p-3">
                        <View className="flex-row items-start">
                          <Ionicons name="warning" size={16} color="#ca8a04" style={{ marginTop: 2 }} />
                          <Text className="text-yellow-800 text-xs ml-2 flex-1 leading-5">
                            {item.warning}
                          </Text>
                        </View>
                      </View>
                    )}
                  </View>
                </View>
              </View>
            ))}
          </View>
        )}

        {/* Pro Tips Section */}
        {currentData.tips.length > 0 && (
          <View className="px-5 pb-6">
            <View className="flex-row items-center mb-3">
              <View className="w-1 h-6 bg-blue-500 rounded-full mr-3" />
              <Ionicons name="bulb" size={20} color="#3b82f6" style={{ marginRight: 6 }} />
              <Text className="text-lg font-bold text-gray-900">Pro Tips</Text>
            </View>

            <View className="bg-white rounded-2xl p-4 shadow-md">
              {currentData.tips.map((tip, idx) => (
                <View
                  key={idx}
                  className={`flex-row items-start pb-3 ${
                    idx !== currentData.tips.length - 1 ? 'mb-3 border-b border-gray-100' : ''
                  }`}
                >
                  <View className="w-8 h-8 bg-blue-100 rounded-full items-center justify-center mr-3 mt-0.5">
                    <Text className="text-blue-600 font-bold text-sm">{idx + 1}</Text>
                  </View>
                  <Text className="text-gray-700 text-sm leading-6 flex-1">{tip}</Text>
                </View>
              ))}
            </View>
          </View>
        )}

        {/* Bottom CTA */}
        <View className="px-5 pb-6">
          <View className="bg-blue-50 border-2 border-blue-200 rounded-2xl p-4">
            <View className="flex-row items-start">
              <View className="w-12 h-12 bg-blue-500 rounded-full items-center justify-center mr-3">
                <Ionicons name="information" size={24} color="#fff" />
              </View>
              <View className="flex-1">
                <Text className="text-blue-900 font-bold mb-1">Stay Smart, Travel Safe!</Text>
                <Text className="text-blue-700 text-xs leading-5">
                  Always verify prices before agreeing, bargain confidently, and trust your instincts. 
                  These price guides are based on 2024 average rates in Goa.
                </Text>
              </View>
            </View>
          </View>
        </View>

        {/* Bottom Spacing */}
        <View className="h-6" />
      </ScrollView>
    </View>
  );
}

export default PriceGuide;

