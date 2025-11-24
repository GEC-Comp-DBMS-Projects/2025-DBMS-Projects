import React, { useState, useEffect } from 'react';
import { Text, View, StyleSheet, Pressable } from 'react-native';
import { Camera, CameraView, BarcodeScanningResult, useCameraPermissions } from 'expo-camera';
import { useLocalSearchParams, router } from 'expo-router';
import { collection, query, where, getDocs, addDoc, doc, getDoc, serverTimestamp } from 'firebase/firestore';
import { db, auth } from '../../../firebase';
import { ChevronLeft } from 'lucide-react-native';

const Scanner = () => {
  const params = useLocalSearchParams();
  const supermarketId = params.id as string;
  
  const [permission, requestPermission] = useCameraPermissions();
  const [scanned, setScanned] = useState(false);
  const [scanning, setScanning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastScannedCode, setLastScannedCode] = useState<string | null>(null);

  useEffect(() => {
    if (!permission?.granted) {
      requestPermission();
    }
  }, [permission]);

  // Get or create an ACTIVE cart only
  const getOrCreateActiveCart = async () => {
    if (!auth.currentUser?.uid) {
      throw new Error('User not authenticated');
    }

    const cartRef = collection(db, 'supermarket', supermarketId, 'cart');
    
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

  const handleBarCodeScanned = async ({ type, data }: { type: string; data: string }) => {
    setScanned(true);
    setScanning(true);
    setError(null);
    setLastScannedCode(data);

    if (!auth.currentUser) {
      setError('Please sign in to add items to cart');
      setScanning(false);
      return;
    }

    try {
      // Query the products subcollection for the scanned barcode
      const productsRef = collection(db, 'supermarket', supermarketId, 'products');
      const q = query(productsRef, where('barcode', '==', data));
      const querySnapshot = await getDocs(q);

      if (querySnapshot.empty) {
        setError('Product not found');
        return;
      }

      // Get the first matching product
      const product = querySnapshot.docs[0];
      const productData = product.data();

      // Get or create ACTIVE cart only
      const cartId = await getOrCreateActiveCart();

      // Add item to cartItems subcollection
      const cartItemsRef = collection(db, 'supermarket', supermarketId, 'cart', cartId, 'cartItems');
      await addDoc(cartItemsRef, {
        productId: product.id,
        name: productData.productName,
        price: productData.price,
        quantity: 1,
        addedAt: serverTimestamp()
      });
      
      // Navigate to cart content
      router.push({
        pathname: "/screens/customer/cartContent",
        params: { 
          supermarketId: supermarketId,
          cartId: cartId
        }
      });

    } catch (error) {
      console.error('Error processing product:', error);
      setError('Error adding product to cart');
    } finally {
      setScanning(false);
    }
  };

  if (!permission) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <Text className="text-gray-600">Requesting camera permission...</Text>
      </View>
    );
  }

  if (!permission.granted) {
    return (
      <View className="flex-1 items-center justify-center bg-gray-50">
        <Text className="text-gray-600">No access to camera</Text>
        <Pressable 
          className="mt-4 bg-amber-400 px-6 py-3 rounded-full"
          onPress={() => router.back()}
        >
          <Text className="text-black font-bold">Go Back</Text>
        </Pressable>
      </View>
    );
  }

  return (
    <View className="flex-1">
      {/* Header */}
      <View className="bg-amber-400 px-4 pt-12 pb-4">
        <Pressable onPress={() => router.back()} className="mb-2">
          <ChevronLeft size={24} color="#000" />
        </Pressable>
        <Text className="text-xl font-bold text-black">Scan Barcode</Text>
      </View>

      <View className="flex-1">
        <CameraView
          style={StyleSheet.absoluteFillObject}
          barcodeScannerSettings={{
            barcodeTypes: ["ean8", "ean13", "qr", "pdf417", "code128", "code39", "upc_e"]
          }}
          onBarcodeScanned={scanned ? undefined : handleBarCodeScanned}
        />

        {/* Overlay */}
        <View className="flex-1 items-center justify-center">
          {/* Scanning frame */}
          <View className="w-72 h-72 border-2 border-amber-400 rounded-lg">
            {scanning && (
              <View className="absolute inset-0 bg-black/50 items-center justify-center">
                <Text className="text-white">Searching...</Text>
              </View>
            )}
          </View>

          {/* Status and controls */}
          <View className="absolute bottom-20 left-0 right-0 items-center">
            {lastScannedCode && (
              <Text className="text-white bg-black/70 px-4 py-2 rounded-full mb-4">
                Barcode: {lastScannedCode}
              </Text>
            )}
            {error && (
              <Text className="text-red-500 bg-white px-4 py-2 rounded-full mb-4">
                {error}
              </Text>
            )}
            {scanned && !scanning && (
              <Pressable 
                className="bg-amber-400 px-6 py-3 rounded-full"
                onPress={() => {
                  setScanned(false);
                  setLastScannedCode(null);
                }}
              >
                <Text className="text-black font-bold">Scan Again</Text>
              </Pressable>
            )}
          </View>
        </View>
      </View>
    </View>
  );
};

export default Scanner;