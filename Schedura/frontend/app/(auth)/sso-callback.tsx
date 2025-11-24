import { Text, View } from 'react-native';
import LottieView from 'lottie-react-native';
import Authentication from '@/assets/animations/authentication.json';

export default function SSOCallbackPage() {
  

  return (
    <View className='bg-primary h-full justify-center items-center'>
      <LottieView
        autoPlay
        style={{
          width: "60%",
          height: "40%",
          backgroundColor: '#E9F0E9',
        }}
        // Find more Lottie files at https://lottiefiles.com/featured
        source={Authentication}
      />
      <View className='p-6 px-10'>
        <Text className='text-4xl text-center font-semibold'>Authenticated Successfully!</Text>
        <Text className='text-center mt-4 text-2xl'>You have successfully logged into your account</Text>
      </View>
    </View>
  );
}
