import { useRef, useEffect } from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';
import LottieView from 'lottie-react-native';
import Authentication from '@/assets/animations/authentication.json';
import { useRouter } from 'expo-router';
export default function BookingSuccessfulPage() {
  const animation = useRef<LottieView>(null);
  const router = useRouter();
  useEffect(() => {
    const timer = setTimeout(() => {
      router.push('/(tabs)/bookings');
    }, 5000);
    return () => {
      if (timer) clearTimeout(timer);
    };
  }, []);

  return (
    <View className='bg-primary h-full justify-center items-center'>
      <LottieView
        autoPlay
        ref={animation}
        style={{
          width: "60%",
          height: "30%",
          backgroundColor: '#E9F0E9',
        }}
        // Find more Lottie files at https://lottiefiles.com/featured
        source={Authentication}
      />
      <View className='p-6'>
        <Text className='text-4xl text-center font-bold'>Payment Successful</Text>
        <Text className='text-center mt-4 text-2xl font-semibold'>Your payment was successful. Thank you for your purchase!</Text>
        <Text className='text-center mt-2 text-lg'>Redirecting to Bookings...</Text>
      </View>
    </View>
  );
}
