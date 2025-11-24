"use client";

import { useEffect, useState } from "react";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import IconSet from "react-native-vector-icons/MaterialIcons";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../../../firebase";
import { router } from "expo-router";

import {
  View,
  Text,
  ScrollView,
  Pressable,
  TextInput,
  Image,
} from "react-native";
interface Supermarket {
  id: string;
  sname: string;
  desc: string;
  supermarketImgUrl: string;
}

export default function SupermarketScreen() {
  const [searchQuery, setSearchQuery] = useState("");
  const [supermarkets, setSupermarkets] = useState<Supermarket[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchSupermarkets = async () => {
      try {
        const querySnapshot = await getDocs(collection(db, "supermarket"));
        const supermarketsData = querySnapshot.docs.map(doc => ({
          id: doc.id,
          sname: doc.data().sname || "Unknown Store",
          desc: doc.data().desc || "No description available",
          supermarketImgUrl: doc.data().supermarketImgUrl || "",
        }));
        setSupermarkets(supermarketsData);
      } catch (error) {
        console.error("Error fetching supermarkets:", error);
      } finally {
        setIsLoading(false);
      }
    };

    fetchSupermarkets();
  }, []);
  const [placeholderIndex, setPlaceholderIndex] = useState(0);
  const insets = useSafeAreaInsets();
  const placeholders = ["'Supermarkets'", "'Items'", "'Stores'"];

  useEffect(() => {
    const interval = setInterval(() => {
      setPlaceholderIndex((prev) => (prev + 1) % placeholders.length);
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  const filteredSupermarkets = supermarkets.filter(
    (store) =>
      store.sname.toLowerCase().includes(searchQuery.toLowerCase()) ||
      store.desc.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // <View className="w-52 h-52 rounded-3xl overflow-hidden bg-white items-center justify-center">
  //                 <Image
  //                   source={store.image}
  //                   style={{ width: "100%", height: "100%" }}
  //                   resizeMode="contain"
  //                 />
  //               </View>

  return (
    <View
      className="flex-1"
      style={{ backgroundColor: "#fff", paddingBottom: insets.bottom }}
    >
      {/* Fixed Header Section */}
      <View className="bg-amber-400 pb-4 pt-6">
        {/* Header */}
        <View className="pt-8 pb-4 px-4">
          <View className="flex-row items-center justify-between">
            <View className="flex-row items-center space-x-2">
              {/* Location Icon */}
              {/* <IconSet name="location-on" size={32} color="#fff" />
              <Text className="text-xl font-bold text-white underline">
                Margao
              </Text> */}
            </View>
            <Pressable onPress={() => router.push("/screens/customer/profile")} className="border rounded-3xl border-white px-4">
              <IconSet name="person" size={32} color="#fff" />
            </Pressable>
          </View>
        </View>

        {/* Search Bar */}
        <View className="px-4 pb-3 pt-4">
          <View className="flex-row items-center bg-white rounded-2xl border border-gray-400 px-4">
            <TextInput
              className="flex-1 py-3 text-gray-800 text-base"
              placeholder={"Search for " + placeholders[placeholderIndex]}
              placeholderTextColor="#9CA3AF"
              value={searchQuery}
              onChangeText={setSearchQuery}
            />
            <Pressable className="pl-2">
              <IconSet name="mic" size={24} color="#9CA3AF" />
            </Pressable>
          </View>
        </View>

        {/* Filter Pills */}
        {/* <View className="px-4 flex-row flex-wrap gap-2 pb-2 pt-4">
          {["Filter", "Sort by", "Offers", "★ 4.0 +"].map((label) => (
            <View
              key={label}
              className="border border-white rounded-full py-1 px-6"
            >
              <Text className="text-white text-sm font-medium">{label}</Text>
            </View>
          ))}
        </View> */}
      </View>

      {/* Scrollable Content */}
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 20 }}
      >
        {/* Collapsible Banner Image */}
        <View className="px-4 pt-4 pb-4 bg-amber-400 rounded-b-3xl">
          <Image
            source={require("../../../assets/images/ganeshOffer1.png")}
            className="w-full h-32 rounded-xl"
            resizeMode="cover"
          />
        </View>

        {/* Supermarket List */}
        <View className="px-2">
          {isLoading ? (
            <View className="flex-1 items-center justify-center py-8">
              <Text className="text-gray-600">Loading supermarkets...</Text>
            </View>
          ) : filteredSupermarkets.length === 0 ? (
            <View className="flex-1 items-center justify-center py-8">
              <Text className="text-gray-600">No supermarkets found</Text>
            </View>
          ) : (
            filteredSupermarkets.map((store) => (
            <Pressable 
              key={store.id} 
              className="rounded-2xl px-2 py-2 mb-4"
              onPress={() => router.push(`/screens/customer/productView?id=${store.id}`)}
            >
              <View className="flex-row items-center px-2 py-3 bg-white rounded-xl border border-gray-100">
                {/* Left: Store Image */}
                <View className="w-52 h-52 rounded-3xl overflow-hidden bg-white items-center justify-center">
                  <View className="absolute top-2 right-2 z-10">
                    <IconSet name="favorite-border" size={24} color="#FF4D4D" />
                  </View>
                  <Image
                    source={{ uri: store.supermarketImgUrl }}
                    style={{ width: "100%", height: "100%" }}
                    resizeMode="contain"
                  />
                </View>

                {/* Right: Store Info */}
                <View className="flex-1 space-y-1 px-4">
                  <Text className="text-lg font-bold text-gray-800">
                    {store.sname}
                  </Text>
                  <Text className="text-sm text-gray-600">
                    {store.desc}
                  </Text>
                </View>
              </View>
            </Pressable>
          )))}
        </View>
      </ScrollView>
    </View>
  );
}
