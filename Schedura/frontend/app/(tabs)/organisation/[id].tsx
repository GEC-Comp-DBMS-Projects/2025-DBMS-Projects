import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StatusBar, Alert, Image, Animated, RefreshControl } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useUser } from '@clerk/clerk-expo';
import SafeBoundingView from '@/components/SafeBoundingView';
import { useTheme } from '@/contexts/ThemeContext';
import { getOrganisationById, getUserOrganisations, checkUserMembership, leaveOrganisation } from '@/supabase/controllers/organisation.controller';
import { getOrganisationJoinRequests, approveJoinRequest, rejectJoinRequest, createJoinRequest, getUserJoinRequests } from '@/supabase/controllers/join-requests.controller';
import { getOrganisationRoles } from '@/supabase/controllers/roles.controller';
import { useToast } from '@/components/Toast';
import { supabase } from '@/supabase/supabase';

// Skeleton Loader Component
const SkeletonLoader: React.FC<{ width: number | string; height: number; style?: any }> = ({ width, height, style }) => {
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

// Organisation Header Skeleton
const OrganisationHeaderSkeleton: React.FC<{ colors: any }> = ({ colors }) => (
  <View
    className="p-6 items-center mb-4 rounded-b-3xl"
    style={{ backgroundColor: colors.card }}
  >
    <SkeletonLoader width={120} height={120} style={{ borderRadius: 60, marginBottom: 16 }} />
    <SkeletonLoader width={200} height={28} style={{ marginBottom: 8 }} />
    <SkeletonLoader width={100} height={28} style={{ borderRadius: 20, marginBottom: 16 }} />
    <SkeletonLoader width={180} height={48} style={{ borderRadius: 12 }} />
  </View>
);

// Join Requests Section Skeleton
const JoinRequestsSkeleton: React.FC<{ colors: any }> = ({ colors }) => (
  <View className="p-5 rounded-lg border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
    <View className="flex-row items-center justify-between mb-4">
      <View className="flex-row items-center">
        <SkeletonLoader width={24} height={24} style={{ borderRadius: 12, marginRight: 12 }} />
        <SkeletonLoader width={120} height={20} />
      </View>
    </View>
    
    {[1, 2].map((i) => (
      <View key={i} className="p-4 rounded-lg border mb-3" style={{ backgroundColor: colors.backgroundSecondary, borderColor: colors.border }}>
        <View className="flex-row items-center mb-3">
          <SkeletonLoader width={40} height={40} style={{ borderRadius: 20, marginRight: 12 }} />
          <View className="flex-1">
            <SkeletonLoader width="70%" height={16} style={{ marginBottom: 4 }} />
            <SkeletonLoader width="90%" height={14} />
          </View>
        </View>
        <SkeletonLoader width="100%" height={14} style={{ marginBottom: 12 }} />
        <View className="flex-row gap-x-2">
          <SkeletonLoader width={70} height={32} style={{ borderRadius: 6 }} />
          <SkeletonLoader width={80} height={32} style={{ borderRadius: 6 }} />
        </View>
      </View>
    ))}
  </View>
);

// Info Section Skeleton
const InfoSectionSkeleton: React.FC<{ colors: any; title?: string; lines?: number }> = ({ colors, lines = 3 }) => (
  <View className="p-5 rounded-lg border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
    <View className="flex-row items-center mb-3">
      <SkeletonLoader width={24} height={24} style={{ borderRadius: 12, marginRight: 12 }} />
      <SkeletonLoader width={100} height={20} />
    </View>
    {Array.from({ length: lines }).map((_, i) => (
      <SkeletonLoader key={i} width={i === lines - 1 ? "80%" : "100%"} height={16} style={{ marginBottom: 8 }} />
    ))}
  </View>
);

// Info Grid Skeleton
const InfoGridSkeleton: React.FC<{ colors: any }> = ({ colors }) => (
  <View className="p-5 rounded-lg border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
    <View className="flex-row items-center mb-4">
      <SkeletonLoader width={24} height={24} style={{ borderRadius: 12, marginRight: 12 }} />
      <SkeletonLoader width={120} height={20} />
    </View>
    
    <View className="gap-y-3">
      {[1, 2, 3].map((i) => (
        <View key={i} className="flex-row justify-between">
          <SkeletonLoader width={80} height={16} />
          <SkeletonLoader width={100} height={16} />
        </View>
      ))}
    </View>
  </View>
);

export default function OrganisationDetailsScreen() {
  const { colors, isDark } = useTheme();
  const { id } = useLocalSearchParams();
  const { back } = useRouter();
  const { user } = useUser();
  const { showToast } = useToast();
  const [organisation, setOrganisation] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [isMember, setIsMember] = useState(false);
  const [isOwner, setIsOwner] = useState(false);
  const [joinRequests, setJoinRequests] = useState<any[]>([]);
  const [userJoinRequest, setUserJoinRequest] = useState<any>(null);
  const [requestsLoading, setRequestsLoading] = useState(false);
  const [members, setMembers] = useState<any[]>([]);
  const [membersLoading, setMembersLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  useEffect(() => {
    if (id && user?.id) {
      loadOrganisationDetails();
      checkMembership();
      checkUserJoinRequest();
    }
  }, [id, user?.id]);

  const loadOrganisationDetails = async () => {
    try {
      setLoading(true);
      const result = await getOrganisationById(id as string);
      if (result.error) {
        showToast({
          type: 'error',
          title: 'Error',
          description: result.error,
        });
        back();
        return;
      }
      setOrganisation(result.data);
      
      // Check if user is owner and load join requests
      if (user?.id && result.data?.ownerid === user.id) {
        setIsOwner(true);
        await loadJoinRequests();
        await loadMembers();
      } else {
        setIsOwner(false);
      }
    } catch (error) {
      console.error('Error loading organisation:', error);
      showToast({
        type: 'error',
        title: 'Error',
        description: 'Failed to load organisation details',
      });
      back();
    } finally {
      setLoading(false);
    }
  };

  const loadJoinRequests = async () => {
    if (!user?.id || !id) return;
    try {
      setRequestsLoading(true);
      const requests = await getOrganisationJoinRequests(id as string, user.id);
      setJoinRequests(requests);
    } catch (error) {
      console.error('Error loading join requests:', error);
    } finally {
      setRequestsLoading(false);
    }
  };

  const loadMembers = async () => {
    if (!id) return;
    try {
      setMembersLoading(true);
      const { data, error } = await supabase
        .from('user_role')
        .select(`
          *,
          users!inner (id, name, email),
          roles!inner (id, name, priviledges)
        `)
        .eq('orgid', id);

      if (!error && data) {
        setMembers(data);
      }
    } catch (error) {
      console.error('Error loading members:', error);
    } finally {
      setMembersLoading(false);
    }
  };

  const checkMembership = async () => {
    if (!user?.id) return;
    try {
      const userOrgs = await getUserOrganisations(user.id);
      const isAlreadyMember = userOrgs.some((org: any) => org.orgid == id);
      setIsMember(isAlreadyMember);
    } catch (error) {
      console.error('Error checking membership:', error);
    }
  };

  const checkUserJoinRequest = async () => {
    if (!user?.id) return;
    try {
      const requests = await getUserJoinRequests(user.id);
      const pendingRequest = requests.find((req: any) => 
        req.organisation_id === id && req.status === 'pending'
      );
      setUserJoinRequest(pendingRequest || null);
    } catch (error) {
      console.error('Error checking join request:', error);
    }
  };

  const handleJoinLeave = async () => {
    if (!user?.id || !organisation) {
      showToast({
        type: 'error',
        title: 'Error',
        description: 'Please log in to continue.',
      });
      return;
    }

    setActionLoading(true);
    try {
      if (isMember) {
        await leaveOrganisation(user.id, organisation.id);
        showToast({
          type: 'success',
          title: 'Success',
          description: `Left ${organisation.name} successfully!`,
        });
        setIsMember(false);
      } else {
        // Send join request instead of direct joining
        await createJoinRequest(user.id, organisation.id, `I would like to join ${organisation.name}`);
        showToast({
          type: 'success',
          title: 'Join request sent!',
          description: `You'll be notified when it's approved.`,
        });
        await checkUserJoinRequest(); // Refresh request status
      }
    } catch (error: any) {
      showToast({
        type: 'error',
        title: 'Error',
        description: error.message || 'Failed to update membership.',
      });
    } finally {
      setActionLoading(false);
    }
  };

  const handleApproveRequest = async (requestId: string, requestedRole: number) => {
    if (!user?.id) return;
    
    try {
      await approveJoinRequest(requestId, user.id, requestedRole);
      showToast({
        type: 'success',
        title: 'Success',
        description: 'Join request approved successfully!',
      });
      await loadJoinRequests(); // Refresh requests
    } catch (error: any) {
      showToast({
        type: 'error',
        title: 'Error',
        description: error.message || 'Failed to approve request.',
      });
    }
  };

  const handleRejectRequest = async (requestId: string) => {
    if (!user?.id) return;
    
    try {
      await rejectJoinRequest(requestId, user.id);
      showToast({
        type: 'success',
        title: 'Success',
        description: 'Join request rejected.',
      });
      await loadJoinRequests(); // Refresh requests
    } catch (error: any) {
      showToast({
        type: 'error',
        title: 'Error',
        description: error.message || 'Failed to reject request.',
      });
    }
  };

  const handleReassignRole = async (memberId: string, memberUserId: string) => {
    
    try {
      const res = await getOrganisationRoles(id as string);
      const roles = Array.isArray(res) ? res : [];

      if (!roles || roles.length === 0) {
        showToast({
          type: 'error',
          title: 'No Roles',
          description: 'No roles configured for this organisation.',
        });
        return;
      }

      const buttons = roles.map((r: any) => ({
        text: r.name || 'Role',
        onPress: async () => {
          try {
            await supabase
              .from('user_role')
              .update({ role: r.id })
              .eq('userid', memberUserId);

            showToast({
              type: 'success',
              title: 'Role Updated',
              description: 'Member role updated successfully.',
            });
            await loadMembers();
          } catch (err) {
            showToast({
              type: 'error',
              title: 'Error',
              description: 'Failed to update role.',
            });
          }
        },
      }));

      buttons.push({ text: 'Cancel', style: 'cancel' });
      Alert.alert('Reassign Role', 'Choose a new role for this member:', buttons);
    } catch (error) {
      console.error('Error reassigning role:', error);
    }
  };

  const handleRemoveMember = async (memberId: string, memberName: string) => {
    Alert.alert(
      'Remove Member',
      `Are you sure you want to remove ${memberName} from this organisation?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Remove',
          style: 'destructive',
          onPress: async () => {
            try {
              await supabase
                .from('user_role')
                .delete()
                .eq('userid', memberId);

              showToast({
                type: 'success',
                title: 'Member Removed',
                description: `${memberName} has been removed from the organisation.`,
              });
              await loadMembers();
            } catch (err) {
              showToast({
                type: 'error',
                title: 'Error',
                description: 'Failed to remove member.',
              });
            }
          },
        },
      ]
    );
  };

  if (loading) {
    return (
      <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
        
        {/* Header */}
        <View
          className="flex-row items-center justify-between px-4 py-3 border-b"
          style={{ backgroundColor: colors.card, borderBottomColor: colors.border }}
        >
          <TouchableOpacity onPress={back} className="p-2">
            <Ionicons name="arrow-back" size={24} color={colors.text} />
          </TouchableOpacity>
          <SkeletonLoader width={150} height={20} />
          <View className="w-10" />
        </View>

        <ScrollView className="flex-1">
          <OrganisationHeaderSkeleton colors={colors} />
          
          <View className="px-6 gap-y-6">
            <JoinRequestsSkeleton colors={colors} />
            <InfoSectionSkeleton colors={colors} lines={3} />
            <InfoGridSkeleton colors={colors} />
          </View>

          <View className="h-8" />
        </ScrollView>
      </SafeBoundingView>
    );
  }

  if (!organisation) {
    return (
      <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
        <View className="flex-1 justify-center items-center">
          <Ionicons name="business-outline" size={64} color={colors.textSecondary} style={{ marginBottom: 16 }} />
          <Text style={{ color: colors.text }} className="text-lg">Organisation not found</Text>
        </View>
      </SafeBoundingView>
    );
  }

  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
      
      {/* Header */}
      <View
        className="flex-row items-center justify-between px-4 py-3 border-b"
        style={{ backgroundColor: colors.card, borderBottomColor: colors.border }}
      >
        <TouchableOpacity onPress={back} className="p-2">
          <Ionicons name="arrow-back" size={24} color={colors.text} />
        </TouchableOpacity>
        <Text className="text-lg font-semibold" style={{ color: colors.text }}>
          Organisation Details
        </Text>
        <View className="w-10" />
      </View>

      <ScrollView 
        className="flex-1"
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => {
              loadJoinRequests()
              loadMembers();
            }}
            colors={["black"]}
            tintColor={colors.text}
          />
        }
      >
        {/* Organisation Header */}
        <View
          className="p-6 items-center mb-4 rounded-b-3xl"
          style={{ backgroundColor: colors.card }}
        >
          {organisation.logo ? (
            <Image 
              source={{ uri: organisation.logo }} 
              className="w-[120px] h-[120px] rounded-full mb-4"
              style={{ backgroundColor: colors.backgroundSecondary }}
            />
          ) : (
            <View
              className="w-[120px] h-[120px] rounded-full items-center justify-center mb-4"
              style={{ backgroundColor: colors.backgroundSecondary }}
            >
              <Ionicons name="business" size={48} color={colors.textSecondary} />
            </View>
          )}
          
          <Text className="text-2xl font-bold text-center mb-2" style={{ color: colors.text }}>
            {organisation.name}
          </Text>
          
          <View
            className="px-3 py-1.5 rounded-full mb-4"
            style={{ backgroundColor: colors.backgroundSecondary }}
          >
            <Text style={{ color: colors.text, fontWeight: '600' }}>
              {organisation.type}
            </Text>
          </View>

          {/* Join/Leave/Request Button - Show for non-owners */}
          {!isOwner && (
            <TouchableOpacity
              onPress={handleJoinLeave}
              disabled={actionLoading || (userJoinRequest && userJoinRequest.status === 'pending')}
              className={`px-8 py-3 rounded-xl flex-row items-center ${actionLoading ? 'opacity-70' : ''} ${isMember ? 'border' : ''}`}
              style={{
                backgroundColor: isMember 
                  ? colors.backgroundSecondary 
                  : userJoinRequest && userJoinRequest.status === 'pending'
                    ? '#FFA500'
                    : colors.accent,
                borderColor: colors.border
              }}
            >
              <Ionicons 
                name={
                  isMember 
                    ? "exit-outline" 
                    : userJoinRequest && userJoinRequest.status === 'pending'
                      ? "hourglass-outline"
                      : "add-circle-outline"
                } 
                size={20} 
                color={
                  isMember 
                    ? colors.text 
                    : userJoinRequest && userJoinRequest.status === 'pending'
                      ? "white"
                      : "white"
                } 
              />
              <Text className="text-base font-semibold ml-2" style={{ color: isMember ? colors.text : 'white' }}>
                {actionLoading 
                  ? 'Processing...' 
                  : isMember 
                    ? 'Leave Organisation' 
                    : userJoinRequest && userJoinRequest.status === 'pending'
                      ? 'Request Pending'
                      : 'Send Join Request'
                }
              </Text>
            </TouchableOpacity>
          )}
        </View>

        <View className="px-6 gap-y-6">
          
          {/* Join Requests Section - Only for Owners */}
          {isOwner && (
            <View className="p-5 rounded-lg border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <View className="flex-row items-center justify-between mb-4">
                <View className="flex-row items-center">
                  <Ionicons name="people-outline" size={24} color={colors.accent} />
                  <Text className="text-lg font-semibold ml-3" style={{ color: colors.text }}>
                    Join Requests
                  </Text>
                </View>
                {joinRequests.length > 0 && (
                  <View className="rounded-full min-w-[24px] h-6 justify-center items-center" style={{ backgroundColor: colors.accent }}>
                    <Text className="text-xs font-semibold" style={{ color: colors.primary }}>
                      {joinRequests.length}
                    </Text>
                  </View>
                )}
              </View>
              
              {requestsLoading ? (
                <Text className="text-base text-center" style={{ color: colors.textSecondary }}>
                  Loading requests...
                </Text>
              ) : joinRequests.length === 0 ? (
                <Text className="text-base text-center" style={{ color: colors.textSecondary }}>
                  No pending join requests
                </Text>
              ) : (
                <View className="gap-y-3">
                  {joinRequests.map((request: any) => (
                    <View key={request.id} className="p-4 rounded-lg border" style={{ backgroundColor: colors.backgroundSecondary, borderColor: colors.border }}>
                      <View className="flex-row items-center mb-3">
                        <View className="w-10 h-10 rounded-full justify-center items-center" style={{ backgroundColor: colors.accent }}>
                          <Text style={{color:colors.primary}} className="font-semibold text-base">
                            {request.users?.name?.charAt(0).toUpperCase() || 'U'}
                          </Text>
                        </View>
                        <View className="flex-1 ml-3">
                          <Text className="font-semibold" style={{ color: colors.text }}>
                            {request.users?.name || 'Unknown User'}
                          </Text>
                          <Text className="text-sm" style={{ color: colors.textSecondary }}>
                            {request.users?.email}
                          </Text>
                        </View>
                      </View>
                      
                      {request.message && (
                        <Text className="text-sm italic mb-3" style={{ color: colors.textSecondary }}>
                          "{request.message}"
                        </Text>
                      )}
                      
                      <View className="flex-col items-start justify-center">
                        <Text className="text-xs" style={{ color: colors.textSecondary }}>
                          Requested: {new Date(request.created_at).toLocaleDateString()}
                        </Text>
                        
                        <View className="mt-2 flex-row gap-x-2">
                          <TouchableOpacity
                            onPress={() => handleRejectRequest(request.id)}
                            className="px-3 py-1.5 rounded-md flex-row items-center"
                            style={{ backgroundColor: '#FF6B6B' }}
                          >
                            <Ionicons name="close" size={16} color="white" />
                            <Text className="text-xs font-semibold ml-1" style={{ color: 'white' }}>
                              Reject
                            </Text>
                          </TouchableOpacity>
                          
                          <TouchableOpacity
                            onPress={() => {
                              (async () => {
                                try {
                                  const res = await getOrganisationRoles(id as string);
                                  const roles = Array.isArray(res) ? res :  [];

                                  if (!roles || roles.length === 0) {
                                    Alert.alert(
                                      'No roles found',
                                      'No roles configured for this organisation. Approve as Member?',
                                      [
                                        { text: 'Cancel', style: 'cancel' },
                                        { text: 'OK', onPress: () => handleApproveRequest(request.id, 'member') }
                                      ]
                                    );
                                    return;
                                  }

                                  const buttons = roles.map((r: any) => {
                                    const label = r.name ?? r.label ?? String(r.role ?? 'Role');
                                    const value = r.id;
                                    return {
                                      text: label,
                                      onPress: () => handleApproveRequest(request.id, value)
                                    };
                                  });

                                  buttons.push({ text: 'Cancel', style: 'cancel' });

                                  Alert.alert('Assign Role', 'Choose a role for this member:', buttons);
                                } catch (error) {
                                  console.error('Error fetching roles:', error);
                                  Alert.alert(
                                    'Error',
                                    'Failed to load roles. Approve as Member instead?',
                                    [
                                      { text: 'Cancel', style: 'cancel' },
                                    ]
                                  );
                                }
                              })()
                            }}
                            className="px-3 py-1.5 rounded-md flex-row items-center"
                            style={{ backgroundColor: colors.accent }}
                          >
                            <Ionicons name="checkmark" size={16} color={colors.primary} />
                            <Text className="text-xs font-semibold ml-1" style={{ color: colors.primary }}>
                              Approve
                            </Text>
                          </TouchableOpacity>
                        </View>
                      </View>
                    </View>
                  ))}
                </View>
              )}
            </View>
          )}

          {/* Current Members Section - Only for Owners */}
          {isOwner && (
            <View className="p-5 rounded-lg border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <View className="flex-row items-center justify-between mb-4">
                <View className="flex-row items-center">
                  <Ionicons name="people" size={24} color={colors.accent} />
                  <Text className="text-lg font-semibold ml-3" style={{ color: colors.text }}>
                    Current Members
                  </Text>
                </View>
                {members.length > 0 && (
                  <View className="rounded-full min-w-[24px] h-6 justify-center items-center" style={{ backgroundColor: colors.accent }}>
                    <Text className="text-xs font-semibold" style={{ color: colors.primary }}>
                      {members.length}
                    </Text>
                  </View>
                )}
              </View>
              
              {membersLoading ? (
                <Text className="text-base text-center" style={{ color: colors.textSecondary }}>
                  Loading members...
                </Text>
              ) : members.length === 0 ? (
                <Text className="text-base text-center" style={{ color: colors.textSecondary }}>
                  No members yet
                </Text>
              ) : (
                <View className="gap-y-3">
                  {members.map((member: any) => (
                    <View key={member.userid} className="p-4 rounded-lg border" style={{ backgroundColor: colors.backgroundSecondary, borderColor: colors.border }}>
                      <View className="flex-row items-center justify-between mb-2">          
                        <View className="flex-row items-center flex-1">
                          <View className="w-10 h-10 rounded-full justify-center items-center" style={{ backgroundColor: colors.accent }}>
                            <Text style={{ color: colors.primary }} className="font-semibold text-base">
                              {member.users?.name?.charAt(0).toUpperCase() || 'U'}
                            </Text>
                          </View>
                          <View className="flex-1 ml-3">
                            <Text className="font-semibold" style={{ color: colors.text }}>
                              {member.users?.name || 'Unknown User'}
                            </Text>
                            
                          </View>
                        </View>
                        <View className="px-2 py-1 rounded-md" style={{ backgroundColor: colors.accent }}>
                          <Text className="text-xs font-semibold" style={{ color: colors.primary }}>
                            {member.roles?.name || 'Member'}
                          </Text>
                        </View>
                      </View>
                      
                      <View className="flex-row gap-x-2 mt-2">
                        <TouchableOpacity
                          onPress={() => handleReassignRole(member.id, member.users?.id)}
                          className="px-3 py-1.5 rounded-md flex-row items-center flex-1"
                          style={{ backgroundColor: colors.info }}
                        >
                          <Ionicons name="swap-horizontal" size={16} color="white" />
                          <Text className="text-xs font-semibold ml-1" style={{ color: 'white' }}>
                            Change Role
                          </Text>
                        </TouchableOpacity>
                        
                        <TouchableOpacity
                          onPress={() => handleRemoveMember(member.id, member.users?.name)}
                          className="px-3 py-1.5 rounded-md flex-row items-center"
                          style={{ backgroundColor: colors.error }}
                        >
                          <Ionicons name="trash" size={16} color="white" />
                          <Text className="text-xs font-semibold ml-1" style={{ color: 'white' }}>
                            Remove
                          </Text>
                        </TouchableOpacity>
                      </View>
                    </View>
                  ))}
                </View>
              )}
            </View>
          )}

          {/* Description */}
          <View className="p-5 rounded-lg border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
            <View className="flex-row items-center mb-3">
              <Ionicons name="document-text-outline" size={24} color={colors.accent} />
              <Text className="text-lg font-semibold ml-3" style={{ color: colors.text }}>
                About
              </Text>
            </View>
            <Text className="text-base" style={{ color: colors.textSecondary, lineHeight: 24 }}>
              {organisation.description || 'No description available.'}
            </Text>
          </View>

          {/* Organisation Info */}
          <View className="p-5 rounded-lg border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
            <View className="flex-row items-center mb-4">
              <Ionicons name="information-circle-outline" size={24} color={colors.accent} />
              <Text className="text-lg font-semibold ml-3" style={{ color: colors.text }}>
                Information
              </Text>
            </View>
            
            <View className="gap-y-3">
              <View className="flex-row justify-between">
                <Text className="text-base" style={{ color: colors.textSecondary }}>Type:</Text>
                <Text className="text-base font-medium" style={{ color: colors.text }}>
                  {organisation.type}
                </Text>
              </View>
              
              <View className="flex-row justify-between">
                <Text className="text-base" style={{ color: colors.textSecondary }}>Created:</Text>
                <Text className="text-base font-medium" style={{ color: colors.text }}>
                  {new Date(organisation.created_at).toLocaleDateString()}
                </Text>
              </View>
              
              <View className="flex-row justify-between">
                <Text className="text-base" style={{ color: colors.text }}>Membership Status:</Text>
                <View className="px-2 py-1 rounded-md" style={{ backgroundColor: isMember ? colors.accent : colors.backgroundSecondary }}>
                  <Text className="text-sm font-semibold" style={{ color: isMember ? colors.primary : colors.textSecondary }}>
                    {isMember ? 'Member' : 'Not a member'}
                  </Text>
                </View>
              </View>
            </View>
          </View>
        </View>

        {/* Bottom spacing */}
        <View className="h-8" />
      </ScrollView>
    </SafeBoundingView>
  );
}