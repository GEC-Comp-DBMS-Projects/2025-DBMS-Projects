import { useTheme } from '@/contexts/ThemeContext';
import React, { useState } from 'react';
import { Modal, Text, View, TouchableOpacity, TextInput, ScrollView } from 'react-native';
import { SafeAreaView, SafeAreaProvider } from 'react-native-safe-area-context';

const priviledges = [
  { id: 1, name: 'Create Request', value: 1 },
  { id: 2, name: 'Accept/Deny Request', value: 2 },
];

const RolesModal = ({
  visible,
  setVisible,
  orgid,
  setRoles
}: {
  visible: boolean;
  setVisible: React.Dispatch<React.SetStateAction<boolean>>;
  orgid: string;
  setRoles: React.Dispatch<React.SetStateAction<any[]>>;
}) => {
  const [roleName, setRoleName] = useState('');
  const [selectedPriviledges, setSelectedPriviledges] = useState<number[]>([]);
  const { colors } = useTheme();
  const togglePrivilege = (value: number) => {
    setSelectedPriviledges((prev) =>
      prev.includes(value) ? prev.filter((p) => p !== value) : [...prev, value]
    );
  };

  const calculatePrivilegeValue = () => {
    return selectedPriviledges.reduce((sum, val) => sum + val, 0);
  };

  const handleSubmit = async () => {
    const privilegeValue = calculatePrivilegeValue();
    
    // Call your Supabase controller here
    try {
      // Example: await addRole(orgid, roleName, privilegeValue);
      console.log('Submitting role:', { orgid, name: roleName, priviledges: privilegeValue });
      setRoles((prevRoles) => [
        ...prevRoles,
        { name: roleName, priviledges: privilegeValue },
      ]);
      // Reset form
      setRoleName('');
      setSelectedPriviledges([]);
      setVisible(false);
    } catch (error) {
      console.error('Error adding role:', error);
    }
  };

  const handleCancel = () => {
    setRoleName('');
    setSelectedPriviledges([]);
    setVisible(false);
  };

  return (
    <SafeAreaProvider>
      <SafeAreaView className="flex-1 justify-center items-center">
        <Modal animationType="fade" transparent={true} visible={visible}>
          <View className="flex-1 justify-center items-center bg-black/40">
            <View style={{backgroundColor: colors.background}} className="rounded-2xl  w-3/4 overflow-hidden max-h-[80%]">
              <View className="pt-5 px-5">
                <Text style={{color: colors.accent}} className="text-xl text-center font-semibold mb-4">Add Role</Text>
              </View>

              <ScrollView className="px-5">
                {/* Role Name Input */}
                <View className="mb-4">
                  <Text style={{color: colors.accent}} className="text-sm font-medium mb-2">Role Name</Text>
                  <TextInput
                    className="border border-gray-300 rounded-lg px-3 py-2"
                    style={{color: colors.accent}}
                    placeholder="Enter role name"
                    value={roleName}
                    onChangeText={setRoleName}
                  />
                </View>

                {/* Priviledges Checkboxes */}
                <View className="mb-4">
                  <Text style={{color: colors.accent}} className="text-sm font-medium mb-2">Priviledges</Text>
                  {priviledges.map((privilege) => (
                    <TouchableOpacity
                      key={privilege.id}
                      className="flex-row items-center mb-3"
                      onPress={() => togglePrivilege(privilege.value)}
                    >
                      <View
                        className={`w-5 h-5 border-2 rounded mr-3 items-center justify-center ${
                          selectedPriviledges.includes(privilege.value)
                            ? 'bg-blue-500 border-blue-500'
                            : 'border-gray-300'
                        }`}
                      >
                        {selectedPriviledges.includes(privilege.value) && (
                          <Text style={{color: colors.textTertiary}} className="text-xs">✓</Text>
                        )}
                      </View>
                      <Text style={{color: colors.text}} className="text-sm">{privilege.name}</Text>
                    </TouchableOpacity>
                  ))}
                </View>
              </ScrollView>

              {/* Buttons */}
              <View className="flex-row border-t border-gray-200">
                <TouchableOpacity
                  className="flex-1 py-4 items-center border-r border-gray-200"
                  onPress={handleCancel}
                >
                  <Text style={{color: colors.textTertiary}} className="font-medium">Cancel</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  className="flex-1 py-4 items-center"
                  onPress={handleSubmit}
                  disabled={!roleName.trim()}
                >
                  <Text
                    style={{color: colors.textTertiary}}
                    className={`font-medium`}
                  >
                    Submit
                  </Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        </Modal>
      </SafeAreaView>
    </SafeAreaProvider>
  );
};

export default RolesModal;