import { ScrollView, Text, View, RefreshControl } from 'react-native';
//@ts-ignore
import { useLocalSearchParams } from 'expo-router';
import { useEffect, useState } from 'react';
import { useUser } from '@clerk/clerk-expo';
import { getLogsForSpace } from '@/supabase/controllers/logs.controller';
import { useTheme } from '@/contexts/ThemeContext';
import { TouchableOpacity, TextInput, Modal, FlatList, ActivityIndicator } from 'react-native';
import { supabase } from '@/supabase/supabase';
import { useToast } from '@/components/Toast';
import { Ionicons } from '@expo/vector-icons';


export default function LogsSpaceScreen() {
  const { colors, isDark } = useTheme();
  const { showToast } = useToast();
  const [logs, setLogs] = useState<any[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const params = useLocalSearchParams();
  const { user } = useUser();
  const space_id = params.id;
  const [orgMembers, setOrgMembers] = useState<any[]>([]);
  const [selectedUser, setSelectedUser] = useState<any>(null);
  const [rfidInput, setRfidInput] = useState('');
  const [showUserPicker, setShowUserPicker] = useState(false);
  const [assignLoading, setAssignLoading] = useState(false);

  const getLogs = async() => {
    setRefreshing(true);
    const {data, error} = await getLogsForSpace(space_id as string);
    if (error) {
      console.log("Error fetching logs: ", error);
      setRefreshing(false);
      return;
    }
    if(data) {
      setLogs(data);
    }
    setRefreshing(false);
  }

  const fetchOrgMembers = async () => {
    try {
      // Get space org
      const { data: spaceData } = await supabase
        .from('spaces')
        .select('organizationid')
        .eq('id', space_id as string)
        .single();

      if (!spaceData?.organizationid) return;

      // Get org members
      const { data: members } = await supabase
        .from('user_role')
        .select(`
          userid,
          users!inner (
            id,
            name,
            email,
            rfid
          )
        `)
        .eq('orgid', spaceData.organizationid);

      if (members) {
        setOrgMembers(members.map((m: any) => m.users));
      }
    } catch (err) {
      console.error('Error fetching org members:', err);
    }
  };

  const handleAssignRFID = async () => {
    if (!selectedUser || !rfidInput.trim()) {
      showToast({
        type: 'error',
        title: 'Missing Info',
        description: 'Please select a user and enter RFID',
      });
      return;
    }
    try {
      setAssignLoading(true);
      const { error } = await supabase
        .from('users')
        .update({ rfid: rfidInput.trim() })
        .eq('id', selectedUser.id);

      if (error) {
        showToast({
          type: 'error',
          title: 'Error',
          description: 'Failed to assign RFID',
        });
      } else {
        showToast({
          type: 'success',
          title: 'Success',
          description: 'RFID assigned successfully',
        });
        setRfidInput('');
        setSelectedUser(null);
        fetchOrgMembers();
      }
    } catch (err) {
      console.error('Error assigning RFID:', err);
      showToast({
        type: 'error',
        title: 'Error',
        description: 'An error occurred',
      });
    } finally {
      setAssignLoading(false);
    }
  };

  useEffect(()=>{
    getLogs();
    fetchOrgMembers();
  },[])
  return (
    <View style={{ flex: 1, backgroundColor: colors.backgroundSecondary }}>
      <ScrollView
        className="px-6"
        style={{ flex: 1 }}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={getLogs}
            colors={[colors.accent]}
            tintColor={colors.accent}
          />
        }
      >
        {logs.map((request) => {
          return (
            <LogCard
              key={request.id}
              request={request}
              getLogs={getLogs}
              setActionLoader={setRefreshing}
              actionLoader={refreshing}
              userId={user?.id!}
              colors={colors}
              isDark={isDark}
            />
          );
        })}
      </ScrollView>

      {/* Assign RFID Section */}
      <View
        className="px-6 py-4 border-t"
        style={{ borderTopColor: colors.border, backgroundColor: colors.card }}
      >
        <Text className="text-lg font-semibold mb-3" style={{ color: colors.text }}>
          Assign RFID to Member
        </Text>

        {/* User Picker */}
        <TouchableOpacity
          onPress={() => setShowUserPicker(true)}
          className="px-4 py-3 rounded-lg border mb-3 flex-row items-center justify-between"
          style={{ borderColor: colors.border, backgroundColor: colors.backgroundSecondary }}
        >
          <Text style={{ color: selectedUser ? colors.text : colors.textSecondary }}>
            {selectedUser ? `${selectedUser.name} (${selectedUser.email})` : 'Select User'}
          </Text>
          <Ionicons name="chevron-down" size={20} color={colors.textSecondary} />
        </TouchableOpacity>

        {/* RFID Input */}
        <TextInput
          placeholder="Enter RFID Tag"
          placeholderTextColor={colors.textSecondary}
          value={rfidInput}
          onChangeText={setRfidInput}
          className="px-4 py-3 rounded-lg border mb-3"
          style={{
            borderColor: colors.border,
            backgroundColor: colors.backgroundSecondary,
            color: colors.text,
          }}
        />

        {/* Assign Button */}
        <TouchableOpacity
          onPress={handleAssignRFID}
          disabled={assignLoading}
          className="py-3 rounded-lg flex-row items-center justify-center"
          style={{ backgroundColor: assignLoading ? colors.border : colors.accent }}
        >
          {assignLoading && <ActivityIndicator size="small" color={colors.primary} style={{ marginRight: 8 }} />}
          <Text className="font-semibold text-base" style={{ color: colors.primary }}>
            {assignLoading ? 'Assigning...' : 'Assign RFID'}
          </Text>
        </TouchableOpacity>
      </View>

      {/* User Picker Modal */}
      <Modal
        visible={showUserPicker}
        transparent
        animationType="slide"
        onRequestClose={() => setShowUserPicker(false)}
      >
        <TouchableOpacity
          activeOpacity={1}
          onPress={() => setShowUserPicker(false)}
          className="flex-1 justify-end"
          style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}
        >
          <TouchableOpacity
            activeOpacity={1}
            onPress={(e) => e.stopPropagation()}
            className="rounded-t-3xl px-6 py-6"
            style={{ backgroundColor: colors.card, maxHeight: '70%' }}
          >
            <View className="flex-row items-center justify-between mb-4">
              <Text className="text-xl font-bold" style={{ color: colors.text }}>
                Select User
              </Text>
              <TouchableOpacity onPress={() => setShowUserPicker(false)}>
                <Ionicons name="close" size={24} color={colors.textSecondary} />
              </TouchableOpacity>
            </View>

            <FlatList
              data={orgMembers}
              keyExtractor={(item) => item.id}
              renderItem={({ item }) => (
                <TouchableOpacity
                  onPress={() => {
                    setSelectedUser(item);
                    setShowUserPicker(false);
                  }}
                  className="py-3 px-4 rounded-lg mb-2 border"
                  style={{
                    borderColor: colors.border,
                    backgroundColor: selectedUser?.id === item.id ? colors.accent : colors.backgroundSecondary,
                  }}
                >
                  <Text className="font-semibold" style={{ color: selectedUser?.id === item.id ? colors.primary : colors.text }}>
                    {item.name}
                  </Text>
                  <Text className="text-sm" style={{ color: selectedUser?.id === item.id ? colors.primary : colors.textSecondary }}>
                    {item.email}
                  </Text>
                  {item.rfid && (
                    <Text className="text-xs mt-1" style={{ color: selectedUser?.id === item.id ? colors.primary : colors.textSecondary }}>
                      Current RFID: {item.rfid}
                    </Text>
                  )}
                </TouchableOpacity>
              )}
            />
          </TouchableOpacity>
        </TouchableOpacity>
      </Modal>
    </View>
  );
}


function LogCard({request, colors, isDark}: {request: any, userId: string, setActionLoader: any, actionLoader: any, getLogs: any, colors: any, isDark: boolean}) {

  const badgeBg = request.event_type === "checkin"
    ? (isDark ? '#065f46' : '#DBFCE7')
    : (isDark ? '#1e3a8a' : '#DBEAFE');
  const badgeTextColor = request.event_type === "checkin" ? '#10b981' : '#3b82f6';

  return (
    <View
      className="px-6 py-4 border rounded-lg mb-4 flex-row items-center justify-between"
      style={{ borderColor: colors.border, backgroundColor: colors.card }}
    >
      <View>
        <Text className="text-xl font-bold" style={{ color: colors.text }}>{request.users.name}</Text>
        <View className="flex-row items-center gap-x-2 mt-1">
          <Text className="font-medium" style={{ color: colors.textSecondary }}>{request.rfid}</Text>
          <View className="px-3 py-1 rounded-full" style={{ backgroundColor: badgeBg }}>
            <Text className="text-xs font-semibold" style={{ color: badgeTextColor }}>{request.event_type}</Text>
          </View>
        </View>
      </View>
      <View>
        <Text className="font-medium" style={{ color: colors.textSecondary }}>{new Date(request.created_at).toLocaleTimeString()}</Text>
      </View>
    </View>
  );
}