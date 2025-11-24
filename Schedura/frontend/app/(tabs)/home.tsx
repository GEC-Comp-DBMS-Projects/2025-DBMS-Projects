import React, { useState, useEffect, FC } from "react";
import {
  View,
  Text,
  ScrollView,
  TextInput,
  TouchableOpacity,
  Image,
  SafeAreaView,
  StatusBar,
  RefreshControl,
  Animated,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { getSpaces } from "@/supabase/controllers/spaces.controller";
import { useUser } from '@clerk/clerk-expo';
import { getUserInfo } from '@/supabase/controllers/user.controller';
import type { UserProfile } from '@/types/database.type';
//@ts-ignore
import { useRouter } from 'expo-router';
import { useTheme } from '@/contexts/ThemeContext';
import { useToast } from "@/components/Toast";

interface Category {
  id: number;
  name: string;
  icon:
    | "heart-outline"
    | "briefcase-outline"
    | "gift-outline"
    | "people-outline"
    | "chatbubbles-outline"
    | "grid-outline";
}

const categories: Category[] = [
  { id: 0, name: "All", icon: "grid-outline" },
  { id: 1, name: "Wedding", icon: "heart-outline" },
  { id: 2, name: "Corporate", icon: "briefcase-outline" },
  { id: 3, name: "Birthday", icon: "gift-outline" },
  { id: 4, name: "Conference", icon: "people-outline" },
  { id: 5, name: "Social", icon: "chatbubbles-outline" },
];

// Skeleton Component
const SkeletonLoader: FC<{ width: number | string; height: number; style?: any }> = ({ width, height, style }) => {
  const animatedValue = new Animated.Value(0);

  React.useEffect(() => {
    Animated.loop(
      Animated.sequence([
        Animated.timing(animatedValue, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }),
        Animated.timing(animatedValue, {
          toValue: 0,
          duration: 1000,
          useNativeDriver: true,
        }),
      ])
    ).start();
  }, []);

  const opacity = animatedValue.interpolate({
    inputRange: [0, 1],
    outputRange: [0.3, 0.7],
  });

  return (
    <Animated.View
      style={[
        {
          width,
          height,
          backgroundColor: '#E0E0E0',
          borderRadius: 8,
          opacity,
        },
        style,
      ]}
    />
  );
};

// Featured Venue Skeleton
const FeaturedVenueSkeleton: FC<{ isDark: boolean }> = ({ isDark }) => (
  <View className="w-72 h-72 rounded-3xl overflow-hidden mr-4" style={{ backgroundColor: isDark ? '#2A2A2A' : '#F0F0F0' }}>
    <SkeletonLoader width="100%" height="100%" style={{ borderRadius: 24 }} />
    <View className="absolute bottom-0 left-0 right-0 p-4">
      <SkeletonLoader width="70%" height={24} style={{ marginBottom: 8 }} />
      <View className="flex-row gap-x-3">
        <SkeletonLoader width={100} height={16} />
        <SkeletonLoader width={80} height={16} />
      </View>
    </View>
  </View>
);

// Recommended Venue Skeleton
const RecommendedVenueSkeleton: FC<{ isDark: boolean }> = ({ isDark }) => (
  <View className="w-64 h-64 rounded-2xl overflow-hidden mr-4" style={{ backgroundColor: isDark ? '#2A2A2A' : '#F0F0F0' }}>
    <SkeletonLoader width="100%" height="100%" style={{ borderRadius: 16 }} />
    <View className="absolute bottom-0 left-0 right-0 p-3">
      <SkeletonLoader width="60%" height={20} />
    </View>
  </View>
);

// Promotion Skeleton
const PromotionSkeleton: FC<{ isDark: boolean }> = ({ isDark }) => (
  <View className="w-80 h-48 rounded-2xl overflow-hidden mr-4" style={{ backgroundColor: isDark ? '#2A2A2A' : '#F0F0F0' }}>
    <SkeletonLoader width="100%" height="100%" style={{ borderRadius: 16 }} />
    <View className="absolute top-0 left-0 right-0 p-4">
      <SkeletonLoader width="50%" height={20} style={{ marginBottom: 8 }} />
      <SkeletonLoader width="70%" height={16} />
    </View>
    <View className="absolute bottom-0 left-0 right-0 p-4">
      <SkeletonLoader width={120} height={16} />
    </View>
  </View>
);

const Home = () => {
  const { colors, isDark } = useTheme();
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const { navigate } = useRouter();
  const [activeCategory, setActiveCategory] = useState(0);
  const [spaces, setSpaces] = useState<any>([]);
  const [filteredSpaces, setFilteredSpaces] = useState<any>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const { showToast } = useToast();
  
  const { user: authUser } = useUser();

  const fetchProfile = async () => {
    const data = await getUserInfo(authUser?.id!);
    setProfile({ ...data, avatar_url: authUser?.imageUrl });
  };

  useEffect(() => {
    fetchProfile();
  }, []);

  const fetchSpaces = async () => {
    try {
      setLoading(true);
      const { data, error } = await getSpaces();
      if (error) {
        console.error("Error fetching spaces:", error);
      } else {
        setSpaces(data || []);
        setFilteredSpaces(data || []);
      }
    } catch (error) {
      console.error("Error in fetchSpaces:", error);
    }
    setLoading(false);
  };

  useEffect(()=>{
    fetchSpaces();
  }, []);
  
  useEffect(() => {
    if (activeCategory === 0) {
      setFilteredSpaces(spaces);
    } else {
      const categoryName = categories[activeCategory].name;
      const filtered = spaces.filter((space: any) => space.category === categoryName);
      setFilteredSpaces(filtered);
    }
  }, [activeCategory, spaces]);

  useEffect(() => {
    if (!searchQuery.trim()) {
      // If search is empty, apply category filter
      if (activeCategory === 0) {
        setFilteredSpaces(spaces);
      } else {
        const categoryName = categories[activeCategory].name;
        const filtered = spaces.filter((space: any) => space.category === categoryName);
        setFilteredSpaces(filtered);
      }
    } else {
      // Apply search filter
      const query = searchQuery.toLowerCase();
      let filtered = spaces.filter((space: any) => {
        const nameMatch = space.name?.toLowerCase().includes(query);
        const locationMatch = space.location?.toLowerCase().includes(query);
        const descriptionMatch = space.description?.toLowerCase().includes(query);
        return nameMatch || locationMatch || descriptionMatch;
      });

      // Also apply category filter if not "All"
      if (activeCategory !== 0) {
        const categoryName = categories[activeCategory].name;
        filtered = filtered.filter((space: any) => space.category === categoryName);
      }

      setFilteredSpaces(filtered);
    }
  }, [searchQuery, activeCategory, spaces]);

  const handleClearSearch = () => {
    setSearchQuery('');
  };
  

  return (
    <SafeAreaView className="flex-1" style={{ backgroundColor: colors.tertiary }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.primary} />
      <View className="rounded-b-3xl pt-12 pb-6" style={{ backgroundColor: colors.primary }}>
        <View className="flex-row items-center justify-between px-6 mb-2">
          <View className="flex-1">
            <Text className="text-3xl font-bold" style={{ color: colors.accent }}>Explore</Text>
          </View>
          <View className="flex-row items-center gap-x-3">
            <TouchableOpacity onPress={() => navigate("/(tabs)/organisation/create")} className="p-2 rounded-full" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(255,255,255,0.7)' }}>
              <Ionicons name="notifications-outline" size={22} color={colors.accent} />
            </TouchableOpacity>
            <TouchableOpacity 
              onPress={() => navigate('/(tabs)/spaces-map' as any)}
              className="p-2 rounded-full"
              style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(255,255,255,0.7)' }}
            >
              <Ionicons name="map-outline" size={24} color={colors.accent} />
            </TouchableOpacity>
          </View>
        </View>

        <View className="flex-row items-center gap-x-3 px-6 pt-2">
          <View className="flex-1 flex-row items-center rounded-xl px-4 border" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(255,255,255,0.8)', borderColor: isDark ? 'rgba(255,255,255,0.2)' : 'rgba(255,255,255,0.5)' }}>
            <Ionicons name="search" size={20} color={colors.textSecondary} />
            <TextInput
              placeholder="Search venues, locations..."
              placeholderTextColor={colors.textSecondary}
              className="py-3 ml-3 text-base"
              style={{ color: colors.text }}
              value={searchQuery}
              onChangeText={setSearchQuery}
            />
            {searchQuery.length > 0 && (
              <TouchableOpacity onPress={handleClearSearch} className="p-1">
                <Ionicons name="close-circle" size={20} color={colors.textSecondary} />
              </TouchableOpacity>
            )}
          </View>
          <TouchableOpacity className="p-3 rounded-xl border" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(255,255,255,0.8)', borderColor: isDark ? 'rgba(255,255,255,0.2)' : 'rgba(255,255,255,0.5)' }}>
            <Ionicons name="options-outline" size={20} color={colors.accent} />
          </TouchableOpacity>
        </View>
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          className="px-6 mt-6"
          contentContainerStyle={{ gap: 12 }}
        >
          {categories.map((category: Category, index: number) => (
            <TouchableOpacity
              key={category.id}
              onPress={() => setActiveCategory(index)}
              className="flex-row items-center px-4 py-2 rounded-full"
              style={{
                backgroundColor: index === activeCategory ? colors.accent : (isDark ? 'rgba(255,255,255,0.15)' : '#FFFFFF')
              }}
            >
              <Ionicons
                name={category.icon}
                size={16}
                color={index === activeCategory ? (isDark ? '#000' : '#fff') : colors.accent}
              />
              <Text className="text-xs font-medium ml-2" style={{
                color: index === activeCategory ? (isDark ? '#000' : '#fff') : colors.accent
              }}>
                {category.name}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      <ScrollView 
        refreshControl={<RefreshControl
          refreshing={loading}
          onRefresh={fetchSpaces}
          colors={["black"]}
          tintColor={colors.text}
        />} 
        showsVerticalScrollIndicator={false} 
        className="flex-1 h-full"
        style={{ backgroundColor: colors.tertiary }}>

        {/* Loading Skeletons */}
        {loading && (
          <>
            {/* Featured Venues Skeleton */}
            <View className="mt-8">
              <View className="flex-row justify-between items-center px-6 mb-4">
                <SkeletonLoader width={150} height={24} />
                <SkeletonLoader width={70} height={20} />
              </View>
              <ScrollView horizontal showsHorizontalScrollIndicator={false} className="pl-4">
                {[1, 2, 3].map((i) => (
                  <FeaturedVenueSkeleton key={i} isDark={isDark} />
                ))}
              </ScrollView>
            </View>

            {/* Recommended Skeleton */}
            <View className="mt-10">
              <View className="flex-row justify-between items-center px-6 mb-4">
                <SkeletonLoader width={180} height={24} />
                <SkeletonLoader width={70} height={20} />
              </View>
              <ScrollView horizontal showsHorizontalScrollIndicator={false} className="pl-4">
                {[1, 2, 3].map((i) => (
                  <RecommendedVenueSkeleton key={i} isDark={isDark} />
                ))}
              </ScrollView>
            </View>

            {/* Promotions Skeleton */}
            <View className="mt-10 mb-6">
              <View className="flex-row justify-between items-center px-6 mb-4">
                <SkeletonLoader width={160} height={24} />
                <SkeletonLoader width={70} height={20} />
              </View>
              <ScrollView horizontal showsHorizontalScrollIndicator={false} className="pl-4">
                {[1, 2, 3].map((i) => (
                  <PromotionSkeleton key={i} isDark={isDark} />
                ))}
              </ScrollView>
            </View>
          </>
        )}

        {/* No Results Message */}
        {filteredSpaces.length === 0 && !loading && (
          <View className="flex-1 items-center justify-center px-6 py-20">
            <Ionicons name="search-outline" size={64} color={colors.textTertiary} />
            <Text className="text-2xl font-bold mt-4" style={{ color: colors.text }}>No spaces found</Text>
            <Text className="text-center mt-2" style={{ color: colors.textSecondary }}>
              {searchQuery ? `No results for "${searchQuery}"` : 'No spaces available in this category'}
            </Text>
            {searchQuery && (
              <TouchableOpacity 
                onPress={handleClearSearch}
                className="px-6 py-3 rounded-full mt-6"
                style={{ backgroundColor: colors.accent }}
              >
                <Text className="font-semibold" style={{ color: isDark ? '#000' : '#fff' }}>Clear Search</Text>
              </TouchableOpacity>
            )}
          </View>
        )}

        {/* Featured Venues */}
        {filteredSpaces.length > 0 && !loading && (
          <View className="mt-8">
            <View className="flex-row justify-between items-center px-6 mb-4">
              <Text className="text-xl font-bold" style={{ color: colors.text }}>Featured Venues</Text>
              <TouchableOpacity>
                <Text className="font-semibold" style={{ color: colors.text }}>View All</Text>
              </TouchableOpacity>
            </View>

            <ScrollView decelerationRate={0.9} horizontal showsHorizontalScrollIndicator={false} className="pl-4">
              {filteredSpaces.map((hall: any) => (
              <TouchableOpacity
                key={hall.id}
                className="w-72 h-72 rounded-3xl overflow-hidden mr-4 bg-gray-700"
                onPress={() => navigate(`/space/${hall.id}`)}
              >
                <Image
                  source={{ uri: hall["spaces-images"]?.[0]?.link }}
                  className="absolute w-full h-full"
                />
                <View className="absolute inset-0 bg-black/30" />
                <View className="absolute bottom-0 left-0 right-0 p-4">
                  <Text className="text-white text-2xl font-bold mb-1">{hall.name}</Text>
                  <View className="flex-row items-center gap-x-3">
                    <View className="flex-row items-center gap-x-1">
                      <Ionicons name="location" size={16} color="white" />
                      <Text className="text-gray-200 text-sm">{hall.location ? hall.location.trim().split(/\s+/).slice(-2).join(' ') : ''}</Text>
                    </View>
                    <View className="flex-row items-center gap-x-1">
                      <Ionicons name="people" size={16} color="white" />
                      <Text className="text-gray-200 text-sm">{hall.capacity}</Text>
                    </View>
                  </View>
                </View>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>
        )}

        {/* Recommended */}
        {filteredSpaces.length > 0 && !loading && (
        <View className="mt-10">
          <View className="flex-row justify-between items-center px-6 mb-4">
            <Text className="text-xl font-bold" style={{ color: colors.text }}>Recommended for You</Text>
            <TouchableOpacity>
              <Text className="font-semibold" style={{ color: colors.text }}>View All</Text>
            </TouchableOpacity>
          </View>

          <ScrollView horizontal showsHorizontalScrollIndicator={false} className="pl-4">
            {filteredSpaces.slice(0, 5).map((hall: any) => (
              <TouchableOpacity
                key={`rec-${hall.id}`}
                className="w-64 h-64 rounded-2xl overflow-hidden mr-4 bg-gray-700"
                onPress={() => navigate(`/space/${hall.id}`)}
              >
                <Image
                  source={{ uri: hall["spaces-images"]?.[0]?.link }}
                  className="absolute w-full h-full"
                />
                <View className="absolute inset-0 bg-black/25" />
                <View className="absolute bottom-0 left-0 right-0 p-3">
                  <Text className="text-white text-lg font-semibold">{hall.name}</Text>
                </View>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>
        )}

        {/* Special Promotions */}
        {filteredSpaces.length > 0 && !loading && (
        <View className="mt-10 mb-6">
          <View className="flex-row justify-between items-center px-6 mb-4">
            <Text className="text-xl font-bold" style={{ color: colors.text }}>Special Promotions</Text>
            <TouchableOpacity>
              <Text className="font-semibold" style={{ color: colors.text }}>View All</Text>
            </TouchableOpacity>
          </View>

          <ScrollView horizontal showsHorizontalScrollIndicator={false} className="pl-4">
            {filteredSpaces.slice(0, 3).map((hall: any) => (
              <TouchableOpacity
                key={`promo-${hall.id}`}
                className="w-80 h-48 rounded-2xl overflow-hidden mr-4 bg-gray-700"
                onPress={() => navigate(`/space/${hall.id}`)}
              >
                <Image
                  source={{ uri: hall["spaces-images"]?.[0]?.link }}
                  className="absolute w-full h-full"
                />
                <View className="absolute inset-0 bg-black/40" />
                <View className="absolute top-0 left-0 right-0 p-4">
                  <Text className="text-white text-lg font-bold">Special Offer!</Text>
                  <Text className="text-white text-sm mt-1">
                    Book {hall.name} now and save 20%!
                  </Text>
                </View>
                <View className="absolute bottom-0 left-0 right-0 p-4">
                  <View className="flex-row items-center gap-x-2">
                    <Ionicons name="pricetag" size={16} color="white" />
                    <Text className="text-white text-sm font-semibold">
                      Limited Time Deal
                    </Text>
                  </View>
                </View>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
};


const App = () => {
  return <Home  />;
}


export default App;