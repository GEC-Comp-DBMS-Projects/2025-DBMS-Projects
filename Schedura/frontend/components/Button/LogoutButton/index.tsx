import { FontAwesome6 } from "@expo/vector-icons";
import { Text, TouchableOpacity } from "react-native";
import { useClerk } from '@clerk/clerk-expo'
import * as Linking from 'expo-linking'

function LogoutButton() {

  const { signOut } = useClerk()

  const onPress = async () => {
    try {
      await signOut()
      Linking.openURL(Linking.createURL('/'))
    } catch (err) {
      console.error(JSON.stringify(err, null, 2))
    }
  }

  return (
    <TouchableOpacity className=" flex flex-row items-center justify-center gap-5 border border-[rgba(0,0,0,0.3)] p-3 w-full rounded-xl" onPress={onPress}> 
        <FontAwesome6 name="google" size={28} color="black"/>
        <Text className="text-xl font-bold tracking-wide">Sign Out</Text>
    </TouchableOpacity>
  )
}

export default LogoutButton