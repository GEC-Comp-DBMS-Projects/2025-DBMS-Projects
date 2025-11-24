import React, { useState, useEffect } from 'react';
import { View, Text, Pressable, ScrollView, ActivityIndicator } from 'react-native';
import { ChevronLeft, ChevronRight, Package } from 'lucide-react-native';
import { collection, query, where, getDocs, orderBy, Timestamp } from 'firebase/firestore';
import { db, auth } from '../../../firebase'; // Adjust path as needed
import { router } from 'expo-router';

interface Order {
  id: string;
  cartId: string;
  supermarketId: string;
  totalAmount: number;
  paidAt: Date;
  itemCount: number;
  status: string;
}

const OrderHistoryPage = () => {
  const [loading, setLoading] = useState(true);
  const [orders, setOrders] = useState<Order[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchOrderHistory();
  }, []);

  const fetchOrderHistory = async () => {
    if (!auth.currentUser) {
      setError('Please sign in to view order history');
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      const allOrders: Order[] = [];

      // Get all supermarkets
      const supermarketsRef = collection(db, 'supermarket');
      const supermarketsSnapshot = await getDocs(supermarketsRef);

      // For each supermarket, get completed carts for this user
      for (const supermarketDoc of supermarketsSnapshot.docs) {
        const supermarketId = supermarketDoc.id;
        const cartsRef = collection(db, 'supermarket', supermarketId, 'cart');
        
        const completedCartsQuery = query(
          cartsRef,
          where('userId', '==', auth.currentUser.uid),
          where('status', '==', 'completed')
        );

        const cartsSnapshot = await getDocs(completedCartsQuery);

        for (const cartDoc of cartsSnapshot.docs) {
          const cartData = cartDoc.data();
          
          // Get cart items count
          const cartItemsRef = collection(db, 'supermarket', supermarketId, 'cart', cartDoc.id, 'cartItems');
          const itemsSnapshot = await getDocs(cartItemsRef);

          allOrders.push({
            id: cartDoc.id,
            cartId: cartDoc.id,
            supermarketId: supermarketId,
            totalAmount: cartData.totalAmount || 0,
            paidAt: cartData.paidAt?.toDate() || new Date(),
            itemCount: itemsSnapshot.size,
            status: cartData.status
          });
        }
      }

      // Sort by date (newest first)
      allOrders.sort((a, b) => b.paidAt.getTime() - a.paidAt.getTime());
      setOrders(allOrders);
    } catch (error) {
      console.error('Error fetching order history:', error);
      setError('Error loading order history');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const handleOrderPress = (order: Order) => {
    router.push({
      pathname: '/screens/customer/orderDetails',
      params: {
        cartId: order.cartId,
        supermarketId: order.supermarketId
      }
    });
  };

  if (loading) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <ActivityIndicator size="large" color="#F59E0B" />
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
        <Text className="text-xl font-bold text-black">Past Orders</Text>
      </View>

      {error && (
        <View className="bg-red-100 px-4 py-3 m-4 rounded-lg">
          <Text className="text-red-700">{error}</Text>
        </View>
      )}

      <ScrollView className="flex-1 px-4 py-4">
        {orders.length === 0 ? (
          <View className="items-center justify-center py-20">
            <Package size={64} color="#D1D5DB" />
            <Text className="text-gray-500 text-lg mt-4">No orders yet</Text>
            <Text className="text-gray-400 text-sm mt-2">Your order history will appear here</Text>
          </View>
        ) : (
          orders.map((order) => (
            <Pressable
              key={order.id}
              onPress={() => handleOrderPress(order)}
              className="bg-white rounded-lg mb-3 p-4 shadow-sm"
            >
              <View className="flex-row justify-between items-start mb-2">
                <View className="flex-1">
                  <Text className="text-base font-semibold text-gray-900">
                    Order #{order.id.slice(0, 8)}
                  </Text>
                  <Text className="text-sm text-gray-500 mt-1">
                    {formatDate(order.paidAt)}
                  </Text>
                </View>
                <View className="items-end">
                  <Text className="text-lg font-bold text-gray-900">
                    ₹{order.totalAmount.toFixed(2)}
                  </Text>
                  <View className="bg-green-100 px-3 py-1 rounded-full mt-1">
                    <Text className="text-xs font-semibold text-green-700">Completed</Text>
                  </View>
                </View>
              </View>

              <View className="flex-row items-center justify-between mt-3 pt-3 border-t border-gray-100">
                <Text className="text-sm text-gray-600">
                  {order.itemCount} {order.itemCount === 1 ? 'item' : 'items'}
                </Text>
                <View className="flex-row items-center">
                  <Text className="text-sm text-amber-600 font-semibold mr-1">View Details</Text>
                  <ChevronRight size={16} color="#D97706" />
                </View>
              </View>
            </Pressable>
          ))
        )}
      </ScrollView>
    </View>
  );
};

export default OrderHistoryPage;