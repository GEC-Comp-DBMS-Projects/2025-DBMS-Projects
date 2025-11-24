import { useRef, useEffect } from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';
import LottieView from 'lottie-react-native';
import PaperPlane from '@/assets/animations/paperplane.json';
import { useRouter } from 'expo-router';
export default function RequestSuccessfulPage() {
  const animation = useRef<LottieView>(null);
  const router = useRouter();
  useEffect(() => {
    const timer = setTimeout(() => {
      router.push('/(tabs)/bookings/requests');
    }, 5000);
    return () => {
      if (timer) clearTimeout(timer);
    };
  }, []);

  return (
    <View className='bg-primary h-full  items-center'>
      <LottieView
        autoPlay
        ref={animation}
        style={{
          width: "100%",
          height: "50%",
          backgroundColor: '#E9F0E9',
        }}
        // Find more Lottie files at https://lottiefiles.com/featured
        source={PaperPlane}
      />
      <View className='p-6'>
        <Text className='text-4xl text-center font-bold'>Request Sent Successfully!</Text>
        <Text className='text-center mt-4 text-xl font-semibold'>Your request has been sent. You will be notified once it is reviewed.</Text>
        <Text className='text-center mt-2 text-lg'>Redirecting to Requests...</Text>
      </View>
    </View>
  );
}
