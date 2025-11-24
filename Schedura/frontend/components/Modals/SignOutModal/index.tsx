import React, { useState } from 'react';
import {Modal, Text, View, TouchableOpacity} from 'react-native';
import { SafeAreaView, SafeAreaProvider } from 'react-native-safe-area-context';
import * as Linking from 'expo-linking'
import { useClerk } from '@clerk/clerk-expo';
import { useRouter } from 'expo-router';
import { useTheme } from '@/contexts/ThemeContext';
const SignOutModal = ({visible, setVisible}:{visible:boolean, setVisible:React.Dispatch<React.SetStateAction<boolean>>}) => {
  const { signOut } = useClerk();
  const { colors } = useTheme();
  const router = useRouter();
  const handleSignOut = async () => {
    try {
      await signOut()
      router.push('/')
      setVisible(false)
    } catch (err) {
      console.error(JSON.stringify(err, null, 2))
    }
  }

  return (
    <SafeAreaProvider>
      <SafeAreaView className='flex-1 justify-center items-center '>
        <Modal animationType="fade" transparent={true} visible={visible}>
          <View className='flex-1 justify-center items-center bg-black/40'>
            <View style={{backgroundColor: colors.background}} className='rounded-2xl items-center mx- pt-5  w-3/4 overflow-hidden'>
              <Text style={{color: colors.accent}} className='text-xl text-center px-10 font-semibold'>Are you sure you want to sign out?</Text>
              <Text style={{color: colors.textTertiary}} className='py-3 text-center px-10 text-black/70'>Next time you open the app, you will have to login in again</Text>
              <View className='w-full flex-row border-t ' style={{borderColor: colors.border}}>
                <TouchableOpacity  className='flex-1 py-3 ' onPress={()=>setVisible(false)}>
                    <Text style={{color: colors.textTertiary}} className='text-center font-semibold'>Cancel</Text>
                </TouchableOpacity>
                <TouchableOpacity className='flex-1 py-3 bg-red-400' onPress={handleSignOut}>
                    <Text className='text-center font-semibold text-white'>Sign Out</Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        </Modal>
      </SafeAreaView>
    </SafeAreaProvider>
  );
};



export default SignOutModal;