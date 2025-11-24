import React, { useState, useEffect } from 'react';
import { View, Text, Pressable, ScrollView, ActivityIndicator, Alert } from 'react-native';
import { ChevronLeft, Trash2, Plus, Minus } from 'lucide-react-native';
import { collection, query, getDocs, doc, deleteDoc, updateDoc, getDoc, writeBatch, addDoc, serverTimestamp } from 'firebase/firestore';
import { db, auth } from '../../../firebase';
import { useLocalSearchParams, router } from 'expo-router';
import { useStripe } from '@stripe/stripe-react-native';

interface CartItem {
  id: string;
  productId: string;
  name: string;
  quantity: number;
  price: number;
  addedAt: Date;
}

const CartContentPage: React.FC = () => {
  const params = useLocalSearchParams();
  const supermarketId = params.supermarketId as string;
  const cartId = params.cartId as string;

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [paymentLoading, setPaymentLoading] = useState(false);

  const fetchCartItems = async () => {
    try {
      setLoading(true);
      setError(null);

      // Verify this is the user's cart
      const cartRef = doc(db, 'supermarket', supermarketId, 'cart', cartId);
      const cartDoc = await getDoc(cartRef);
      
      if (!cartDoc.exists() || cartDoc.data().userId !== auth.currentUser?.uid) {
        setError('Cart not found or access denied');
        setLoading(false);
        return;
      }

      // Check if cart is already completed (paid)
      if (cartDoc.data().status === 'completed') {
        setError('This cart has already been paid for');
        setCartItems([]);
        setLoading(false);
        return;
      }

      const cartItemsRef = collection(db, 'supermarket', supermarketId, 'cart', cartId, 'cartItems');
      const querySnapshot = await getDocs(cartItemsRef);
      
      const items: CartItem[] = [];
      querySnapshot.forEach((doc) => {
        items.push({
          id: doc.id,
          ...doc.data(),
          addedAt: doc.data().addedAt?.toDate() // Convert Firestore Timestamp to Date
        } as CartItem);
      });

      setCartItems(items.sort((a, b) => b.addedAt.getTime() - a.addedAt.getTime()));
    } catch (error) {
      console.error('Error fetching cart items:', error);
      setError('Error loading cart items');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCartItems();
  }, [supermarketId, cartId]);

  const removeItem = async (itemId: string) => {
    try {
      const itemRef = doc(db, 'supermarket', supermarketId, 'cart', cartId, 'cartItems', itemId);
      await deleteDoc(itemRef);
      setCartItems(prevItems => prevItems.filter(item => item.id !== itemId));
    } catch (error) {
      console.error('Error removing item:', error);
      setError('Error removing item');
    }
  };

  const updateQuantity = async (itemId: string, newQuantity: number) => {
    if (newQuantity < 1) return;

    try {
      const itemRef = doc(db, 'supermarket', supermarketId, 'cart', cartId, 'cartItems', itemId);
      await updateDoc(itemRef, { quantity: newQuantity });
      
      setCartItems(prevItems =>
        prevItems.map(item =>
          item.id === itemId ? { ...item, quantity: newQuantity } : item
        )
      );
    } catch (error) {
      console.error('Error updating quantity:', error);
      setError('Error updating quantity');
    }
  };

  const calculateTotal = () => {
    return cartItems.reduce((total, item) => total + (item.price * item.quantity), 0);
  };

  const { initPaymentSheet, presentPaymentSheet } = useStripe();

  const initializePayment = async () => {
    if (!auth.currentUser?.uid) {
      Alert.alert('Error', 'Please sign in to make a payment');
      return false;
    }

    try {
      const response = await fetch('https://kasse-backend.onrender.com/create-payment-intent', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          amount: Math.round(calculateTotal() * 100), // Convert to cents
          currency: 'eur',
          cartId,
          supermarketId,
          items: cartItems.map(item => ({
            id: item.productId,
            quantity: item.quantity,
            price: item.price,
            name: item.name
          })),
          userId: auth.currentUser.uid,
        }),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Payment initialization failed');
      }

      const { paymentIntent, ephemeralKey, customer } = await response.json();

      const { error } = await initPaymentSheet({
        merchantDisplayName: "Kasse Store",
        customerId: customer,
        customerEphemeralKeySecret: ephemeralKey,
        paymentIntentClientSecret: paymentIntent,
        allowsDelayedPaymentMethods: true,
        defaultBillingDetails: {
          name: auth.currentUser.displayName || '',
          email: auth.currentUser.email || '',
        },
        style: 'automatic'
      });

      if (error) {
        Alert.alert('Error', error.message);
        return false;
      }

      return true;
    } catch (error) {
      console.error('Payment initialization error:', error);
      Alert.alert('Error', error instanceof Error ? error.message : 'Unable to initialize payment');
      return false;
    }
  };

  const markCartAsPaid = async () => {
    try {
      // Update the current cart to mark it as paid/completed
      const cartRef = doc(db, 'supermarket', supermarketId, 'cart', cartId);
      await updateDoc(cartRef, {
        status: 'completed',
        paidAt: serverTimestamp(),
        totalAmount: calculateTotal()
      });
    } catch (error) {
      console.error('Error marking cart as paid:', error);
      throw error;
    }
  };

  const createNewCart = async () => {
    try {
      if (!auth.currentUser?.uid) {
        throw new Error('User not authenticated');
      }

      // Create a new empty cart for the user
      const cartsRef = collection(db, 'supermarket', supermarketId, 'cart');
      const newCartRef = await addDoc(cartsRef, {
        userId: auth.currentUser.uid,
        createdAt: serverTimestamp(),
        status: 'active'
      });

      return newCartRef.id;
    } catch (error) {
      console.error('Error creating new cart:', error);
      throw error;
    }
  };

  const handlePayPress = async () => {
    if (paymentLoading) return;
    
    try {
      setPaymentLoading(true);
      const initialized = await initializePayment();
      
      if (!initialized) {
        setPaymentLoading(false);
        return;
      }

      const { error } = await presentPaymentSheet();

      if (error) {
        Alert.alert('Error', error.message);
      } else {
        try {
          // Mark current cart as paid
          await markCartAsPaid();
          
          // Create a new cart for future orders
          const newCartId = await createNewCart();
          
          Alert.alert(
            'Payment Successful',
            'Thank you for your purchase!',
            [
              {
                text: 'OK',
                onPress: () => {
                  // Navigate back to supermarket page (not just back)
                  router.push(`/screens/customer/home`);
                }
              }
            ]
          );
        } catch (error) {
          console.error('Error in post-payment processing:', error);
          Alert.alert('Warning', 'Payment was successful but there was an error setting up your new cart. Please contact support.');
          router.back();
        }
      }
    } catch (error) {
      console.error('Payment error:', error);
      Alert.alert('Error', 'Payment failed');
    } finally {
      setPaymentLoading(false);
    }
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
        <Text className="text-xl font-bold text-black">Shopping Cart</Text>
      </View>

      {error && (
        <Text className="text-red-500 bg-white px-4 py-2 m-4 rounded-lg">
          {error}
        </Text>
      )}

      <ScrollView className="flex-1 p-4">
        {cartItems.length === 0 ? (
          <View className="items-center justify-center py-8">
            <Text className="text-gray-500">Your cart is empty</Text>
          </View>
        ) : (
          cartItems.map((item) => (
            <View key={item.id} className="bg-white rounded-lg mb-3 p-4 shadow-sm">
              <View className="flex-row justify-between items-center">
                <View className="flex-1">
                  <Text className="text-lg font-semibold">{item.name}</Text>
                  <Text className="text-gray-600">₹{item.price.toFixed(2)}</Text>
                </View>
                <View className="flex-row items-center space-x-4">
                  <Pressable 
                    onPress={() => updateQuantity(item.id, item.quantity - 1)}
                    className="p-2"
                  >
                    <Minus size={20} color="#000" />
                  </Pressable>
                  <Text className="text-lg font-semibold">{item.quantity}</Text>
                  <Pressable 
                    onPress={() => updateQuantity(item.id, item.quantity + 1)}
                    className="p-2"
                  >
                    <Plus size={20} color="#000" />
                  </Pressable>
                  <Pressable 
                    onPress={() => removeItem(item.id)}
                    className="p-2"
                  >
                    <Trash2 size={20} color="#EF4444" />
                  </Pressable>
                </View>
              </View>
            </View>
          ))
        )}
      </ScrollView>

      {cartItems.length > 0 && (
        <View className="bg-white p-4 shadow-lg">
          <Pressable 
            className={`bg-amber-400 py-4 rounded-full mb-4 ${paymentLoading ? 'opacity-50' : ''}`}
            onPress={handlePayPress}
            disabled={paymentLoading}
          >
            <View className="flex-row justify-center items-center">
              {paymentLoading && <ActivityIndicator size="small" color="#000" style={{marginRight: 8}} />}
              <Text className="text-center text-black font-bold text-lg">
                {paymentLoading ? 'Processing...' : 'Pay with Card'}
              </Text>
            </View>
          </Pressable>
          <View className="flex-row justify-between items-center">
            <Text className="text-lg font-semibold">Total:</Text>
            <Text className="text-lg font-bold">₹{calculateTotal().toFixed(2)}</Text>
          </View>
        </View>
      )}
    </View>
  );
};

export default CartContentPage;