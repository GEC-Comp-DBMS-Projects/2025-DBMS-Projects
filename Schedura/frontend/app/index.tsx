import { Image, Text, View, Dimensions } from 'react-native';
//@ts-ignore
import { Link, SplashScreen, useRouter } from 'expo-router';
import { useAuth, useUser } from '@clerk/clerk-expo';
import { updateUserInfo } from '@/supabase/controllers/user.controller';
import Button from '@/components/Button';
//@ts-ignore
import Logo from "@/assets/images/logo.jpg";
import SafeBoundingView from '@/components/SafeBoundingView';
import { useEffect } from 'react';

const { width } = Dimensions.get('window');
SplashScreen.preventAutoHideAsync();
export default function HomeScreen() {
  const { isSignedIn } = useAuth()
  const { user } = useUser()
  const { replace } = useRouter();
  

  const handleRedirect = async () => {
    const status = await updateUserInfo(user)
    await SplashScreen.hideAsync();
    if(status == 201 || status == 409) {
      return replace('/(tabs)/home')
    }
  }

  useEffect(() => {
    if (isSignedIn) {
      handleRedirect();
    } else {
      SplashScreen.hideAsync();
    }
  }, [isSignedIn]);


  return (
    <>
      <SafeBoundingView className="flex-1 bg-primary">
        <View className="flex-1 justify-between px-6 pt-16 ">
          <View className="flex-1 justify-center items-center">
            <View className="items-center mb-8">
              <View className="rounded-full p-8 mb-6">
                <Image 
                  style={{
                    height: Math.min(width * 0.5, 200), 
                    width: Math.min(width * 0.5, 200),
                    resizeMode: 'contain'
                  }}
                  className='rounded-full'
                  source={Logo}
                />
              </View>
              
              <Text className="text-5xl font-bold text-black text-center mb-3">
                Schedura.
              </Text>
              
              <Text className="text-lg text-black/80 text-center max-w-sm leading-6">
                Organize your time, amplify your productivity
              </Text>
            </View>

            <View className="flex-row justify-center gap-10 gap-x-8 mt-8">
              <View className="items-center">
                <View className="w-12 h-12 bg-black/20 rounded-full items-center justify-center mb-2">
                  <Text className="text-black text-xl">📅</Text>
                </View>
                <Text className="text-black/70 text-xs">Schedule</Text>
              </View>
              
              <View className="items-center">
                <View className="w-12 h-12 bg-black/20 rounded-full items-center justify-center mb-2">
                  <Text className="text-black text-xl">⏰</Text>
                </View>
                <Text className="text-black/70 text-xs">Reminders</Text>
              </View>
              
              <View className="items-center">
                <View className="w-12 h-12 bg-black/20 rounded-full items-center justify-center mb-2">
                  <Text className="text-black text-xl">📊</Text>
                </View>
                <Text className="text-black/70 text-xs">Analytics</Text>
              </View>
            </View>
          </View>

          <View className="">
            <Text className="text-md text-black/60 text-left  mb-4 px-1">
              By continuing you agree with our{' '}
              <Link 
                href="https://google.com" 
                className="text-black underline font-medium"
              >
                terms and conditions
              </Link>
              {' '}and{' '}
              <Link 
                href="https://google.com" 
                className="text-black underline font-medium"
              >
                privacy policy
              </Link>
            </Text>
            <View className='pb-5'>
              <Button 
                link="/(auth)" 
                text="Get Started"
              />
            </View>
          </View>
        </View>
      </SafeBoundingView>
    </>
  );
}