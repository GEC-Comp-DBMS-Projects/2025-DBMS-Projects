import Box from '@/components/Box';
import LoginButton from '@/components/Button/LoginButton';
import SafeBoundingView from '@/components/SafeBoundingView';
import { useState } from 'react';
import { TextInput, Text, View, Image } from 'react-native';
//@ts-ignore
import LoginIllustration from '@/assets/images/illustrations/login.png';

export default function HomeScreen() {
  return (
    <SafeBoundingView className="flex-1 overflow-hidden">
      <View className=' w-full flex-[0.75] justify-center items-center px-10'>
        <View className=' w-[600px] h-[600px] bg-primary'>
          <Image source={LoginIllustration} className='w-10 h-10 scale-x-[-1] object-contain absolute right-[-70%] top-[-20%]' style={{ height:1100, width:1100, resizeMode: 'contain' }} />
        </View>
      </View>
      <View className='w-full px-6 py-10 flex-[0.25] bg-black'>
        <Text className='text-3xl text-white font-bold mb-2 text-center'>Schedura.</Text>
        <Text className='text-primary text-center text-lg mb-5'>Login in to your account or get started</Text>
        <LoginButton /> 
        <Text className='text-primary text-sm mt-2'>Read on how your data will be used</Text>
      </View>
    </SafeBoundingView>
  );
}
