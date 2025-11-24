import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  TextInput,
  Alert,
  Modal,
  ActivityIndicator,
  Switch,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import { auth, db } from '../firebase';
import { doc, getDoc, updateDoc, setDoc, serverTimestamp } from 'firebase/firestore';

interface OperatingHours {
  [key: string]: {
    isOpen: boolean;
    openTime: string;
    closeTime: string;
  };
}

interface StoreItem {
  id: string;
  name: string;
  description: string;
  price: string;
  category: string;
  available: boolean;
}

const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

const CATEGORIES = ['Food', 'Drinks', 'Snacks', 'Souvenirs', 'Handicrafts', 'Clothing', 'Accessories', 'Services', 'Other'];

function StoreOwner() {
  const navigation = useNavigation<any>();
  const [storeData, setStoreData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  
  // Modals
  const [showDetailsModal, setShowDetailsModal] = useState(false);
  const [showHoursModal, setShowHoursModal] = useState(false);
  const [showItemModal, setShowItemModal] = useState(false);
  
  // Store Details
  const [storeName, setStoreName] = useState('');
  const [storeDescription, setStoreDescription] = useState('');
  const [storeType, setStoreType] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [website, setWebsite] = useState('');
  
  // Operating Hours
  const [operatingHours, setOperatingHours] = useState<OperatingHours>({
    Monday: { isOpen: true, openTime: '09:00', closeTime: '18:00' },
    Tuesday: { isOpen: true, openTime: '09:00', closeTime: '18:00' },
    Wednesday: { isOpen: true, openTime: '09:00', closeTime: '18:00' },
    Thursday: { isOpen: true, openTime: '09:00', closeTime: '18:00' },
    Friday: { isOpen: true, openTime: '09:00', closeTime: '18:00' },
    Saturday: { isOpen: true, openTime: '10:00', closeTime: '16:00' },
    Sunday: { isOpen: false, openTime: '00:00', closeTime: '00:00' },
  });
  
  // Items
  const [items, setItems] = useState<StoreItem[]>([]);
  const [currentItem, setCurrentItem] = useState<StoreItem>({
    id: '',
    name: '',
    description: '',
    price: '',
    category: 'Food',
    available: true,
  });
  const [editingItemId, setEditingItemId] = useState<string | null>(null);

  useEffect(() => {
    loadStoreData();
  }, []);

  const loadStoreData = async () => {
    try {
      const user = auth.currentUser;
      if (!user) {
        navigation.navigate('userLogin');
        return;
      }

      const userDoc = await getDoc(doc(db, 'users', user.uid));
      if (userDoc.exists()) {
        const data = userDoc.data();
        setStoreData(data);
        setStoreName(data.storeName || '');
        setStoreDescription(data.storeDescription || '');
        setStoreType(data.storeType || '');
        setPhoneNumber(data.phoneNumber || '');
        setWebsite(data.website || '');
        
        if (data.operatingHours) {
          setOperatingHours(data.operatingHours);
        }
        
        if (data.items) {
          setItems(data.items);
        }
      }
    } catch (error) {
      console.error('Error loading store data:', error);
      Alert.alert('Error', 'Failed to load store data');
    } finally {
      setLoading(false);
    }
  };

  const saveStoreDetails = async () => {
    if (!storeName || !storeType) {
      Alert.alert('Error', 'Please fill in store name and type');
      return;
    }

    setSaving(true);
    try {
      const user = auth.currentUser;
      if (!user) return;

      await updateDoc(doc(db, 'users', user.uid), {
        storeName,
        storeDescription,
        storeType,
        phoneNumber,
        website,
        updatedAt: serverTimestamp(),
      });

      setStoreData({ ...storeData, storeName, storeDescription, storeType, phoneNumber, website });
      Alert.alert('Success', 'Store details updated successfully');
      setShowDetailsModal(false);
    } catch (error) {
      console.error('Error saving store details:', error);
      Alert.alert('Error', 'Failed to save store details');
    } finally {
      setSaving(false);
    }
  };

  const saveOperatingHours = async () => {
    setSaving(true);
    try {
      const user = auth.currentUser;
      if (!user) return;

      await updateDoc(doc(db, 'users', user.uid), {
        operatingHours,
        updatedAt: serverTimestamp(),
      });

      setStoreData({ ...storeData, operatingHours });
      Alert.alert('Success', 'Operating hours updated successfully');
      setShowHoursModal(false);
    } catch (error) {
      console.error('Error saving operating hours:', error);
      Alert.alert('Error', 'Failed to save operating hours');
    } finally {
      setSaving(false);
    }
  };

  const saveItem = async () => {
    if (!currentItem.name || !currentItem.price) {
      Alert.alert('Error', 'Please fill in item name and price');
      return;
    }

    setSaving(true);
    try {
      const user = auth.currentUser;
      if (!user) return;

      let updatedItems = [...items];
      
      if (editingItemId) {
        // Update existing item
        updatedItems = items.map(item => 
          item.id === editingItemId ? { ...currentItem, id: editingItemId } : item
        );
      } else {
        // Add new item
        const newItem = {
          ...currentItem,
          id: Date.now().toString(),
        };
        updatedItems.push(newItem);
      }

      await updateDoc(doc(db, 'users', user.uid), {
        items: updatedItems,
        updatedAt: serverTimestamp(),
      });

      setItems(updatedItems);
      Alert.alert('Success', editingItemId ? 'Item updated successfully' : 'Item added successfully');
      setShowItemModal(false);
      resetItemForm();
    } catch (error) {
      console.error('Error saving item:', error);
      Alert.alert('Error', 'Failed to save item');
    } finally {
      setSaving(false);
    }
  };

  const deleteItem = async (itemId: string) => {
    Alert.alert(
      'Delete Item',
      'Are you sure you want to delete this item?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              const user = auth.currentUser;
              if (!user) return;

              const updatedItems = items.filter(item => item.id !== itemId);

              await updateDoc(doc(db, 'users', user.uid), {
                items: updatedItems,
                updatedAt: serverTimestamp(),
              });

              setItems(updatedItems);
              Alert.alert('Success', 'Item deleted successfully');
            } catch (error) {
              console.error('Error deleting item:', error);
              Alert.alert('Error', 'Failed to delete item');
            }
          },
        },
      ]
    );
  };

  const toggleItemAvailability = async (itemId: string) => {
    try {
      const user = auth.currentUser;
      if (!user) return;

      const updatedItems = items.map(item =>
        item.id === itemId ? { ...item, available: !item.available } : item
      );

      await updateDoc(doc(db, 'users', user.uid), {
        items: updatedItems,
        updatedAt: serverTimestamp(),
      });

      setItems(updatedItems);
    } catch (error) {
      console.error('Error toggling item availability:', error);
      Alert.alert('Error', 'Failed to update item availability');
    }
  };

  const resetItemForm = () => {
    setCurrentItem({
      id: '',
      name: '',
      description: '',
      price: '',
      category: 'Food',
      available: true,
    });
    setEditingItemId(null);
  };

  const openEditItem = (item: StoreItem) => {
    setCurrentItem(item);
    setEditingItemId(item.id);
    setShowItemModal(true);
  };

  const handleSignOut = async () => {
    try {
      await auth.signOut();
      navigation.navigate('userLogin');
    } catch (error) {
      console.error('Error signing out:', error);
    }
  };

  if (loading) {
    return (
      <View className="flex-1 bg-gray-50 items-center justify-center">
        <ActivityIndicator size="large" color="#8b5cf6" />
        <Text className="text-gray-600 mt-4">Loading store data...</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-gray-50">
      <StatusBar barStyle="dark-content" backgroundColor="#fff" />
      
      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View className="bg-white px-5 pt-12 pb-5 shadow-sm">
          <View className="flex-row justify-between items-center mb-5">
            <View className="flex-1">
              <Text className="text-2xl font-bold text-gray-900">Store Dashboard</Text>
              <Text className="text-sm text-gray-500 mt-1">
                Welcome, {storeData?.name || 'Store Owner'}
              </Text>
            </View>
            <TouchableOpacity 
              onPress={handleSignOut}
              className="w-10 h-10 bg-red-100 rounded-full items-center justify-center"
            >
              <Ionicons name="log-out-outline" size={20} color="#ef4444" />
            </TouchableOpacity>
          </View>
        </View>

        {/* Store Info Card */}
        {storeData && (
          <View className="px-5 pt-5 pb-4">
            <View className="rounded-3xl overflow-hidden shadow-xl">
              <LinearGradient
                colors={['#8b5cf6', '#ec4899']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={{ padding: 24 }}
              >
                <View className="flex-row items-center mb-4">
                  <View className="w-16 h-16 bg-white/30 rounded-full items-center justify-center mr-4">
                    <Ionicons name="storefront" size={32} color="#fff" />
                  </View>
                  <View className="flex-1">
                    <Text className="text-white text-2xl font-bold mb-1">
                      {storeData.storeName}
                    </Text>
                    <View className="flex-row items-center">
                      <Ionicons name="location" size={14} color="rgba(255,255,255,0.9)" />
                      <Text className="text-white/90 text-sm ml-1">
                        {storeData.storeLocation}
                      </Text>
                    </View>
                  </View>
                </View>
                
                {/* <View className="bg-white/20 rounded-2xl p-4">
                  <View className="flex-row items-center mb-2">
                    <Ionicons name="checkmark-circle" size={18} color="#fff" />
                    <Text className="text-white font-bold ml-2">
                      {storeData.verified ? 'Verified Store' : 'Pending Verification'}
                    </Text>
                  </View>
                  <Text className="text-white/90 text-xs">
                    {storeData.verified 
                      ? 'Your store is verified and visible to tourists'
                      : 'Your store is under review. You will be notified once verified.'}
                  </Text>
                </View> */}
              </LinearGradient>
            </View>
          </View>
        )}

        {/* Quick Stats */}
        <View className="px-5 pb-4">
          <Text className="text-lg font-bold text-gray-900 mb-3">Quick Stats</Text>
          <View className="flex-row gap-3">
            <View className="flex-1 bg-white rounded-2xl p-4 shadow-sm">
              <View className="w-12 h-12 bg-blue-100 rounded-full items-center justify-center mb-3">
                <Ionicons name="pricetag" size={24} color="#3b82f6" />
              </View>
              <Text className="text-2xl font-bold text-gray-900 mb-1">{items.length}</Text>
              <Text className="text-xs text-gray-500">Total Items</Text>
            </View>
            
            <View className="flex-1 bg-white rounded-2xl p-4 shadow-sm">
              <View className="w-12 h-12 bg-green-100 rounded-full items-center justify-center mb-3">
                <Ionicons name="checkmark-circle" size={24} color="#16a34a" />
              </View>
              <Text className="text-2xl font-bold text-gray-900 mb-1">
                {items.filter(i => i.available).length}
              </Text>
              <Text className="text-xs text-gray-500">Available</Text>
            </View>
          </View>
        </View>

        {/* Management Options */}
        <View className="px-5 pb-4">
          <Text className="text-lg font-bold text-gray-900 mb-3">Manage Store</Text>
          
          <TouchableOpacity 
            onPress={() => setShowDetailsModal(true)}
            className="bg-white rounded-2xl p-4 mb-3 shadow-sm flex-row items-center"
          >
            <View className="w-12 h-12 bg-purple-100 rounded-full items-center justify-center mr-4">
              <Ionicons name="information-circle" size={24} color="#8b5cf6" />
            </View>
            <View className="flex-1">
              <Text className="text-base font-bold text-gray-900 mb-1">Store Details</Text>
              <Text className="text-xs text-gray-500">Update store information</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
          </TouchableOpacity>

          <TouchableOpacity 
            onPress={() => setShowHoursModal(true)}
            className="bg-white rounded-2xl p-4 mb-3 shadow-sm flex-row items-center"
          >
            <View className="w-12 h-12 bg-blue-100 rounded-full items-center justify-center mr-4">
              <Ionicons name="time" size={24} color="#3b82f6" />
            </View>
            <View className="flex-1">
              <Text className="text-base font-bold text-gray-900 mb-1">Operating Hours</Text>
              <Text className="text-xs text-gray-500">Set your business hours</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
          </TouchableOpacity>

          <TouchableOpacity 
            onPress={() => {
              resetItemForm();
              setShowItemModal(true);
            }}
            className="bg-white rounded-2xl p-4 shadow-sm flex-row items-center"
          >
            <View className="w-12 h-12 bg-orange-100 rounded-full items-center justify-center mr-4">
              <Ionicons name="add-circle" size={24} color="#f97316" />
            </View>
            <View className="flex-1">
              <Text className="text-base font-bold text-gray-900 mb-1">Add Item/Product</Text>
              <Text className="text-xs text-gray-500">Add items to your catalog</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color="#9ca3af" />
          </TouchableOpacity>
        </View>

        {/* Items List */}
        {items.length > 0 && (
          <View className="px-5 pb-6">
            <View className="flex-row items-center justify-between mb-3">
              <Text className="text-lg font-bold text-gray-900">Your Items</Text>
              <View className="bg-purple-100 rounded-full px-3 py-1">
                <Text className="text-purple-700 text-xs font-bold">{items.length} items</Text>
              </View>
            </View>

            {items.map((item) => (
              <View key={item.id} className="bg-white rounded-2xl p-4 mb-3 shadow-sm">
                <View className="flex-row items-start justify-between mb-2">
                  <View className="flex-1">
                    <View className="flex-row items-center mb-1">
                      <Text className="text-base font-bold text-gray-900 flex-1">{item.name}</Text>
                      <Switch
                        value={item.available}
                        onValueChange={() => toggleItemAvailability(item.id)}
                        trackColor={{ false: '#d1d5db', true: '#86efac' }}
                        thumbColor={item.available ? '#16a34a' : '#f3f4f6'}
                      />
                    </View>
                    {item.description ? (
                      <Text className="text-xs text-gray-600 mb-2">{item.description}</Text>
                    ) : null}
                    <View className="flex-row items-center gap-2">
                      <View className="bg-blue-50 rounded-lg px-2 py-1">
                        <Text className="text-xs font-semibold text-blue-700">₹{item.price}</Text>
                      </View>
                      <View className="bg-purple-50 rounded-lg px-2 py-1">
                        <Text className="text-xs font-semibold text-purple-700">{item.category}</Text>
                      </View>
                      {item.available ? (
                        <View className="bg-green-50 rounded-lg px-2 py-1">
                          <Text className="text-xs font-semibold text-green-700">Available</Text>
                        </View>
                      ) : (
                        <View className="bg-red-50 rounded-lg px-2 py-1">
                          <Text className="text-xs font-semibold text-red-700">Unavailable</Text>
                        </View>
                      )}
                    </View>
                  </View>
                </View>
                
                <View className="flex-row gap-2 mt-3 pt-3 border-t border-gray-100">
                  <TouchableOpacity
                    onPress={() => openEditItem(item)}
                    className="flex-1 bg-blue-50 rounded-xl py-2 flex-row items-center justify-center"
                  >
                    <Ionicons name="pencil" size={16} color="#3b82f6" />
                    <Text className="text-blue-600 font-semibold text-sm ml-1">Edit</Text>
                  </TouchableOpacity>
                  
                  <TouchableOpacity
                    onPress={() => deleteItem(item.id)}
                    className="flex-1 bg-red-50 rounded-xl py-2 flex-row items-center justify-center"
                  >
                    <Ionicons name="trash" size={16} color="#ef4444" />
                    <Text className="text-red-600 font-semibold text-sm ml-1">Delete</Text>
                  </TouchableOpacity>
                </View>
              </View>
            ))}
          </View>
        )}

        {/* Bottom Spacing */}
        <View className="h-6" />
      </ScrollView>

      {/* Store Details Modal */}
      <Modal
        visible={showDetailsModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowDetailsModal(false)}
      >
        <View className="flex-1 bg-black/50 justify-end">
          <View className="bg-white rounded-t-3xl p-6" style={{ maxHeight: '90%' }}>
            <View className="flex-row items-center justify-between mb-6">
              <Text className="text-xl font-bold text-gray-900">Store Details</Text>
              <TouchableOpacity onPress={() => setShowDetailsModal(false)}>
                <Ionicons name="close-circle" size={28} color="#9ca3af" />
              </TouchableOpacity>
            </View>

            <ScrollView showsVerticalScrollIndicator={false}>
              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-900 mb-2">Store Name *</Text>
                <TextInput
                  value={storeName}
                  onChangeText={setStoreName}
                  placeholder="Enter store name"
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                />
              </View>

              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-900 mb-2">Store Type *</Text>
                <TextInput
                  value={storeType}
                  onChangeText={setStoreType}
                  placeholder="e.g., Restaurant, Cafe, Shop, etc."
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                />
              </View>

              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-900 mb-2">Description</Text>
                <TextInput
                  value={storeDescription}
                  onChangeText={setStoreDescription}
                  placeholder="Describe your store"
                  multiline
                  numberOfLines={4}
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                  style={{ textAlignVertical: 'top' }}
                />
              </View>

              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-900 mb-2">Phone Number</Text>
                <TextInput
                  value={phoneNumber}
                  onChangeText={setPhoneNumber}
                  placeholder="Enter phone number"
                  keyboardType="phone-pad"
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                />
              </View>

              <View className="mb-6">
                <Text className="text-sm font-semibold text-gray-900 mb-2">Website</Text>
                <TextInput
                  value={website}
                  onChangeText={setWebsite}
                  placeholder="https://yourwebsite.com"
                  keyboardType="url"
                  autoCapitalize="none"
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                />
              </View>

              <TouchableOpacity
                onPress={saveStoreDetails}
                disabled={saving}
                className="rounded-xl overflow-hidden"
              >
                <LinearGradient
                  colors={saving ? ['#9ca3af', '#6b7280'] : ['#8b5cf6', '#ec4899']}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 0 }}
                  style={{ paddingVertical: 16, alignItems: 'center' }}
                >
                  {saving && <ActivityIndicator color="#fff" />}
                  <Text className="text-white font-bold text-base">
                    {saving ? 'Saving...' : 'Save Details'}
                  </Text>
                </LinearGradient>
              </TouchableOpacity>
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* Operating Hours Modal */}
      <Modal
        visible={showHoursModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => setShowHoursModal(false)}
      >
        <View className="flex-1 bg-black/50 justify-end">
          <View className="bg-white rounded-t-3xl p-6" style={{ maxHeight: '90%' }}>
            <View className="flex-row items-center justify-between mb-6">
              <Text className="text-xl font-bold text-gray-900">Operating Hours</Text>
              <TouchableOpacity onPress={() => setShowHoursModal(false)}>
                <Ionicons name="close-circle" size={28} color="#9ca3af" />
              </TouchableOpacity>
            </View>

            <ScrollView showsVerticalScrollIndicator={false}>
              {DAYS.map((day) => (
                <View key={day} className="mb-4 bg-gray-50 rounded-2xl p-4">
                  <View className="flex-row items-center justify-between mb-3">
                    <Text className="text-base font-bold text-gray-900">{day}</Text>
                    <View className="flex-row items-center">
                      <Text className="text-sm text-gray-600 mr-2">
                        {operatingHours[day].isOpen ? 'Open' : 'Closed'}
                      </Text>
                      <Switch
                        value={operatingHours[day].isOpen}
                        onValueChange={(value) =>
                          setOperatingHours({
                            ...operatingHours,
                            [day]: { ...operatingHours[day], isOpen: value },
                          })
                        }
                        trackColor={{ false: '#d1d5db', true: '#86efac' }}
                        thumbColor={operatingHours[day].isOpen ? '#16a34a' : '#f3f4f6'}
                      />
                    </View>
                  </View>

                  {operatingHours[day].isOpen && (
                    <View className="flex-row gap-3">
                      <View className="flex-1">
                        <Text className="text-xs text-gray-600 mb-2">Open Time</Text>
                        <TextInput
                          value={operatingHours[day].openTime}
                          onChangeText={(value) =>
                            setOperatingHours({
                              ...operatingHours,
                              [day]: { ...operatingHours[day], openTime: value },
                            })
                          }
                          placeholder="09:00"
                          className="bg-white rounded-xl px-3 py-2 text-gray-900 text-center"
                        />
                      </View>
                      <View className="flex-1">
                        <Text className="text-xs text-gray-600 mb-2">Close Time</Text>
                        <TextInput
                          value={operatingHours[day].closeTime}
                          onChangeText={(value) =>
                            setOperatingHours({
                              ...operatingHours,
                              [day]: { ...operatingHours[day], closeTime: value },
                            })
                          }
                          placeholder="18:00"
                          className="bg-white rounded-xl px-3 py-2 text-gray-900 text-center"
                        />
                      </View>
                    </View>
                  )}
                </View>
              ))}

              <TouchableOpacity
                onPress={saveOperatingHours}
                disabled={saving}
                className="rounded-xl overflow-hidden mt-4"
              >
                <LinearGradient
                  colors={saving ? ['#9ca3af', '#6b7280'] : ['#3b82f6', '#8b5cf6']}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 0 }}
                  style={{ paddingVertical: 16, alignItems: 'center' }}
                >
                  {saving && <ActivityIndicator color="#fff" />}
                  <Text className="text-white font-bold text-base">
                    {saving ? 'Saving...' : 'Save Hours'}
                  </Text>
                </LinearGradient>
              </TouchableOpacity>
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* Add/Edit Item Modal */}
      <Modal
        visible={showItemModal}
        animationType="slide"
        transparent={true}
        onRequestClose={() => {
          setShowItemModal(false);
          resetItemForm();
        }}
      >
        <View className="flex-1 bg-black/50 justify-end">
          <View className="bg-white rounded-t-3xl p-6" style={{ maxHeight: '90%' }}>
            <View className="flex-row items-center justify-between mb-6">
              <Text className="text-xl font-bold text-gray-900">
                {editingItemId ? 'Edit Item' : 'Add New Item'}
              </Text>
              <TouchableOpacity onPress={() => {
                setShowItemModal(false);
                resetItemForm();
              }}>
                <Ionicons name="close-circle" size={28} color="#9ca3af" />
              </TouchableOpacity>
            </View>

            <ScrollView showsVerticalScrollIndicator={false}>
              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-900 mb-2">Item Name *</Text>
                <TextInput
                  value={currentItem.name}
                  onChangeText={(value) => setCurrentItem({ ...currentItem, name: value })}
                  placeholder="Enter item name"
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                />
              </View>

              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-900 mb-2">Description</Text>
                <TextInput
                  value={currentItem.description}
                  onChangeText={(value) => setCurrentItem({ ...currentItem, description: value })}
                  placeholder="Describe the item"
                  multiline
                  numberOfLines={3}
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                  style={{ textAlignVertical: 'top' }}
                />
              </View>

              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-900 mb-2">Price (₹) *</Text>
                <TextInput
                  value={currentItem.price}
                  onChangeText={(value) => setCurrentItem({ ...currentItem, price: value })}
                  placeholder="0.00"
                  keyboardType="numeric"
                  className="bg-gray-50 rounded-xl px-4 py-3 text-gray-900"
                />
              </View>

              <View className="mb-4">
                <Text className="text-sm font-semibold text-gray-900 mb-2">Category</Text>
                <ScrollView horizontal showsHorizontalScrollIndicator={false} className="gap-2">
                  {CATEGORIES.map((cat) => (
                    <TouchableOpacity
                      key={cat}
                      onPress={() => setCurrentItem({ ...currentItem, category: cat })}
                      className={`rounded-xl px-4 py-2 mr-2 ${
                        currentItem.category === cat ? 'bg-purple-500' : 'bg-gray-100'
                      }`}
                    >
                      <Text className={`text-sm font-semibold ${
                        currentItem.category === cat ? 'text-white' : 'text-gray-700'
                      }`}>
                        {cat}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </ScrollView>
              </View>

              <View className="mb-6 flex-row items-center justify-between bg-gray-50 rounded-xl px-4 py-3">
                <Text className="text-sm font-semibold text-gray-900">Available for Sale</Text>
                <Switch
                  value={currentItem.available}
                  onValueChange={(value) => setCurrentItem({ ...currentItem, available: value })}
                  trackColor={{ false: '#d1d5db', true: '#86efac' }}
                  thumbColor={currentItem.available ? '#16a34a' : '#f3f4f6'}
                />
              </View>

              <TouchableOpacity
                onPress={saveItem}
                disabled={saving}
                className="rounded-xl overflow-hidden"
              >
                <LinearGradient
                  colors={saving ? ['#9ca3af', '#6b7280'] : ['#f97316', '#ea580c']}
                  start={{ x: 0, y: 0 }}
                  end={{ x: 1, y: 0 }}
                  style={{ paddingVertical: 16, alignItems: 'center' }}
                >
                  {saving && <ActivityIndicator color="#fff" />}
                  <Text className="text-white font-bold text-base">
                    {saving ? 'Saving...' : (editingItemId ? 'Update Item' : 'Add Item')}
                  </Text>
                </LinearGradient>
              </TouchableOpacity>
            </ScrollView>
          </View>
        </View>
      </Modal>
    </View>
  );
}

export default StoreOwner;
