import { Image, ScrollView, Text, TouchableOpacity, View, StatusBar, RefreshControl } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { MaterialCommunityIcons, Ionicons } from '@expo/vector-icons';
//@ts-ignore
import { useRouter } from 'expo-router';
import { useEffect, useState } from 'react';
import { getMySpaces } from '@/supabase/controllers/spaces.controller';
import { useUser } from '@clerk/clerk-expo';
import { useTheme } from '@/contexts/ThemeContext';
import { getOrganisationByUserId } from '@/supabase/controllers/organisation.controller';
import { supabase } from '@/supabase/supabase';

export default function SpacesScreen() {
  const { colors, isDark } = useTheme();
  const { navigate, back } = useRouter();
  const [spaces, setSpaces] = useState<any>();
  const { user } = useUser();
  const [refreshing, setRefreshing] = useState(false);
  const [organization, setOrganization] = useState<any>(null);
  const [orgSpaces, setOrgSpaces] = useState<any[]>([]);

  const fetchMySpaces = async () => {
    const { data } = await getMySpaces(user?.id!);
    setSpaces(data);
  }
  
  useEffect(() => {
    fetchMySpaces()
  },[])

  const fetchOrganization = async () => {
      const orgData = await getOrganisationByUserId(user?.id!);
      setOrganization(orgData.data);
      
      // Fetch organization spaces if org exists
      if (orgData.data) {
        await fetchOrganizationSpaces(orgData.data.id);
      }
  };

  const fetchOrganizationSpaces = async (orgId: string) => {
    try {
      const { data, error } = await supabase
        .from('spaces')
        .select(`
          *,
          spaces-images (link)
        `)
        .eq('organizationid', orgId)
        //.neq('ownerid', user?.id!); // Exclude user's own spaces
      
      if (!error && data) {
        setOrgSpaces(data);
      }
    } catch (err) {
      console.error('Error fetching org spaces:', err);
    }
  };
  
  useEffect(() => {
    fetchMySpaces();
    fetchOrganization();
  }, []);

  return (
    <SafeAreaView className="flex-1" style={{ backgroundColor: colors.backgroundSecondary }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.primary} />
      <ScrollView
        showsVerticalScrollIndicator={false}
        className="flex-1"
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={() => {
              fetchMySpaces();
              fetchOrganization();
            }}
            colors={["black"]}
            tintColor={colors.text}
          />
        }
      >
        <View className="px-6 pt-6 pb-8 rounded-b-3xl" style={{ backgroundColor: colors.primary }}>
          <View className="mb-4">
            <Text className="text-3xl font-bold" style={{ color: colors.accent }}>My Spaces</Text>
            <Text className="text-lg mt-1" style={{ color: colors.textSecondary }}>Manage your venues</Text>
          </View>
          <View className="flex-row gap-x-2 mt-4">
            <View className="rounded-xl p-4 flex-1" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(255,255,255,0.8)' }}>
              <Text className="text-2xl font-bold" style={{ color: colors.text }}>{spaces?.length || 0}</Text>
              <Text className="text-sm" style={{ color: colors.textSecondary }}>Total Spaces</Text>
            </View>
            <View className="rounded-xl p-4 flex-1" style={{ backgroundColor: isDark ? 'rgba(255,255,255,0.1)' : 'rgba(255,255,255,0.8)' }}>
              <Text className="text-2xl font-bold" style={{ color: colors.success }}>Active</Text>
              <Text className="text-sm" style={{ color: colors.textSecondary }}>Status</Text>
            </View>
          </View>
        </View>
        {spaces && spaces.length > 0 && (
        <View className="px-6 pt-6 pb-2 flex-row items-center justify-between">
            <TouchableOpacity
              onPress={() => navigate('/(tabs)/space/analytics')}
              className="px-4 py-4 w-full rounded-xl flex-row justify-center items-center"
              style={{ backgroundColor: colors.tertiary }}
            >
              <Ionicons name="pie-chart-sharp" size={20} color={isDark ? '#fff' : '#000'} />
              <Text className="font-semibold ml-3" style={{ color: isDark ? '#fff' : '#000' }}>View Analytics</Text>
            </TouchableOpacity>
        </View>
        )}
        {/* Personal Spaces Section */}
        <View className="px-6 py-8">
          <View className="flex-row items-center justify-between mb-6">
            <Text className="text-xl font-bold" style={{ color: colors.text }}>Your Venues</Text>
            <TouchableOpacity
              onPress={() => navigate('/space/create')}
              className="px-4 py-2 rounded-xl flex-row items-center"
              style={{ backgroundColor: colors.accent }}
            >
              <Ionicons name="add" size={20} color={isDark ? '#000' : '#E9F0E9'} />
              <Text className="font-semibold ml-1" style={{ color: isDark ? '#000' : '#ffffff' }}>Add Space</Text>
            </TouchableOpacity>

            
          </View>

          {spaces && spaces.length > 0 ? (
            <ScrollView horizontal showsHorizontalScrollIndicator={false} className="">
              <View className="flex-row gap-x-4 pr-6">
                {spaces.map((space: any) => (
                  <TouchableOpacity
                    key={space.id}
                    onPress={() => navigate(`/spaces?id=${space.id}`)}
                    className="rounded-2xl overflow-hidden border w-72"
                    style={{ backgroundColor: colors.card, borderColor: colors.border }}
                  >
                    <View className="relative">
                      <Image
                        source={{
                          uri: space['spaces-images']?.[0]?.link || 'https://via.placeholder.com/300x200.png?text=No+Image+Available'
                        }}
                        className="h-48 w-full"
                        style={{ resizeMode: 'cover' }}
                      />
                      <View className="absolute inset-0" style={{ backgroundColor: 'rgba(0,0,0,0.15)' }} />
                      <View className="absolute top-3 right-3 rounded-full px-3 py-1" style={{ backgroundColor: colors.success }}>
                        <Text className="text-xs font-semibold" style={{ color: '#ffffff' }}>Active</Text>
                      </View>
                    </View>
                    <View className="p-5">
                      <Text className="text-xl font-bold mb-2" style={{ color: colors.text }}>{space.name}</Text>
                      <View className="gap-y-2">
                        <View className="flex-row items-center">
                          <View className="rounded-full p-1 mr-3" style={{ backgroundColor: colors.backgroundSecondary }}>
                            <Ionicons name="location" size={14} color={colors.textSecondary} />
                          </View>
                          <Text className="flex-1" style={{ color: colors.textSecondary }}>{space.location}</Text>
                        </View>
                        <View className="flex-row items-center">
                          <View className="rounded-full p-1 mr-3" style={{ backgroundColor: colors.backgroundSecondary }}>
                            <Ionicons name="people" size={14} color={colors.textSecondary} />
                          </View>
                          <Text style={{ color: colors.textSecondary }}>Up to {space.capacity} guests</Text>
                        </View>
                      </View>
                      <View className="flex-row mt-4 gap-x-2">
                        <TouchableOpacity
                          onPress={() => navigate(`/space/${space.id}/manage`)}
                          className="rounded-xl px-4 py-2 flex-1"
                          style={{ backgroundColor: colors.accent }}
                        >
                          <Text className="text-center font-semibold" style={{ color: isDark ? '#000' : '#ffffff' }}>Manage</Text>
                        </TouchableOpacity>
                        <TouchableOpacity
                          onPress={() => navigate(`/space/${space.id}/edit`)}
                          className="rounded-xl px-4 py-2 flex-1"
                          style={{ backgroundColor: colors.backgroundSecondary }}
                        >
                          <Text className="text-center font-semibold" style={{ color: colors.text }}>Edit</Text>
                        </TouchableOpacity>
                      </View>
                    </View>
                  </TouchableOpacity>
                ))}
              </View>
            </ScrollView>
          ) : (
            <View className="rounded-2xl border-2 border-dashed p-8 items-center justify-center" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <View className="rounded-full p-4 mb-4" style={{ backgroundColor: colors.backgroundSecondary }}>
                <MaterialCommunityIcons name="home-plus-outline" size={48} color={colors.textTertiary} />
              </View>
              <Text className="text-xl font-semibold mb-2" style={{ color: colors.text }}>No spaces yet</Text>
              <Text className="text-center mb-6" style={{ color: colors.textSecondary }}>Create your first venue to start managing bookings</Text>
              <TouchableOpacity
                onPress={() => navigate('/space/create')}
                className="py-3 px-6 rounded-xl"
                style={{ backgroundColor: colors.accent }}
              >
                <Text className="text-lg font-semibold" style={{ color: isDark ? '#000' : '#ffffff' }}>Create Your First Space</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>

        {/* Organization Spaces Section */}
        {organization && orgSpaces.length > 0 && (
          <View className="px-6 pb-8">
            <View className="flex-row items-center justify-between mb-6">
              <View>
                <Text className="text-xl font-bold" style={{ color: colors.text }}>Organization Spaces</Text>
                <Text className="text-sm" style={{ color: colors.textSecondary }}>{organization.name}</Text>
              </View>
              <TouchableOpacity onPress={() => navigate('/spaces-map')}>
                <Ionicons name="map-outline" size={24} color={colors.accent} />
              </TouchableOpacity>
            </View>

            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
              <View className="flex-row gap-x-4 pr-6">
                {orgSpaces.map((space: any) => (
                  <TouchableOpacity
                    key={space.id}
                    onPress={() => navigate(`/space/${space.id}`)}
                    className="rounded-2xl overflow-hidden border w-72"
                    style={{ backgroundColor: colors.card, borderColor: colors.border }}
                  >
                    <View className="relative">
                      <Image
                        source={{
                          uri: space['spaces-images']?.[0]?.link || 'https://via.placeholder.com/300x200.png?text=No+Image+Available'
                        }}
                        className="h-48 w-full"
                        style={{ resizeMode: 'cover' }}
                      />
                      <View className="absolute inset-0" style={{ backgroundColor: 'rgba(0,0,0,0.15)' }} />
                      <View className="absolute top-3 left-3 rounded-full px-3 py-1" style={{ backgroundColor: colors.info }}>
                        <Text className="text-xs font-semibold" style={{ color: '#ffffff' }}>Organization</Text>
                      </View>
                    </View>
                    <View className="p-5">
                      <Text className="text-xl font-bold mb-2" style={{ color: colors.text }}>{space.name}</Text>
                      <View className="gap-y-2">
                        <View className="flex-row items-center">
                          <View className="rounded-full p-1 mr-3" style={{ backgroundColor: colors.backgroundSecondary }}>
                            <Ionicons name="location" size={14} color={colors.textSecondary} />
                          </View>
                          <Text className="flex-1" style={{ color: colors.textSecondary }}>{space.location}</Text>
                        </View>
                        <View className="flex-row items-center">
                          <View className="rounded-full p-1 mr-3" style={{ backgroundColor: colors.backgroundSecondary }}>
                            <Ionicons name="people" size={14} color={colors.textSecondary} />
                          </View>
                          <Text style={{ color: colors.textSecondary }}>Up to {space.capacity} guests</Text>
                        </View>
                      </View>
                      <View className="flex-row mt-4 gap-x-2">
                        {
                          organization.roles[0].priviledges >= 2 &&
                          <TouchableOpacity
                            onPress={() => navigate(`/space/${space.id}/manage`)}
                            className="rounded-xl px-2 py-2 mt-4 flex-1"
                            style={{ backgroundColor: colors.accent }}
                          >
                            <Text className="text-center font-semibold" style={{ color: isDark ? '#000' : '#ffffff' }}>Manage</Text>
                          </TouchableOpacity>
                        }
                        <TouchableOpacity
                          onPress={() => navigate(`/space/${space.id}`)}
                          className="rounded-xl px-2 py-2 mt-4 flex-1"
                          style={{ backgroundColor: colors.tertiary }}
                        >
                          <Text className="text-center font-semibold" style={{ color: isDark ? '#ffffff' : '#000' }}>View</Text>
                        </TouchableOpacity>
                      </View>
                    </View>
                  </TouchableOpacity>
                ))}
              </View>
            </ScrollView>
          </View>
        )}

        <View className="px-6 pb-8">
          <View className="flex-row items-center justify-between mb-6">
            <Text className="text-xl font-bold" style={{ color: colors.text }}>Organization</Text>
            <TouchableOpacity>
              <Ionicons name="information-circle-outline" size={24} color={colors.textSecondary} />
            </TouchableOpacity>
          </View>
          {organization ? (
            <View className="rounded-2xl p-6 border" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <View className="flex-row items-center">
                {(() => {
                  const orgImage =
                  organization?.logo ||
                  organization?.image ||
                  organization?.['organisation-image']?.[0]?.link ||
                  organization?.['organisation_images']?.[0]?.link ||
                  organization?.images?.[0]?.link;

                  return (
                  <View className="w-16 h-16 rounded-lg overflow-hidden mr-4 items-center justify-center" style={{ backgroundColor: colors.tertiary }}>
                    {orgImage ? (
                    <Image
                      source={{ uri: orgImage }}
                      className="w-full h-full"
                      resizeMode="cover"
                    />
                    ) : (
                    <MaterialCommunityIcons name="office-building" size={32} color={colors.accent}  />
                    )}
                  </View>
                  );
                })()}
                <View className="flex-1">
                  <Text className="text-lg font-semibold mb-1" style={{ color: colors.text }}>{organization.name}</Text>
                  <View className='flex-row items-center'>
                    <Text style={{backgroundColor:colors.tertiary, color:colors.text}} className='p-0.5 mt-0.5 px-2 text-center rounded-md text-xs'>{organization.roles[0].name}</Text>
                  </View>
                </View>
              </View>
              {
                organization.roles[0].priviledges >= 2 &&
                <View className="flex-row items-center gap-x-2 mt-6">
                  <TouchableOpacity
                    onPress={() => navigate(`/organisation/${organization.id}`)}
                    className="py-2 px-4 rounded-xl flex-1"
                    style={{ backgroundColor: colors.accent, borderWidth: 2, borderColor: colors.accent }}
                  >
                    <Text className="text-base font-semibold text-center" style={{ color: isDark ? '#000' : '#ffffff' }}>Manage</Text>
                  </TouchableOpacity>
                  
                </View>
              }
            </View>
          ) : (
            <View className="rounded-2xl border-2 border-dashed p-8 items-center justify-center" style={{ backgroundColor: colors.card, borderColor: colors.border }}>
              <Text className="text-xl font-semibold mb-2" style={{ color: colors.text }}>No organization yet</Text>
              <Text className="text-center mb-6" style={{ color: colors.textSecondary }}>Create or join an organization to collaborate</Text>
              <View className="flex-row items-center gap-x-2 w-full">
                <TouchableOpacity
                  onPress={() => navigate('/organisation/create')}
                  className="py-2 px-4 rounded-xl flex-1"
                  style={{ backgroundColor: colors.accent, borderWidth: 2, borderColor: colors.accent }}
                >
                  <Text className="text-base font-semibold text-center" style={{ color: isDark ? '#000' : '#ffffff' }}>Create</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  onPress={() => navigate('/organisation/join')}
                  className="py-2 px-4 rounded-xl flex-1"
                  style={{ borderWidth: 2, borderColor: colors.border }}
                >
                  <Text className="text-base font-semibold text-center" style={{ color: colors.text }}>Join</Text>
                </TouchableOpacity>
              </View>
            </View>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}