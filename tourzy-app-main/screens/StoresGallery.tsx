import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  TextInput,
  ActivityIndicator,
  RefreshControl,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import { db } from '../firebase';
import { collection, query, where, getDocs } from 'firebase/firestore';

interface Store {
  id: string;
  name: string;
  storeName: string;
  storeLocation: string;
  storeType: string;
  storeDescription?: string;
  phoneNumber?: string;
  website?: string;
  verified: boolean;
  items?: any[];
  operatingHours?: any;
}

const STORE_TYPES = ['All', 'Restaurant', 'Cafe', 'Shop', 'Handicrafts', 'Clothing', 'Souvenirs', 'Services'];

function StoresGallery() {
  const navigation = useNavigation<any>();
  const [stores, setStores] = useState<Store[]>([]);
  const [filteredStores, setFilteredStores] = useState<Store[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedType, setSelectedType] = useState('All');

  useEffect(() => {
    loadStores();
  }, []);

  useEffect(() => {
    filterStores();
  }, [searchQuery, selectedType, stores]);

  const loadStores = async () => {
    try {
      const usersRef = collection(db, 'users');
      const q = query(usersRef, where('userType', '==', 'storeowner'));
      const querySnapshot = await getDocs(q);

      const storesData: Store[] = [];
      querySnapshot.forEach((doc) => {
        const data = doc.data();
        // Only include stores that have basic info
        if (data.storeName && data.storeLocation) {
          storesData.push({
            id: doc.id,
            name: data.name,
            storeName: data.storeName,
            storeLocation: data.storeLocation,
            storeType: data.storeType || 'Shop',
            storeDescription: data.storeDescription,
            phoneNumber: data.phoneNumber,
            website: data.website,
            verified: data.verified || false,
            items: data.items || [],
            operatingHours: data.operatingHours,
          });
        }
      });

      setStores(storesData);
      setFilteredStores(storesData);
    } catch (error) {
      console.error('Error loading stores:', error);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  const filterStores = () => {
    let filtered = [...stores];

    // Filter by search query
    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(
        (store) =>
          store.storeName.toLowerCase().includes(query) ||
          store.storeType.toLowerCase().includes(query) ||
          store.storeLocation.toLowerCase().includes(query) ||
          store.storeDescription?.toLowerCase().includes(query)
      );
    }

    // Filter by type
    if (selectedType !== 'All') {
      filtered = filtered.filter(
        (store) => store.storeType.toLowerCase() === selectedType.toLowerCase()
      );
    }

    setFilteredStores(filtered);
  };

  const onRefresh = () => {
    setRefreshing(true);
    loadStores();
  };

  const getStoreIcon = (type: string) => {
    const lowerType = type.toLowerCase();
    if (lowerType.includes('restaurant') || lowerType.includes('cafe')) return 'restaurant';
    if (lowerType.includes('shop') || lowerType.includes('store')) return 'storefront';
    if (lowerType.includes('handicraft')) return 'color-palette';
    if (lowerType.includes('clothing')) return 'shirt';
    if (lowerType.includes('souvenir')) return 'gift';
    if (lowerType.includes('service')) return 'construct';
    return 'storefront';
  };

  const getTypeColor = (type: string): string[] => {
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

  const isOpenNow = (operatingHours: any) => {
    if (!operatingHours) return null;
    
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const now = new Date();
    const currentDay = days[now.getDay()];
    const currentTime = now.getHours() * 60 + now.getMinutes();
    
    const todayHours = operatingHours[currentDay];
    if (!todayHours || !todayHours.isOpen) return false;
    
    const [openHour, openMin] = todayHours.openTime.split(':').map(Number);
    const [closeHour, closeMin] = todayHours.closeTime.split(':').map(Number);
    
    const openTime = openHour * 60 + openMin;
    const closeTime = closeHour * 60 + closeMin;
    
    return currentTime >= openTime && currentTime <= closeTime;
  };

  if (loading) {
    return (
      <View className="flex-1 bg-gray-50 items-center justify-center">
        <StatusBar barStyle="dark-content" backgroundColor="#fff" />
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Loading stores...</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />
      
      <ScrollView
        className="flex-1"
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }
      >
        {/* Header */}
        <View className="bg-white px-5 pt-12 pb-5 shadow-sm">
          <View className="flex-row justify-between items-center mb-5">
            <TouchableOpacity onPress={() => navigation.goBack()}>
              <Ionicons name="arrow-back" size={24} color="#000" />
            </TouchableOpacity>
            <View className="flex-1 items-center">
              <Text className="text-lg font-bold text-gray-900">Local Stores</Text>
              <Text className="text-xs text-gray-500 mt-0.5">Discover & Shop</Text>
            </View>
            <View style={{ width: 24 }} />
          </View>

          {/* Search Bar */}
          <View className="bg-gray-100 rounded-2xl px-4 py-3 flex-row items-center">
            <Ionicons name="search" size={20} color="#9ca3af" />
            <TextInput
              value={searchQuery}
              onChangeText={setSearchQuery}
              placeholder="Search stores..."
              placeholderTextColor="#9ca3af"
              className="flex-1 ml-3 text-gray-900"
            />
            {searchQuery ? (
              <TouchableOpacity onPress={() => setSearchQuery('')}>
                <Ionicons name="close-circle" size={20} color="#9ca3af" />
              </TouchableOpacity>
            ) : null}
          </View>
        </View>

        {/* Store Type Filters */}
        <View className="px-5 pt-5 pb-4">
          <Text className="text-xs text-gray-500 mb-3 uppercase tracking-wide">Filter by Type</Text>
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{ gap: 8 }}
          >
            {STORE_TYPES.map((type) => (
              <TouchableOpacity
                key={type}
                onPress={() => setSelectedType(type)}
                className={`rounded-2xl px-5 py-3 ${
                  selectedType === type
                    ? 'bg-blue-500 shadow-md'
                    : 'bg-white border border-gray-200'
                }`}
              >
                <Text
                  className={`text-sm font-bold ${
                    selectedType === type ? 'text-white' : 'text-gray-700'
                  }`}
                >
                  {type}
                </Text>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        {/* Stats Banner */}
        <View className="px-5 pb-4">
          <View className="bg-blue-600 rounded-2xl p-4 shadow-lg">
            <LinearGradient
              colors={['#3b82f6', '#8b5cf6']}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                borderRadius: 16,
              }}
            />
            <View className="flex-row items-center justify-between">
              <View className="flex-row items-center">
                <View className="w-12 h-12 bg-white/30 rounded-full items-center justify-center mr-3">
                  <Ionicons name="storefront" size={24} color="#fff" />
                </View>
                <View>
                  <Text className="text-white text-2xl font-bold">{filteredStores.length}</Text>
                  <Text className="text-white/90 text-xs">
                    {selectedType === 'All' ? 'Total Stores' : `${selectedType} Stores`}
                  </Text>
                </View>
              </View>
              <View className="bg-white/20 rounded-xl px-4 py-2">
                <Text className="text-white text-xs font-bold">
                  {stores.filter((s) => s.verified).length} Verified
                </Text>
              </View>
            </View>
          </View>
        </View>

        {/* Stores List */}
        {filteredStores.length > 0 ? (
          <View className="px-5 pb-6">
            <View className="flex-row items-center mb-3">
              <Ionicons name="grid" size={20} color="#1f2937" style={{ marginRight: 6 }} />
              <Text className="text-lg font-bold text-gray-900">All Stores</Text>
            </View>

            {filteredStores.map((store) => {
              const openStatus = isOpenNow(store.operatingHours);
              const typeColors = getTypeColor(store.storeType);

              return (
                <TouchableOpacity
                  key={store.id}
                  onPress={() => navigation.navigate('storeDetail', { store })}
                  className="bg-white rounded-2xl mb-3 overflow-hidden shadow-md"
                  activeOpacity={0.9}
                >
                  {/* Store Header with Gradient */}
                  <LinearGradient
                    colors={typeColors}
                    start={{ x: 0, y: 0 }}
                    end={{ x: 1, y: 0 }}
                    style={{ padding: 16 }}
                  >
                    <View className="flex-row items-start justify-between">
                      <View className="flex-1">
                        <View className="flex-row items-center mb-2">
                          <Text className="text-white text-xl font-bold flex-1">
                            {store.storeName}
                          </Text>
                          {store.verified && (
                            <View className="bg-white/30 rounded-full px-3 py-1 ml-2">
                              <View className="flex-row items-center">
                                <Ionicons name="checkmark-circle" size={14} color="#fff" />
                                <Text className="text-white text-xs font-bold ml-1">Verified</Text>
                              </View>
                            </View>
                          )}
                        </View>

                        <View className="flex-row items-center mb-2">
                          <Ionicons name="location" size={14} color="rgba(255,255,255,0.9)" />
                          <Text className="text-white/90 text-sm ml-1">{store.storeLocation}</Text>
                        </View>

                        <View className="bg-white/20 rounded-lg px-3 py-1.5 self-start">
                          <Text className="text-white text-xs font-bold">{store.storeType}</Text>
                        </View>
                      </View>

                      <View className="w-16 h-16 bg-white/30 rounded-full items-center justify-center ml-3">
                        <Ionicons name={getStoreIcon(store.storeType) as any} size={32} color="#fff" />
                      </View>
                    </View>
                  </LinearGradient>

                  {/* Store Details */}
                  <View className="p-4">
                    {store.storeDescription && (
                      <Text className="text-sm text-gray-600 mb-3 leading-5" numberOfLines={2}>
                        {store.storeDescription}
                      </Text>
                    )}

                    {/* Store Stats */}
                    <View className="flex-row items-center gap-2 mb-3">
                      {store.items && store.items.length > 0 && (
                        <View className="bg-blue-50 rounded-lg px-3 py-1.5 flex-row items-center">
                          <Ionicons name="pricetag" size={14} color="#3b82f6" />
                          <Text className="text-xs font-semibold text-blue-700 ml-1">
                            {store.items.length} items
                          </Text>
                        </View>
                      )}

                      {openStatus !== null && (
                        <View
                          className={`rounded-lg px-3 py-1.5 flex-row items-center ${
                            openStatus ? 'bg-green-50' : 'bg-red-50'
                          }`}
                        >
                          <View
                            className={`w-2 h-2 rounded-full mr-1.5 ${
                              openStatus ? 'bg-green-500' : 'bg-red-500'
                            }`}
                          />
                          <Text
                            className={`text-xs font-semibold ${
                              openStatus ? 'text-green-700' : 'text-red-700'
                            }`}
                          >
                            {openStatus ? 'Open Now' : 'Closed'}
                          </Text>
                        </View>
                      )}

                      {store.phoneNumber && (
                        <View className="bg-purple-50 rounded-lg px-3 py-1.5 flex-row items-center">
                          <Ionicons name="call" size={14} color="#8b5cf6" />
                          <Text className="text-xs font-semibold text-purple-700 ml-1">
                            Contact
                          </Text>
                        </View>
                      )}
                    </View>

                    {/* Action Button */}
                    <View className="flex-row items-center justify-between pt-3 border-t border-gray-100">
                      <Text className="text-blue-600 text-sm font-bold">View Details</Text>
                      <Ionicons name="chevron-forward" size={20} color="#3b82f6" />
                    </View>
                  </View>
                </TouchableOpacity>
              );
            })}
          </View>
        ) : (
          // Empty State
          <View className="px-5 py-12 items-center">
            <View className="w-24 h-24 bg-gray-100 rounded-full items-center justify-center mb-4">
              <Ionicons name="storefront-outline" size={48} color="#9ca3af" />
            </View>
            <Text className="text-gray-900 text-xl font-bold mb-2">No Stores Found</Text>
            <Text className="text-gray-600 text-sm text-center mb-6 px-6">
              {searchQuery || selectedType !== 'All'
                ? 'Try adjusting your search or filters'
                : 'No stores available at the moment'}
            </Text>
            {(searchQuery || selectedType !== 'All') && (
              <TouchableOpacity
                onPress={() => {
                  setSearchQuery('');
                  setSelectedType('All');
                }}
                className="bg-blue-500 rounded-xl px-6 py-3"
              >
                <Text className="text-white font-bold">Clear Filters</Text>
              </TouchableOpacity>
            )}
          </View>
        )}

        {/* Bottom Spacing */}
        <View className="h-6" />
      </ScrollView>
    </View>
  );
}

export default StoresGallery;

