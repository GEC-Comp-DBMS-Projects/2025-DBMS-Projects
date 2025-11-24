import { ScrollView, Text, TouchableOpacity, View, TextInput, Alert, StatusBar } from 'react-native';
import SafeBoundingView from '@/components/SafeBoundingView';
import { useCallback, useState } from 'react';

import { Image } from 'react-native';
import { useUser } from '@clerk/clerk-expo';
import { AntDesign, Ionicons } from '@expo/vector-icons';
//@ts-ignore
import CSpace from "@/assets/images/illustrations/cspace.png"
import { searchOrganisations, getUserOrganisations } from '@/supabase/controllers/organisation.controller';
import { createJoinRequest, getUserJoinRequests } from '@/supabase/controllers/join-requests.controller';
import { useFocusEffect } from '@react-navigation/native';
import { useTheme } from '@/contexts/ThemeContext';
import { useRouter } from 'expo-router';
import { useToast } from '@/components/Toast';


export default function JoinOrganisationScreen() {
  const { colors, isDark } = useTheme();
  const { push } = useRouter();
  const [name, setName] = useState('');
  const [organisations, setOrganisations] = useState<any[]>([]);
  const [userOrganisations, setUserOrganisations] = useState<any[]>([]);
  const [userJoinRequests, setUserJoinRequests] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const { user } = useUser();
  const { showToast } = useToast();
  const search = async (name:string) => {
    setName(name);
    if (name.trim() === '') {
      setOrganisations([]);
      return;
    }
    const data = await searchOrganisations(name);
    if(data.error){
      showToast({
        type: 'error',
        title: 'Error',
        description: data.error,
      });
      return;
    }
    setOrganisations(data.data || []);
  };

  const handleJoinOrganisation = async (organisationId: string, organisationName: string) => {
    if (!user?.id) {
      showToast({
        type: 'error',
        title: 'Error',
        description: 'Please log in to send a join request.',
      });
      return;
    }

    setLoading(true);
    try {
      await createJoinRequest(user.id, organisationId, `I would like to join ${organisationName}`);
      showToast({
        type: 'success',
        title: 'Success',
        description: `Join request sent to ${organisationName}! You'll be notified when it's approved.`,
      });
      // Refresh user join requests
      await loadUserJoinRequests();
    } catch (error: any) {
      showToast({
        type: 'error',
        title: 'Error',
        description: error.message || 'Failed to send join request.',
      });
    } finally {
      setLoading(false);
    }
  };

  const loadUserOrganisations = async () => {
    if (!user?.id) return;
    try {
      const userOrgs = await getUserOrganisations(user.id);
      setUserOrganisations(userOrgs);
    } catch (error) {
      console.error('Error loading user organisations:', error);
    }
  };

  const loadUserJoinRequests = async () => {
    if (!user?.id) return;
    try {
      const requests = await getUserJoinRequests(user.id);
      setUserJoinRequests(requests);
    } catch (error) {
      console.error('Error loading join requests:', error);
    }
  };

  const isAlreadyMember = (organisationId: string) => {
    return userOrganisations.some(org => org.organisation_id === organisationId);
  };

  const hasPendingRequest = (organisationId: string) => {
    return userJoinRequests.some(req => req.organisation_id === organisationId && req.status === 'pending');
  };

  const getRequestStatus = (organisationId: string) => {
    const request = userJoinRequests.find(req => req.organisation_id === organisationId);
    return request?.status || null;
  };

  // Load user organizations and join requests on component mount
  useFocusEffect(
    useCallback(() => {
      //loadUserOrganisations();
      //loadUserJoinRequests();
    }, [user?.id])
  );

 
  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
      <ScrollView className="flex-1" style={{ backgroundColor: colors.backgroundSecondary }}>

        <View className="p-6 pb-12 rounded-b-[24px]" style={{ backgroundColor: colors.primary }}>
          <Text className="text-3xl font-bold mt-6" style={{ color: colors.accent }}>Join Organisation</Text>
          <Text className="mt-2 text-xl" style={{ color: colors.accent }}>Set up your space and let people {'\n'}reserve it with ease</Text>
          <Image source={CSpace} className="absolute -right-2 bottom-0" />
        </View>

        <View className="mb-6 p-6 gap-y-6">
          
          <View>
            <Text className="mb-1 font-semibold text-xl" style={{ color: colors.text }}>Search</Text>
            <View className="px-2 rounded-[12px] border-2 flex-row items-center gap-x-2" style={{ borderColor: colors.border, backgroundColor: colors.card }}>
              <Ionicons name="search" size={20} color={colors.textSecondary} style={{ paddingHorizontal: 8 }} />
              <TextInput
                placeholder="Convention Center"
                placeholderTextColor={colors.textSecondary}
                value={name}
                onChangeText={search}
                className="p-4 rounded-[12px] flex-1"
                style={{ color: colors.text }}
              />
            </View>
          </View>
        </View>

        <View className="px-6">
          {organisations.map((org:any) => {
            const isMember = isAlreadyMember(org.id);
            const pendingRequest = hasPendingRequest(org.id);
            const requestStatus = getRequestStatus(org.id);
            
            return (
              <View key={org.id} className="rounded-[16px] mb-4 p-5 border shadow-sm elevation-4" style={{ backgroundColor: colors.card, borderColor: colors.border, shadowColor: colors.shadow }}>
                <TouchableOpacity 
                  onPress={() => push(`/organisation/${org.id}` as any)}
                  className="mb-4"
                >
                  <View className="flex-row items-center gap-x-4">
                    {org.logo ? (
                      <Image source={{ uri: org.logo }} className="w-20 h-20 rounded-[16px]" style={{ backgroundColor: colors.backgroundSecondary }} />
                    ) : (
                      <View className="w-20 h-20 rounded-[16px] justify-center items-center" style={{ backgroundColor: colors.backgroundSecondary }}>
                        <Ionicons name="business" size={36} color={colors.textSecondary} />
                      </View>
                    )}
                    <View className="flex-1">
                      <Text className="text-xl font-extrabold mb-1" style={{ color: colors.text }}>{org.name}</Text>
                      <View className="px-2 py-1 rounded-[12px] self-start mb-2" style={{ backgroundColor: colors.backgroundSecondary }}>
                        <Text className="text-sm font-semibold" style={{ color: colors.text }}>{org.type}</Text>
                      </View>
                      <Text className="text-sm" style={{ color: colors.textSecondary, lineHeight: 20 }} numberOfLines={2}>
                        {org.description || 'No description available'}
                      </Text>
                    </View>
                    <Ionicons name="chevron-forward" size={20} color={colors.textSecondary} />
                  </View>
                </TouchableOpacity>
                
                {/* Action Buttons */}
                <View className="flex-row gap-x-3">
                  <TouchableOpacity
                    onPress={() => push(`/organisation/${org.id}` as any)}
                    className="flex-1 py-3 px-4 rounded-[12px] flex-row items-center justify-center gap-x-2"
                    style={{ backgroundColor: colors.backgroundSecondary }}
                  >
                    <Ionicons name="information-circle-outline" size={18} color={colors.text} />
                    <Text style={{ color: colors.text, fontWeight: '600' }}>View Details</Text>
                  </TouchableOpacity>
                  
                  <TouchableOpacity 
                    onPress={() => handleJoinOrganisation(org.id, org.name)}
                    disabled={isMember || pendingRequest || requestStatus === 'rejected' || loading}
                    className={`flex-1 py-3 px-4 rounded-[12px] flex-row items-center justify-center gap-x-2 ${isMember ? 'border' : ''}`}
                    style={{
                      backgroundColor: isMember 
                        ? colors.backgroundSecondary 
                        : pendingRequest 
                          ? '#FFA500' 
                          : requestStatus === 'rejected' 
                            ? '#FF6B6B' 
                            : colors.accent,
                      borderColor: colors.border,
                      opacity: loading ? 0.7 : 1
                    }}
                  >
                    <Ionicons 
                      name={
                        isMember 
                          ? "checkmark-circle" 
                          : pendingRequest 
                            ? "hourglass-outline" 
                            : requestStatus === 'rejected' 
                              ? "close-circle-outline" 
                              : "add-circle-outline"
                      } 
                      size={18} 
                      color={
                        isMember 
                          ? colors.textSecondary 
                          : pendingRequest || requestStatus === 'rejected' 
                            ? 'white' 
                            : 'white'
                      } 
                    />
                    <Text style={{ 
                      color: isMember ? colors.textSecondary : 'white', 
                      fontWeight: '600' 
                    }}>
                      {isMember 
                        ? 'Joined' 
                        : pendingRequest 
                          ? 'Pending' 
                          : requestStatus === 'rejected' 
                            ? 'Rejected' 
                            : 'Join Now'}
                    </Text>
                  </TouchableOpacity>
                </View>
              </View>
            );
          })}
          
          {organisations.length === 0 && name.trim() !== '' && (
            <View className="items-center mt-8">
              <Text className="text-base" style={{ color: colors.textSecondary }}>No organisations found</Text>
            </View>
          )}
          
          {name.trim() === '' && (
            <View className="items-center mt-8">
              <Ionicons name="search" size={48} color={colors.textSecondary} />
              <Text className="text-base mt-2" style={{ color: colors.textSecondary }}>Search for organisations to join</Text>
            </View>
          )}
        </View>
      </ScrollView>
    </SafeBoundingView>
  );
}
