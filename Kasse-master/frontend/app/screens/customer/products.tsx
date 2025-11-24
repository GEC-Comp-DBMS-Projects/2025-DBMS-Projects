import React, { useState, useEffect } from 'react';
import { View, Text, TextInput, ScrollView, Image, Pressable } from 'react-native';
import { Search, ChevronLeft } from 'lucide-react-native';
import { useLocalSearchParams, router } from 'expo-router';
import { collection, getDocs, query, where } from 'firebase/firestore';
import { db } from '../../../firebase';

interface Product {
  id: string;
  productName: string;
  category: string;
  price: number;
  description: string;
  productImgUrl: string;
  stockQuantity: number;
}

const ProductsPage: React.FC = () => {
  const params = useLocalSearchParams();
  const supermarketId = params.supermarketId as string;
  const category = params.category as string;
  
  const [searchQuery, setSearchQuery] = useState('');
  const [products, setProducts] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchProducts = async () => {
      if (!supermarketId || !category) return;

      try {
        const productsRef = collection(db, 'supermarket', supermarketId, 'products');
        const q = query(productsRef, where('category', '==', category));
        const productsSnapshot = await getDocs(q);

        const productsData = productsSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        } as Product));

        setProducts(productsData);
      } catch (error) {
        console.error('Error fetching products:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchProducts();
  }, [supermarketId, category]);

  const filteredProducts = products.filter(product =>
    product.productName.toLowerCase().includes(searchQuery.toLowerCase()) ||
    product.description.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (isLoading) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <Text className="text-gray-600">Loading products...</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-gray-50">
      {/* Header */}
      <View className="bg-amber-400 px-4 pt-12 pb-4">
        <View className="flex-row items-center mb-4">
          <Pressable onPress={() => router.back()} className="mr-4">
            <ChevronLeft size={24} color="#000" />
          </Pressable>
          <Text className="text-xl font-bold text-black">{category}</Text>
        </View>

        {/* Search Bar */}
        <View className="relative">
          <View className="absolute left-3 top-3 z-10">
            <Search size={18} color="#9ca3af" />
          </View>
          <TextInput
            placeholder="Search products..."
            value={searchQuery}
            onChangeText={setSearchQuery}
            className="w-full pl-10 pr-4 py-3 rounded-2xl bg-white text-sm text-black"
            placeholderTextColor="#9ca3af"
          />
        </View>
      </View>

      {/* Products Grid */}
      <ScrollView
        className="flex-1 px-4 pt-4"
        contentContainerStyle={{ paddingBottom: 100 }}
        showsVerticalScrollIndicator={false}
      >
        <View className="flex-row flex-wrap justify-between">
          {filteredProducts.map((product) => (
            <Pressable
              key={product.id}
              className="w-[48%] bg-white rounded-xl p-3 mb-4"
              onPress={() => {
                router.push({
                  pathname: "/screens/customer/productDetail",
                  params: { 
                    supermarketId: supermarketId,
                    productId: product.id
                  }
                });
              }}
            >
              <Image
                source={{ uri: product.productImgUrl }}
                className="w-full h-32 rounded-lg mb-2"
                resizeMode="cover"
              />
              <Text className="text-sm font-semibold text-gray-800" numberOfLines={2}>
                {product.productName}
              </Text>
              <Text className="text-xs text-gray-500 mt-1" numberOfLines={1}>
                {product.description}
              </Text>
              <Text className="text-sm font-bold text-black mt-2">
                ₹{product.price.toFixed(2)}
              </Text>
              {product.stockQuantity <= 0 && (
                <Text className="text-xs text-red-500 mt-1">Out of stock</Text>
              )}
            </Pressable>
          ))}
        </View>
      </ScrollView>
    </View>
  );
};

export default ProductsPage;