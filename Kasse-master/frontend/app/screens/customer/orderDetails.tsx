import React, { useState, useEffect } from 'react';
import { View, Text, Pressable, ScrollView, ActivityIndicator } from 'react-native';
import { ChevronLeft, Package, Calendar, CreditCard } from 'lucide-react-native';
import { collection, doc, getDoc, getDocs } from 'firebase/firestore';
import { db, auth } from '../../../firebase'; // Adjust path as needed
import { useLocalSearchParams, router } from 'expo-router';

interface OrderItem {
  id: string;
  productId: string;
  name: string;
  quantity: number;
  price: number;
}

interface OrderDetails {
  cartId: string;
  totalAmount: number;
  paidAt: Date;
  status: string;
  items: OrderItem[];
}

const OrderDetailsPage = () => {
  const params = useLocalSearchParams();
  const cartId = params.cartId as string;
  const supermarketId = params.supermarketId as string;

  const [loading, setLoading] = useState(true);
  const [orderDetails, setOrderDetails] = useState<OrderDetails | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchOrderDetails();
  }, []);

  const fetchOrderDetails = async () => {
    if (!auth.currentUser) {
      setError('Please sign in to view order details');
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      // Get cart document
      const cartRef = doc(db, 'supermarket', supermarketId, 'cart', cartId);
      const cartDoc = await getDoc(cartRef);

      if (!cartDoc.exists() || cartDoc.data().userId !== auth.currentUser.uid) {
        setError('Order not found');
        setLoading(false);
        return;
      }

      const cartData = cartDoc.data();

      // Get cart items
      const cartItemsRef = collection(db, 'supermarket', supermarketId, 'cart', cartId, 'cartItems');
      const itemsSnapshot = await getDocs(cartItemsRef);

      const items: OrderItem[] = [];
      itemsSnapshot.forEach((doc) => {
        items.push({
          id: doc.id,
          ...doc.data()
        } as OrderItem);
      });

      setOrderDetails({
        cartId: cartId,
        totalAmount: cartData.totalAmount || 0,
        paidAt: cartData.paidAt?.toDate() || new Date(),
        status: cartData.status,
        items: items
      });
    } catch (error) {
      console.error('Error fetching order details:', error);
      setError('Error loading order details');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <ActivityIndicator size="large" color="#F59E0B" />
      </View>
    );
  }

  if (error || !orderDetails) {
    return (
      <View className="flex-1 bg-gray-50">
        <View className="bg-amber-400 px-4 pt-12 pb-4">
          <Pressable onPress={() => router.back()} className="mb-2">
            <ChevronLeft size={24} color="#000" />
          </Pressable>
          <Text className="text-xl font-bold text-black">Order Details</Text>
        </View>
        <View className="flex-1 items-center justify-center">
          <Text className="text-red-500">{error || 'Order not found'}</Text>
        </View>
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
        <Text className="text-xl font-bold text-black">Order Details</Text>
      </View>

      <ScrollView className="flex-1 px-4 py-4">
        {/* Order Info Card */}
        <View className="bg-white rounded-lg p-4 mb-4 shadow-sm">
          <View className="flex-row items-center mb-3">
            <Package size={20} color="#F59E0B" />
            <Text className="text-lg font-bold text-gray-900 ml-2">
              Order #{cartId.slice(0, 8)}
            </Text>
          </View>

          <View className="flex-row items-center mb-2">
            <Calendar size={16} color="#666" />
            <Text className="text-sm text-gray-600 ml-2">
              {formatDate(orderDetails.paidAt)}
            </Text>
          </View>

          <View className="flex-row items-center justify-between mt-3 pt-3 border-t border-gray-100">
            <View className="bg-green-100 px-3 py-1 rounded-full">
              <Text className="text-sm font-semibold text-green-700">
                {orderDetails.status === 'completed' ? 'Completed' : orderDetails.status}
              </Text>
            </View>
            <Text className="text-xl font-bold text-gray-900">
              ₹{orderDetails.totalAmount.toFixed(2)}
            </Text>
          </View>
        </View>

        {/* Items List */}
        <View className="bg-white rounded-lg p-4 shadow-sm">
          <Text className="text-lg font-bold text-gray-900 mb-3">
            Order Items ({orderDetails.items.length})
          </Text>

          {orderDetails.items.map((item, index) => (
            <View 
              key={item.id}
              className={`py-3 ${index !== orderDetails.items.length - 1 ? 'border-b border-gray-100' : ''}`}
            >
              <View className="flex-row justify-between items-start">
                <View className="flex-1">
                  <Text className="text-base font-semibold text-gray-900">
                    {item.name}
                  </Text>
                  <Text className="text-sm text-gray-500 mt-1">
                    ₹{item.price.toFixed(2)} × {item.quantity}
                  </Text>
                </View>
                <Text className="text-base font-bold text-gray-900">
                  ₹{(item.price * item.quantity).toFixed(2)}
                </Text>
              </View>
            </View>
          ))}

          {/* Total */}
          <View className="flex-row justify-between items-center mt-4 pt-4 border-t-2 border-gray-200">
            <Text className="text-lg font-bold text-gray-900">Total</Text>
            <Text className="text-xl font-bold text-gray-900">
              ₹{orderDetails.totalAmount.toFixed(2)}
            </Text>
          </View>
        </View>

        {/* Payment Method */}
        <View className="bg-white rounded-lg p-4 mt-4 mb-4 shadow-sm">
          <View className="flex-row items-center">
            <CreditCard size={20} color="#666" />
            <Text className="text-base font-semibold text-gray-900 ml-2">
              Payment Method
            </Text>
          </View>
          <Text className="text-sm text-gray-600 mt-2 ml-7">Card Payment</Text>
        </View>
      </ScrollView>
    </View>
  );
};

export default OrderDetailsPage;