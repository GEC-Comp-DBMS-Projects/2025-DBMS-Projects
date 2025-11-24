import React from 'react';
import { View, Text, Image, ScrollView, Pressable } from 'react-native';
import { ChevronLeft, MapPin, Barcode } from 'lucide-react-native';
import { useLocalSearchParams, router } from 'expo-router';
import { doc, getDoc } from 'firebase/firestore';
import { db } from '../../../firebase';

interface Product {
  id: string;
  productName: string;
  description: string;
  price: number | string;
  barcode: string;
  aisleLocation: string;
  stockQuantity: number | string;
  productImgUrl: string;
  category: string;
}

const ProductDetailPage: React.FC = () => {
  const params = useLocalSearchParams();
  const [product, setProduct] = React.useState<Product | null>(null);
  const [isLoading, setIsLoading] = React.useState(true);

  React.useEffect(() => {
    const fetchProduct = async () => {
      try {
        const productDoc = await getDoc(doc(db, 'supermarket', params.supermarketId as string, 'products', params.productId as string));
        if (productDoc.exists()) {
          setProduct({
            ...(productDoc.data() as Product),
            id: productDoc.id
          });
        }
      } catch (error) {
        console.error('Error fetching product:', error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchProduct();
  }, [params.supermarketId, params.productId]);

  if (isLoading) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <Text className="text-gray-600">Loading product details...</Text>
      </View>
    );
  }

  if (!product) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <Text className="text-gray-600">Product not found</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-gray-50">
      {/* Header */}
      <View className="bg-amber-400 px-4 pt-12 pb-4">
        <Pressable onPress={() => router.back()} className="mb-2">
          <ChevronLeft size={24} color="#000" />
        </Pressable>
      </View>

      <ScrollView className="flex-1">
        {/* Product Image */}
        <View className="w-full aspect-square bg-white">
          <Image
            source={{ uri: product.productImgUrl }}
            className="w-full h-full"
            resizeMode="contain"
          />
        </View>

        {/* Product Info */}
        <View className="p-4 space-y-4">
          {/* Name and Price */}
          <View className="space-y-2">
            <Text className="text-2xl font-bold text-gray-900">
              {product.productName}
            </Text>
            <Text className="text-xl font-semibold text-amber-500">
              ${typeof product.price === 'number' ? product.price.toFixed(2) : Number(product.price).toFixed(2)}
            </Text>
          </View>

          {/* Location and Barcode */}
          <View className="space-y-2">
            <View className="flex-row items-center space-x-2">
              <MapPin size={20} color="#9ca3af" />
              <Text className="text-gray-600">Aisle: {product.aisleLocation}</Text>
            </View>
            <View className="flex-row items-center space-x-2">
              <Barcode size={20} color="#9ca3af" />
              <Text className="text-gray-600">Barcode: {product.barcode}</Text>
            </View>
          </View>

          {/* Category and Stock */}
          <View className="space-y-2">
            <View className="flex-row justify-between">
              <Text className="text-gray-600">Category</Text>
              <Text className="font-medium text-gray-900">{product.category}</Text>
            </View>
            <View className="flex-row justify-between">
              <Text className="text-gray-600">Stock</Text>
              <Text className={Number(product.stockQuantity) > 0 ? "font-medium text-green-600" : "font-medium text-red-600"}>
                {Number(product.stockQuantity) > 0 ? `${product.stockQuantity} in stock` : 'Out of stock'}
              </Text>
            </View>
          </View>

          {/* Description */}
          <View className="space-y-2">
            <Text className="text-lg font-semibold text-gray-900">Description</Text>
            <Text className="text-gray-600">{product.description}</Text>
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

export default ProductDetailPage;