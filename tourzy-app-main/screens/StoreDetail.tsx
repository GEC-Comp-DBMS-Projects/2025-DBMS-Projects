import React from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  Linking,
  Alert,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons } from '@expo/vector-icons';

const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

function StoreDetail() {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const store = route.params?.store;

  if (!store) {
    return (
      <View className="flex-1 bg-gray-50 items-center justify-center">
        <Text className="text-gray-600">Store not found</Text>
      </View>
    );
  }

  const getTypeColors = (type: string): string[] => {
    const lowerType = type.toLowerCase();
    if (lowerType.includes('restaurant')) return ['#f97316', '#ea580c'];
    if (lowerType.includes('cafe')) return ['#a855f7', '#9333ea'];
    if (lowerType.includes('shop')) return ['#3b82f6', '#2563eb'];
    if (lowerType.includes('handicraft')) return ['#ec4899', '#db2777'];
    if (lowerType.includes('clothing')) return ['#8b5cf6', '#7c3aed'];
    if (lowerType.includes('souvenir')) return ['#eab308', '#ca8a04'];
    if (lowerType.includes('service')) return ['#10b981', '#059669'];
    return ['#6366f1', '#4f46e5'];
  };

  const handleCall = () => {
    if (store.phoneNumber) {
      Linking.openURL(`tel:${store.phoneNumber}`);
    } else {
      Alert.alert('No Phone Number', 'This store has not provided a phone number.');
    }
  };

  const handleWebsite = () => {
    if (store.website) {
      Linking.openURL(store.website);
    } else {
      Alert.alert('No Website', 'This store has not provided a website.');
    }
  };

  const handleGetDirections = () => {
    const address = encodeURIComponent(store.storeLocation);
    Linking.openURL(`https://www.google.com/maps/search/?api=1&query=${address}`);
  };

  const typeColors = getTypeColors(store.storeType);
  const items = store.items || [];
  const availableItems = items.filter((item: any) => item.available);

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="light-content" backgroundColor={typeColors[0]} />
      
      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* Header with Gradient */}
        <View>
          <LinearGradient
            colors={typeColors}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={{ paddingTop: 48, paddingBottom: 24, paddingHorizontal: 20 }}
          >
            <TouchableOpacity
              onPress={() => navigation.goBack()}
              className="w-10 h-10 bg-white/30 rounded-full items-center justify-center mb-6"
            >
              <Ionicons name="arrow-back" size={24} color="#fff" />
            </TouchableOpacity>

            <View className="flex-row items-start justify-between mb-4">
              <View className="flex-1">
                <Text className="text-white text-3xl font-bold mb-2">{store.storeName}</Text>
                <View className="flex-row items-center mb-3">
                  <Ionicons name="location" size={16} color="rgba(255,255,255,0.9)" />
                  <Text className="text-white/90 text-base ml-2">{store.storeLocation}</Text>
                </View>
              </View>
            </View>

            <View className="flex-row items-center gap-2">
              <View className="bg-white/30 rounded-full px-4 py-2">
                <Text className="text-white font-bold text-sm">{store.storeType}</Text>
              </View>
              {store.verified && (
                <View className="bg-white/30 rounded-full px-4 py-2 flex-row items-center">
                  <Ionicons name="checkmark-circle" size={16} color="#fff" />
                  <Text className="text-white font-bold text-sm ml-1">Verified</Text>
                </View>
              )}
            </View>
          </LinearGradient>
        </View>

        {/* Quick Actions */}
        <View className="px-5 -mt-6">
          <View className="bg-white rounded-2xl p-4 shadow-xl">
            <View className="flex-row justify-around">
              <TouchableOpacity
                onPress={handleCall}
                className="items-center flex-1"
              >
                <View className="w-14 h-14 bg-blue-100 rounded-full items-center justify-center mb-2">
                  <Ionicons name="call" size={24} color="#3b82f6" />
                </View>
                <Text className="text-xs font-semibold text-gray-700">Call</Text>
              </TouchableOpacity>

              <TouchableOpacity
                onPress={handleGetDirections}
                className="items-center flex-1"
              >
                <View className="w-14 h-14 bg-green-100 rounded-full items-center justify-center mb-2">
                  <Ionicons name="navigate" size={24} color="#16a34a" />
                </View>
                <Text className="text-xs font-semibold text-gray-700">Directions</Text>
              </TouchableOpacity>

              <TouchableOpacity
                onPress={handleWebsite}
                className="items-center flex-1"
              >
                <View className="w-14 h-14 bg-purple-100 rounded-full items-center justify-center mb-2">
                  <Ionicons name="globe" size={24} color="#8b5cf6" />
                </View>
                <Text className="text-xs font-semibold text-gray-700">Website</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        {/* About Section */}
        {store.storeDescription && (
          <View className="px-5 pt-6 pb-4">
            <Text className="text-lg font-bold text-gray-900 mb-3">About</Text>
            <View className="bg-white rounded-2xl p-4 shadow-sm">
              <Text className="text-sm text-gray-700 leading-6">{store.storeDescription}</Text>
            </View>
          </View>
        )}

        {/* Contact Info */}
        <View className="px-5 pb-4">
          <Text className="text-lg font-bold text-gray-900 mb-3">Contact Information</Text>
          <View className="bg-white rounded-2xl p-4 shadow-sm">
            {store.phoneNumber && (
              <View className="flex-row items-center mb-3 pb-3 border-b border-gray-100">
                <View className="w-10 h-10 bg-blue-100 rounded-full items-center justify-center mr-3">
                  <Ionicons name="call" size={20} color="#3b82f6" />
                </View>
                <View className="flex-1">
                  <Text className="text-xs text-gray-500 mb-1">Phone</Text>
                  <Text className="text-sm font-semibold text-gray-900">{store.phoneNumber}</Text>
                </View>
              </View>
            )}

            <View className="flex-row items-center mb-3 pb-3 border-b border-gray-100">
              <View className="w-10 h-10 bg-green-100 rounded-full items-center justify-center mr-3">
                <Ionicons name="location" size={20} color="#16a34a" />
              </View>
              <View className="flex-1">
                <Text className="text-xs text-gray-500 mb-1">Address</Text>
                <Text className="text-sm font-semibold text-gray-900">{store.storeLocation}</Text>
              </View>
            </View>

            {store.website && (
              <View className="flex-row items-center">
                <View className="w-10 h-10 bg-purple-100 rounded-full items-center justify-center mr-3">
                  <Ionicons name="globe" size={20} color="#8b5cf6" />
                </View>
                <View className="flex-1">
                  <Text className="text-xs text-gray-500 mb-1">Website</Text>
                  <Text className="text-sm font-semibold text-blue-600" numberOfLines={1}>
                    {store.website}
                  </Text>
                </View>
              </View>
            )}
          </View>
        </View>

        {/* Operating Hours */}
        {store.operatingHours && (
          <View className="px-5 pb-4">
            <Text className="text-lg font-bold text-gray-900 mb-3">Operating Hours</Text>
            <View className="bg-white rounded-2xl p-4 shadow-sm">
              {DAYS.map((day) => {
                const hours = store.operatingHours[day];
                const today = DAYS[new Date().getDay() === 0 ? 6 : new Date().getDay() - 1];
                const isToday = day === today;

                return (
                  <View
                    key={day}
                    className={`flex-row items-center justify-between py-3 ${
                      isToday ? 'bg-blue-50 -mx-4 px-4 rounded-xl' : ''
                    }`}
                  >
                    <View className="flex-row items-center">
                      {isToday && (
                        <View className="w-2 h-2 bg-blue-500 rounded-full mr-2" />
                      )}
                      <Text
                        className={`text-sm font-semibold ${
                          isToday ? 'text-blue-900' : 'text-gray-700'
                        }`}
                      >
                        {day}
                      </Text>
                    </View>
                    {hours?.isOpen ? (
                      <Text
                        className={`text-sm font-semibold ${
                          isToday ? 'text-blue-700' : 'text-gray-600'
                        }`}
                      >
                        {hours.openTime} - {hours.closeTime}
                      </Text>
                    ) : (
                      <Text className="text-sm font-semibold text-red-600">Closed</Text>
                    )}
                  </View>
                );
              })}
            </View>
          </View>
        )}

        {/* Items/Products */}
        {items.length > 0 && (
          <View className="px-5 pb-6">
            <View className="flex-row items-center justify-between mb-3">
              <Text className="text-lg font-bold text-gray-900">Menu / Products</Text>
              <View className="bg-blue-100 rounded-full px-3 py-1">
                <Text className="text-blue-700 text-xs font-bold">
                  {availableItems.length} available
                </Text>
              </View>
            </View>

            {items.map((item: any) => (
              <View
                key={item.id}
                className={`bg-white rounded-2xl p-4 mb-3 shadow-sm ${
                  !item.available ? 'opacity-50' : ''
                }`}
              >
                <View className="flex-row items-start justify-between mb-2">
                  <View className="flex-1">
                    <View className="flex-row items-center mb-1">
                      <Text className="text-base font-bold text-gray-900 flex-1">
                        {item.name}
                      </Text>
                      {!item.available && (
                        <View className="bg-red-100 rounded-lg px-2 py-1">
                          <Text className="text-red-700 text-xs font-bold">Out of Stock</Text>
                        </View>
                      )}
                    </View>
                    {item.description && (
                      <Text className="text-xs text-gray-600 mb-2 leading-4">
                        {item.description}
                      </Text>
                    )}
                    <View className="flex-row items-center gap-2">
                      <View className="bg-green-50 rounded-lg px-3 py-1">
                        <Text className="text-green-700 text-sm font-bold">₹{item.price}</Text>
                      </View>
                      <View className="bg-purple-50 rounded-lg px-3 py-1">
                        <Text className="text-purple-700 text-xs font-semibold">
                          {item.category}
                        </Text>
                      </View>
                    </View>
                  </View>
                </View>
              </View>
            ))}
          </View>
        )}

        {/* Call to Action */}
        <View className="px-5 pb-6">
          <TouchableOpacity
            onPress={handleGetDirections}
            className="rounded-2xl overflow-hidden shadow-lg"
          >
            <LinearGradient
              colors={typeColors}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={{
                padding: 18,
                flexDirection: 'row',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Ionicons name="navigate" size={20} color="#fff" style={{ marginRight: 8 }} />
              <Text className="text-white text-base font-bold">Get Directions</Text>
            </LinearGradient>
          </TouchableOpacity>
        </View>

        {/* Bottom Spacing */}
        <View className="h-6" />
      </ScrollView>
    </View>
  );
}

export default StoreDetail;

