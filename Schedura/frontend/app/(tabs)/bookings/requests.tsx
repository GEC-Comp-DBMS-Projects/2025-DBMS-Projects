import { acceptRequest, getRequestsForSpace, getRequestsOfUser } from '@/supabase/controllers/request.controller';
import { ScrollView, Text, TouchableOpacity, View, TextInput, Alert, StatusBar, Animated, Easing, RefreshControl } from 'react-native';
//@ts-ignore
import { useLocalSearchParams } from 'expo-router';
import { useEffect, useState } from 'react';
import { useUser } from '@clerk/clerk-expo';
import { Feather } from '@expo/vector-icons';
import { useTheme } from '@/contexts/ThemeContext';

export default function RequestsSpacesScreen() {
  const { colors, isDark } = useTheme();
  const [bookings, setBookings] = useState<any[]>([]);
  const [actionLoader, setActionLoader] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const params = useLocalSearchParams();
  const { user } = useUser();
  const space_id = params.id;

  const getMyRequests = async() => {
    setRefreshing(true);
    const {data, error} = await getRequestsOfUser(user?.id!);
    if (error) {
      console.log("Error fetching requests: ", error);
      return;
    }
    if(data) {
      setBookings(data);
    }
    setRefreshing(false);
  }

  useEffect(()=>{
    getMyRequests();
  },[])
  return (
    <ScrollView 
      className="px-6"
      style={{ backgroundColor: colors.tertiary }}
      refreshControl={
        <RefreshControl
          refreshing={refreshing}
          onRefresh={getMyRequests}
          colors={["black"]}
          tintColor={colors.text}
        />
      }
    >
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} />
      {bookings.length === 0 && !refreshing ? (
        <View className="items-center justify-center py-20">
          <Feather name="inbox" size={64} color={colors.textTertiary} />
          <Text className="text-xl font-bold mt-4" style={{ color: colors.text }}>No requests yet</Text>
          <Text className="text-center mt-2" style={{ color: colors.textSecondary }}>Your booking requests will appear here</Text>
        </View>
      ) : (
        bookings.map((booking) => {
          return <BookingCard key={booking.id} booking={booking} getBookings={getMyRequests} setActionLoader={setRefreshing} actionLoader={refreshing} userId={user?.id!} colors={colors} isDark={isDark}/>
        })
      )}
    </ScrollView>
  );
}


function BookingCard({
  booking,
  userId,
  setActionLoader,
  actionLoader,
  getBookings,
  colors,
  isDark
}: {
  booking: any,
  userId: string,
  setActionLoader: any,
  actionLoader: any,
  getBookings: any,
  colors: any,
  isDark: boolean
}) {
  let pendingTag = (
    <View className="px-3 py-1 rounded-full" style={{ backgroundColor: isDark ? '#713f12' : '#fef3c7' }}>
      <Text className="font-semibold" style={{ color: isDark ? '#fde047' : '#92400e' }}>Pending</Text>
    </View>
  )

  let acceptedTag = (
    <View className="px-3 py-1 rounded-full" style={{ backgroundColor: isDark ? '#14532d' : '#d1fae5' }}>
      <Text className="font-semibold" style={{ color: isDark ? '#86efac' : '#065f46' }}>Accepted</Text>
    </View>
  )
  
  return (
    <View className="p-6 border rounded-2xl mb-4" style={{ borderColor: colors.border, backgroundColor: colors.card }}>
      <View className="flex-row items-center justify-between mb-2">
        <Text className="text-xl font-bold flex-row items-center" style={{ color: colors.text }}>
          <Feather name='home' size={18} color={colors.text}/>  {booking.space.name.slice(0,15)} {booking.space.name.length > 10 && "..."}
        </Text>
        {booking.approved ? acceptedTag : pendingTag}
      </View>
      <Text className="text-lg flex-row items-center" style={{ color: colors.textSecondary }}>
        <Feather name='calendar' size={18} color={colors.textSecondary}/>  {new Date(booking.start).toLocaleDateString()} - {new Date(booking.end).toLocaleDateString()}
      </Text>
      
    </View>
  );
}
