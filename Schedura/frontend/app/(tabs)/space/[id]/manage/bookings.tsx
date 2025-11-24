import { acceptRequest, getRequestsForSpace } from '@/supabase/controllers/request.controller';
import { ScrollView, Text, TouchableOpacity, View, TextInput, Alert, StatusBar, Animated, Easing, RefreshControl } from 'react-native';
//@ts-ignore
import { useLocalSearchParams } from 'expo-router';
import { useEffect, useState } from 'react';
import { useUser } from '@clerk/clerk-expo';
import { getBookingsForSpace } from '@/supabase/controllers/booking.controller';
import { Feather } from '@expo/vector-icons';
import { useTheme } from '@/contexts/ThemeContext';


export default function BookingSpacesScreen() {
  const { colors } = useTheme();
  const [bookings, setBookings] = useState<any[]>([]);
  const [actionLoader, setActionLoader] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const params = useLocalSearchParams();
  const { user } = useUser();
  const space_id = params.id;

  const getBookings = async() => {
    setRefreshing(true);
    const {data, error} = await getBookingsForSpace(space_id as string);
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
    getBookings();
  },[])
  return (
    <ScrollView
      className="px-6"
      style={{ backgroundColor: colors.backgroundSecondary }}
      refreshControl={
        <RefreshControl
          refreshing={refreshing}
          onRefresh={getBookings}
          colors={[colors.accent]}
          tintColor={colors.accent}
        />
      }
    >
      {bookings.map((booking) => {
        return <BookingCard key={booking.id} booking={booking} getBookings={getBookings} setActionLoader={setRefreshing} actionLoader={refreshing} userId={user?.id!} colors={colors}/>
      })}
    </ScrollView>
  );
}


function BookingCard({booking, userId, setActionLoader, actionLoader, getBookings, colors}: {booking: any, userId: string, setActionLoader: any, actionLoader: any, getBookings: any, colors: any}) {

  let pendingTag = (
    <View className="px-3 py-1 rounded-[20px] bg-[#FEF3C7]">
      <Text className="text-[#92400E] font-semibold">Pending</Text>
    </View>
  )

  let acceptedTag = (
    <View className="px-3 py-1 rounded-[20px]" style={{ backgroundColor: colors.success + '20' }}>
      <Text style={{ color: colors.success }} className="font-semibold">Accepted</Text>
    </View>
  )
  return (
    <View className="p-6 border rounded-xl mb-4" style={{ borderColor: colors.border, backgroundColor: colors.card }}>
      <View className="flex-row items-center justify-between mb-2">
        <Text className="text-xl font-bold" style={{ color: colors.text }}><Feather name='home' size={18}/>  {booking.space.name.slice(0,15)} {booking.space.name.length > 10 && "..."}</Text>
        {booking.payment_status === 'pending' ? pendingTag : acceptedTag}
      </View>
      <Text className="text-lg" style={{ color: colors.textSecondary }}><Feather name='user' size={18}/>  {booking.users.name}</Text>
      <Text className="text-lg" style={{ color: colors.textSecondary }}><Feather name='calendar' size={18}/>  {new Date(booking.start).toLocaleDateString()} - {new Date(booking.end).toLocaleDateString()}</Text>
      
    </View>
  );
}