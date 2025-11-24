import { acceptRequest, getRequestsForSpace, rejectRequest } from '@/supabase/controllers/request.controller';
import { ScrollView, Text, TouchableOpacity, View, TextInput, Alert, StatusBar, Animated, Easing, RefreshControl } from 'react-native';
//@ts-ignore
import { useLocalSearchParams } from 'expo-router';
import { useEffect, useState } from 'react';
import { useUser } from '@clerk/clerk-expo';
import { useTheme } from '@/contexts/ThemeContext';


export default function RequestsSpaceScreen() {
  const { colors } = useTheme();
  const [requests, setRequests] = useState<any[]>([]);
  const [actionLoader, setActionLoader] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const params = useLocalSearchParams();
  const { user } = useUser();
  const space_id = params.id;

  const getRequests = async() => {
    setRefreshing(true);
    const {data, error} = await getRequestsForSpace(space_id as string);
    if (error) {
      console.log("Error fetching requests: ", error);
      return;
    }
    if(data) {
      setRequests(data);
    }
    setRefreshing(false);
  }

  useEffect(()=>{
    getRequests();
  },[])
  return (
    <ScrollView
      className="px-6"
      style={{ backgroundColor: colors.backgroundSecondary }}
      refreshControl={
        <RefreshControl
          refreshing={refreshing}
          onRefresh={getRequests}
          colors={[colors.accent]}
          tintColor={colors.accent}
        />
      }
    >
      {requests.map((request) => {
        return (
          <RequestCard
            key={request.id}
            request={request}
            getRequests={getRequests}
            setActionLoader={setRefreshing}
            actionLoader={refreshing}
            userId={user?.id!}
            colors={colors}
          />
        );
      })}
    </ScrollView>
  );
}


function RequestCard({request, userId, setActionLoader, actionLoader, getRequests, colors}: {request: any, userId: string, setActionLoader: any, actionLoader: any, getRequests: any, colors: any}) {

  const handleAccept = async() => {
    if(actionLoader) return;
    console.log("Accepting request: ", request.id);
    setActionLoader(true);
    await acceptRequest(request.id, userId);
    await getRequests();
    setActionLoader(false);
  }

  const handleReject = async() => {
    if(actionLoader) return;
    console.log("Rejecting request: ", request.id);
    setActionLoader(true);
    await rejectRequest(request.id, userId);
    await getRequests();
    setActionLoader(false);
  }

  return (
    <View
      className="p-6 rounded-2xl mb-4 border"
      style={{ borderColor: colors.border, backgroundColor: colors.card }}
    >
      <Text className="text-2xl font-bold" style={{ color: colors.text }}>{request.space.name}</Text>
      <Text className="text-xl font-medium" style={{ color: colors.text }}>{request.users.name}</Text>
      <Text className="text-lg font-medium mb-4" style={{ color: colors.textSecondary }}>
        {new Date(request.start).toLocaleDateString()} - {new Date(request.end).toLocaleDateString()}
      </Text>

      <View className="w-full h-[1px] mb-4" style={{ backgroundColor: colors.border }} />

      <Text className="text-xl font-semibold" style={{ color: colors.text }}>Reason</Text>
      <Text className="text-base" style={{ color: colors.textSecondary }}>
        {request.reason || "No reason provided"}
      </Text>

      <View className="flex-row gap-x-4 mt-4">
        <TouchableOpacity
          onPress={handleAccept}
          className="flex-1 px-4 py-2.5 rounded-xl border"
          style={{ backgroundColor: colors.accent, borderColor: colors.border }}
        >
          <Text className="text-center font-semibold" style={{ color: colors.card }}>Accept</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={handleReject}
          className="flex-1 px-4 py-2.5 rounded-xl"
          style={{ backgroundColor: colors.error }}
        >
          <Text className="text-center font-semibold" style={{ color: 'white' }}>Reject</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}