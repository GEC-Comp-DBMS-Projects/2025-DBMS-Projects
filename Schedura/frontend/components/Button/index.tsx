import { FontAwesome6 } from "@expo/vector-icons";
import { Text, TouchableOpacity } from "react-native";
import { Link } from "expo-router";

function Button({text, link}:{text:string, link:any}) {

  return (
    <Link href={link} className="bg-black flex flex-row items-center justify-center gap-5 border border-[rgba(0,0,0,0.3)] p-4 w-full rounded-2xl"> 
        <Text className="text-xl font-bold text-white tracking-wide">{text}</Text>
    </Link>
  )
}

export default Button