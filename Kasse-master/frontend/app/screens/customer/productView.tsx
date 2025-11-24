import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, ScrollView, Image, Pressable, Alert, ActivityIndicator } from 'react-native';
import { Search, Scan, ChevronRight } from 'lucide-react-native';
import { useLocalSearchParams, router } from 'expo-router';
import {
  doc,
  getDoc,
  collection,
  getDocs,
  query,
  where,
  addDoc,
  serverTimestamp
} from 'firebase/firestore';
import { db, auth } from '../../../firebase'; // Make sure auth is exported from your firebase config

interface Supermarket {
  id: string;
  sname: string;
  desc: string;
  supermarketImgUrl: string;
}

interface Product {
  id: string;
  productName: string;
  category: string;
  price: number;
  description: string;
  productImage: string;
  stockQuantity: number;
}

const ProductCategoryPage: React.FC = () => {
  const params = useLocalSearchParams();
  const id = params.id as string; // supermarket id
  const [searchQuery, setSearchQuery] = useState('');
  const [supermarket, setSupermarket] = useState<Supermarket | null>(null);
  const [categories, setCategories] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Fetch specific supermarket data and its products
  useEffect(() => {
    const fetchData = async () => {
      if (!id) return;
      
      try {
        // Fetch supermarket data
        const supermarketDoc = await getDoc(doc(db, 'supermarket', id as string));
        if (supermarketDoc.exists()) {
          setSupermarket({
            id: supermarketDoc.id,
            sname: supermarketDoc.data().sname || 'Unknown Store',
            desc: supermarketDoc.data().desc || 'No description available',
            supermarketImgUrl: supermarketDoc.data().supermarketImgUrl || '',
          });

          // Fetch products to get unique categories
          const productsRef = collection(db, 'supermarket', id, 'products');
          const productsSnapshot = await getDocs(productsRef);
          
          const uniqueCategories = [...new Set(
            productsSnapshot.docs.map(doc => doc.data().category as string)
          )].filter(category => category); // Remove any undefined/null values

          setCategories(uniqueCategories);
        }
      } catch (error) {
        console.error('Error fetching data:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [id]);

  // Get or create an ACTIVE cart only
  const getOrCreateActiveCart = async () => {
    if (!auth.currentUser?.uid) {
      throw new Error('User not authenticated');
    }

    const cartRef = collection(db, 'supermarket', id, 'cart'); // Use 'id' from params
    
    // Query for ACTIVE carts only
    const cartQuery = query(
      cartRef, 
      where('userId', '==', auth.currentUser.uid),
      where('status', '==', 'active')
    );
    
    const cartSnapshot = await getDocs(cartQuery);
    
    // If active cart exists, return its ID
    if (!cartSnapshot.empty) {
      return cartSnapshot.docs[0].id;
    }
    
    // Otherwise, create a new active cart
    const newCart = await addDoc(cartRef, {
      userId: auth.currentUser.uid,
      createdAt: serverTimestamp(),
      status: 'active'
    });
    
    return newCart.id;
  };

  // Handler for the cart button
  const handleGoToCart = async () => {
    if (!auth.currentUser) {
      Alert.alert("Error", "Please sign in to view your cart.");
      return;
    }
    try {
      const cartId = await getOrCreateActiveCart();
      // Now navigate WITH the required params
      router.push({
        pathname: "/screens/customer/cartContent",
        params: { 
          supermarketId: id, // 'id' is the supermarketId
          cartId: cartId 
        }
      });
    } catch (error) {
      console.error("Error getting cart:", error);
      Alert.alert("Error", "Could not find or create your cart.");
    }
  };


  const filteredCategories = categories.filter(category =>
    category.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (isLoading) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <ActivityIndicator size="large" color="#F59E0B" />
        <Text className="text-gray-600 mt-2">Loading supermarket...</Text>
      </View>
    );
  }

  if (!supermarket) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <Text className="text-gray-600">Supermarket not found</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-gray-50">
      {/* Header with Store Info */}
      <View className="bg-amber-400 px-4 pt-12 pb-4">
        {/* Search Bar */}
        <View className="relative my-2">
          <View className="absolute left-3 top-3 z-10">
            <Search size={18} color="#9ca3af" />
          </View>
          <TextInput
            placeholder="Search for items..."
            value={searchQuery}
            onChangeText={setSearchQuery}
            className="w-full pl-10 pr-4 py-3 rounded-2xl bg-white text-sm text-black"
            placeholderTextColor="#9ca3af"
          />
        </View>
        <View className="flex-row items-center justify-between mb-3">
          <View>
            <Text className="text-4xl font-bold text-black">
              {supermarket.sname.split(' ')[0]} {supermarket.sname.split(' ')[1] || ''}
            </Text>
            <Text className="text-xl font-bold text-black">
              {supermarket.sname.split(' ').slice(2).join(' ')}
            </Text>
            <Text className="text-xs text-gray-700 mt-0.5">
              {supermarket.desc}
            </Text>
          </View>
          <Image
            source={{ uri: supermarket.supermarketImgUrl }}
            className="w-24 h-20 rounded-xl"
            resizeMode="contain"
          />
        </View>
      </View>

      {/* Scanner Section */}
      <View className="px-4 pt-5 pb-4">
        <Pressable 
          className="bg-white rounded-xl border-2 border-dashed border-amber-400 py-5 items-center justify-center"
          onPress={() => router.push({
            pathname: "/screens/customer/scanner",
            params: { id: id }
          })}
        >
          <View className="items-center">
            <Scan size={40} color="#fbbf24" strokeWidth={1.5} />
            <Text className="text-lg font-bold text-black mt-2">
              Scanner
            </Text>
          </View>
        </Pressable>
      </View>

      {/* Categories List */}
      <ScrollView 
        className="flex-1"
        contentContainerStyle={{ paddingHorizontal: 16, paddingBottom: 100 }}
        showsVerticalScrollIndicator={false}
      >
        <View className="space-y-4">
          {filteredCategories.map((category) => (
            <Pressable
              key={category}
              onPress={() => router.push({
                pathname: "/screens/customer/products",
                params: { supermarketId: id, category: category }
              })}
              className="bg-white rounded-xl p-4 shadow-sm flex-row justify-between items-center"
            >
              <Text className="text-lg font-semibold text-gray-800">
                {category}
              </Text>
              <ChevronRight className="w-6 h-6 text-gray-400" />
            </Pressable>
          ))}
        </View>
      </ScrollView>

      {/* Go to Cart Button */}
      <View className="absolute bottom-0 left-0 right-0 px-4 py-4 bg-white border-t border-gray-200">
        <Pressable 
          onPress={handleGoToCart} 
          className="bg-amber-400 rounded-full py-3.5 flex-row items-center justify-center" 
          style={{ gap: 8 }}
        >
          <Text className="text-base font-bold text-black">
            GO TO CART
          </Text>
          <Text className="text-base font-bold text-black">
            →
          </Text>
        </Pressable>
      </View>
    </View>
  );
};

export default ProductCategoryPage;