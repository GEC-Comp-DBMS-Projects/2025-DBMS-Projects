import { Stack, useRouter } from 'expo-router'
import { useAuth, useUser } from '@clerk/clerk-expo'
import { updateUserInfo } from '@/supabase/controllers/user.controller';
import { useEffect } from 'react';

export default function AuthRoutesLayout() {
  const { isSignedIn } = useAuth()
  const { user } = useUser()
  const { replace } = useRouter();

  const handleRedirect = async () => {  
      await updateUserInfo(user)
      return replace('/(tabs)/home')
  }

  useEffect(()=>{
    if (isSignedIn) {
      handleRedirect()
    }
  },[isSignedIn])

  return <Stack screenOptions={{headerShown:false}}/>
}