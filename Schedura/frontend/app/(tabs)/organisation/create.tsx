import { ScrollView, Text, TouchableOpacity, View, TextInput, Alert, StatusBar, Animated, Easing } from 'react-native';
import SafeBoundingView from '@/components/SafeBoundingView';
import { useCallback, useEffect, useRef, useState } from 'react';
import { createSpace } from '@/supabase/controllers/spaces.controller';
import * as DocumentPicker from "expo-document-picker";
import * as FileSystem from "expo-file-system/legacy";
import { Image } from 'react-native';
import { useUser } from '@clerk/clerk-expo';
import { decode } from 'base64-arraybuffer'
import { AntDesign, Ionicons } from '@expo/vector-icons';
//@ts-ignore
import CSpace from "@/assets/images/illustrations/cspace.png"
import RolesModal from '@/components/Modals/RolesModal';
import { createOrganisation } from '@/supabase/controllers/organisation.controller';
import { useFocusEffect } from '@react-navigation/native';
import { useTheme } from '@/contexts/ThemeContext';
import { useRouter } from 'expo-router';
import { useToast } from '@/components/Toast';

export default function CreateOrganisationScreen() {
  const { colors, isDark } = useTheme();
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [orgType, setOrgType] = useState<'Educational' | 'CoWorking'>('Educational');
  const [images, setImages] = useState<any>({filePath:"", fileData:"", fileType:"", fileUri:""})
  const [loading, setLoading] = useState(false)
  const [rolesModalVisible, setRolesModalVisible] = useState(false)
  const [roles, setRoles] = useState<{name:string, priviledges:number}[]>([])
  const { user } = useUser();
  const { push } = useRouter();
  const { showToast } = useToast();
  const rotateValue = new Animated.Value(0); 

  const rotateAnimation = rotateValue.interpolate({
      inputRange: [0, 1], 
      outputRange: ['0deg', '360deg'], 
  });
  useFocusEffect(
    useCallback(() => {
      let animation: Animated.CompositeAnimation | null = null;
      if (loading) {
        animation = Animated.loop(
          Animated.timing(rotateValue, {
            toValue: 1,
            duration: 2000,
            easing: Easing.linear,
            useNativeDriver: true,
          })
        );
        animation.start();
      }
      return () => {
        if (animation) {
          rotateValue.setValue(0);
          animation.stop();
        }
      };
    }, [loading])
  );

  async function pickAndUploadFile(spaceId: string) {
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: ["image/*"],
        copyToCacheDirectory: true
      });
  
      if (result.canceled) {
        console.log("User cancelled file picker");
        return null;
      }
      const file = result.assets[0];
      const fileExt = file.name.split(".").pop();
      const fileName = `${spaceId}-${Date.now()}.${fileExt}`;
      const filePath = `${fileName}`;
      const base64 = await FileSystem.readAsStringAsync(file.uri, {
        encoding: FileSystem.EncodingType.Base64,
      });
      const fileData = decode(base64);
  
      setImages({
        filePath,
        fileData,
        fileType: file.mimeType,
        fileUri: file.uri,
      });
  
      return filePath;
    } catch (err) {
      console.error("Error picking/uploading file:", err);
      return null;
    }
  }
  const handleSubmit = async () => {
    setLoading(true);
    if (!name || !description) {
      
      showToast({
        type: 'error',
        title: 'Error',
        description: 'Please fill in all fields.',
      });
      setLoading(false);
      return;
    }
    try {
      const { data, error } = await createOrganisation(user?.id!, name, description, orgType, images, roles);
      if (error || !data) {
        showToast({
          type: 'error',
          title: 'Error',
          description: error || 'Failed to create organisation.',
        });
        setLoading(false);
        return;
      }
      showToast({
          type: 'success',
          title: 'Organisation created successfully!',
      });
      setName('');
      setDescription('');
      setImages({filePath:"", fileData:"", fileType:"", fileUri:""});
      console.log('Organisation created:', data);
    }
    catch (error) {
      showToast({
        type: 'error',
        title: 'Error',
        description: 'An unexpected error occurred.',
      });
    }
    setLoading(false);
    push('/spaces');
  };

 
  return (
    <SafeBoundingView style={{ flex: 1, backgroundColor: colors.background }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
      <ScrollView style={{ backgroundColor: colors.backgroundSecondary }}>
        <View style={{ padding: 24, backgroundColor: colors.primary, borderBottomLeftRadius: 24, borderBottomRightRadius: 24, paddingBottom: 48 }}>
          <Text style={{ color: colors.text, fontSize: 36, fontWeight: 'bold', marginTop: 24 }}>Create Organisation</Text>
          <Text style={{ marginTop: 8, fontSize: 20, color: colors.text }}>Set up your space and let people {'\n'}reserve it with ease</Text>
          <Image source={CSpace} style={{ position: 'absolute', right: -8, bottom: 0 }} />
        </View>

        <View style={{ marginBottom: 24, padding: 24, gap: 24 }}>
          <View className='flex flex-row items-center gap-x-4'>
            {
              images.fileUri ?
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 16 }}>
            
              <View style={{ borderRadius: 12, overflow: 'hidden', borderWidth: 1, borderColor: colors.border, width: 'auto' }}>
                  <Image 
                      style={{ height: 80, width: 80 }}
                      source={{uri:images.fileUri}}
                  />
              </View>
              
            
                
          </View>
          :
              <></> 
              }
          <TouchableOpacity
                  onPress={async () => {
                      const url = await pickAndUploadFile("schedura-space");
                      if (url) {
                        console.log("Uploaded file URL:", url);
                      }
                  }}
                  style={{ borderWidth: 2, borderStyle: 'dashed', padding: 16, borderRadius: 12, height: 80, width: 80, justifyContent: 'center', alignItems: 'center', borderColor: colors.border, backgroundColor: colors.card }}
                >
                  <Ionicons name="add" size={24} color={colors.text} />
          </TouchableOpacity>
          </View>    
          <View>
            <Text style={{ marginBottom: 4, fontWeight: '600', fontSize: 20, color: colors.text }}>Organisation Name</Text>
            <TextInput
              placeholder="Convention Center"
              placeholderTextColor={colors.textSecondary}
              value={name}
              onChangeText={setName}
              style={{ padding: 16, borderRadius: 12, borderWidth: 2, borderColor: colors.border, backgroundColor: colors.card, color: colors.text }}
            />
          </View>
          
          <View>
            <Text style={{ marginBottom: 4, fontWeight: '600', fontSize: 20, color: colors.text }}>Description</Text>
            <TextInput
              placeholder="A very spacious and elegant hall with..."
              placeholderTextColor={colors.textSecondary}
              value={description}
              onChangeText={setDescription}
              multiline
              numberOfLines={50}
              style={{ padding: 16, borderRadius: 12, borderWidth: 2, borderColor: colors.border, height: 160, backgroundColor: colors.card, color: colors.text }}
              textAlignVertical='top'
            />
          </View>
          
          <View>
            <Text style={{ marginBottom: 4, fontWeight: '600', fontSize: 20, color: colors.text }}>Organization Type</Text>
            <View style={{ borderColor: colors.border, borderWidth: 2, padding: 20, borderRadius: 12, flexDirection: 'row', flexWrap: 'wrap', gap: 12, backgroundColor: colors.card }}>
              {(['Educational', 'CoWorking'] as const).map((type) => (
                <TouchableOpacity 
                  onPress={() => setOrgType(type)} 
                  key={type} 
                  style={{ paddingHorizontal: 16, paddingVertical: 10, borderRadius: 20, backgroundColor: orgType === type ? colors.accent : colors.backgroundSecondary }}
                >
                  <Text style={{ fontWeight: '500', color: orgType === type ? colors.primary : colors.text }}>{type}</Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>
          
          
          
          <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginBottom: 24 }}>
            <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>Roles</Text>
            <TouchableOpacity
              onPress={() => setRolesModalVisible(true)}
              style={{ backgroundColor: colors.accent, paddingHorizontal: 16, paddingVertical: 8, borderRadius: 12, flexDirection: 'row', alignItems: 'center' }}
            >
              <Ionicons name="add" size={20} color={isDark ? '#000' : '#E9F0E9'} />
              <Text style={{ color: isDark ? '#000' : '#ffffff', fontWeight: '600', marginLeft: 4 }}>Add Role</Text>
            </TouchableOpacity>
          </View>
          <View>
            {roles.map((role, i) => (
              <View key={i} style={{ padding: 16, borderRadius: 12, backgroundColor: colors.card, marginBottom: 12, borderWidth: 1, borderColor: colors.border }}>
                <Text style={{ fontSize: 18, fontWeight: '600', color: colors.text }}>{role.name}</Text>
                <Text style={{ marginTop: 4, color: colors.textSecondary }}>Priviledges: {role.priviledges}</Text>
              </View>
            ))}
          </View>
          <TouchableOpacity
            onPress={handleSubmit}
            disabled={loading}
            style={{ backgroundColor: colors.accent, padding: 16, borderRadius: 16, marginTop: 16, flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 20 }}
          >
            <Text style={{ color: colors.primary, fontSize: 18, textAlign: 'center', fontWeight: '600' }}>
              Create Organisation
            </Text>
            {
              loading &&
              <Animated.View
                style={{
                  transform: [{ rotate: rotateAnimation }],
                  borderTopWidth: 2,
                  borderLeftWidth: 2,
                  borderRightWidth: 2,
                  borderBottomWidth: 2,
                  borderRightColor: colors.primary,
                  borderLeftColor: colors.primary,
                  borderTopColor: colors.primary,
                  borderBottomColor: 'transparent',
                  height: 20,
                  width: 20,
                  borderRadius: 10
                }}
              >
              </Animated.View>
              }
            </TouchableOpacity>
        </View>
      </ScrollView>
      <RolesModal visible={rolesModalVisible} setVisible={setRolesModalVisible} setRoles={setRoles} orgid={"123"} />
    </SafeBoundingView>
  );
}