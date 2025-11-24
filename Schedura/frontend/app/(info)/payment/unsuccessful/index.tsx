import { useRef, useEffect } from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';
import LottieView from 'lottie-react-native';
import Unsuccessful from '@/assets/animations/unsuccessful.json';
import { useRouter } from 'expo-router';
export default function BookingUnsuccessfulPage() {
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
        source={Unsuccessful}
      />
      <View className='p-6'>
        <Text className='text-4xl text-center font-bold'>Payment Unsuccessful</Text>
        <Text className='text-center mt-4 text-2xl font-semibold'>Your payment was unsuccessful. Please try again later.</Text>
        <Text className='text-center mt-2 text-lg'>Redirecting to Bookings...</Text>
      </View>
    </View>
  );
}
