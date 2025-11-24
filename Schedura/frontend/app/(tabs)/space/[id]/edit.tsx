import { ScrollView, Text, TouchableOpacity, View, TextInput, Alert, StatusBar, Animated, Easing } from 'react-native';
import SafeBoundingView from '@/components/SafeBoundingView';
import { useEffect, useRef, useState } from 'react';
import { createSpace } from '@/supabase/controllers/spaces.controller';
import * as DocumentPicker from "expo-document-picker";
import * as FileSystem from "expo-file-system/legacy";
import { Image } from 'react-native';
import { useUser } from '@clerk/clerk-expo';
import { decode } from 'base64-arraybuffer'
import { AntDesign, Ionicons } from '@expo/vector-icons';
//@ts-ignore
import CSpace from "@/assets/images/illustrations/cspace.png"
import { useTheme } from '@/contexts/ThemeContext';
import { getOrganisationByUserId } from '@/supabase/controllers/organisation.controller';
import MapLocationPicker from '@/components/MapLocationPicker';
import { supabase } from '@/supabase/supabase';
import { getUserUpiId } from '@/supabase/controllers/user.controller';
import { useToast } from '@/components/Toast';
import { useRouter, useLocalSearchParams } from 'expo-router';
import { getSpaceById } from '@/supabase/controllers/spaces.controller';

interface Location {
  latitude: number;
  longitude: number;
  address?: string;
}


export default function EditSpaceScreen() {
  const { colors, isDark } = useTheme();
  const [name, setName] = useState('');
  const [capacity, setCapacity] = useState('');
  const [location, setLocation] = useState('');
  const [selectedMapLocation, setSelectedMapLocation] = useState<Location | null>(null);
  const [showMapPicker, setShowMapPicker] = useState(false);
  const [description, setDescription] = useState('');
  const [pph, setPph] = useState('');
  const [ownerid, setOwnerId] = useState('');
  const [organizationid, setOrganizationId] = useState('');
  const [category, setCategory] = useState<'Wedding' | 'Corporate' | 'Birthday' | 'Conference' | 'Social'>('Social');
  const [images, setImages] = useState<any>({filePath:"", fileData:"", fileType:"", fileUri:""})
  const { user } = useUser();
  const [loading, setLoading] = useState(false)
  const [amenities, setAmenities] = useState([
    { name: "WiFi", icon: "wifi", id:1, selected:false },
    { name: "Parking", icon: "car", id:2, selected:false },
    { name: "AC", icon: "snow", id:3, selected:false },
    { name: "Projector", icon: "tv", id:4, selected:false },
    { name: "Catering", icon: "restaurant", id:5, selected:false },
    { name: "Sound System", icon: "volume-high", id:6, selected:false },
  ])
  const { showToast } = useToast();
  const { navigate } = useRouter();
  const { id } = useLocalSearchParams();
  const categories: Array<'Wedding' | 'Corporate' | 'Birthday' | 'Conference' | 'Social'> = ['Wedding', 'Corporate', 'Birthday', 'Conference', 'Social'];
  const rotateValue = new Animated.Value(0); 
  const [initialLoading, setInitialLoading] = useState(true);

  const rotateAnimation = rotateValue.interpolate({
      inputRange: [0, 1], 
      outputRange: ['0deg', '360deg'], 
  });
  useEffect(() => {
    if(loading){
      Animated.loop(
        Animated.timing(rotateValue, {
          toValue: 1, 
          duration: 2000, 
          easing: Easing.linear, 
          useNativeDriver: true, 
        })
      ).start()
    }
  }, [loading]);

  // Prefill form with existing space data
  useEffect(() => {
    const loadSpace = async () => {
      try {
        if (!id) return;
        setInitialLoading(true);
        const { data, error } = await getSpaceById(id as string);
        if (error || !data) {
          showToast({
            type: 'error',
            title: 'Error',
            description: 'Failed to load space details',
          });
          return;
        }
        // Populate form fields from space
        setName(data.name || '');
        setCapacity(data.capacity ? String(data.capacity) : '');
        setLocation(data.location || '');
        setDescription(data.description || '');
        setPph(data.pph ? String(data.pph) : '');
        setCategory((data.category as any) || 'Social');
        // Map amenities to selection
        if (Array.isArray(data.amenities)) {
          setAmenities(prev =>
            prev.map(a => ({ ...a, selected: data.amenities.includes(a.name) }))
          );
        }
        // Map coordinates
        if (data.latitude && data.longitude) {
          setSelectedMapLocation({
            latitude: Number(data.latitude),
            longitude: Number(data.longitude),
            address: data.location || undefined,
          });
        }
      } catch (e) {
        console.error('Error loading space:', e);
        showToast({
          type: 'error',
          title: 'Error',
          description: 'Could not load space. Try again later.',
        });
      } finally {
        setInitialLoading(false);
      }
    };
    loadSpace();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

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
    // Require signed-in user
    if (!user) {
      showToast({
        type: 'error',
        title: 'Not signed in',
        description: 'Please sign in before creating a space.',
      });
      return;
    }
 
    // Read UPI id from users table (source of truth)
    try {
      const userUpiId = await getUserUpiId(user?.id)
      if (!userUpiId) {
        showToast({
          type: 'error',
          title: 'UPI ID Required',
          description: 'Please add your UPI ID in your profile before creating a space.',
        });
        return;
      }
      // upi available, continue
    } catch (err) {
      console.error('Error fetching user upi:', err);
      showToast({
        type: 'error',
        title: 'Error',
        description: 'Could not verify UPI. Try again later.',
      });
      return;
    }
 
    setLoading(true);
    if (!name || !capacity || !location || !description || !pph) {
      showToast({
        type: 'error',
        title: 'Error',
        description: 'Please fill all fields',
      });
      setLoading(false);
      return;
    }
    // Update the space row
    try {
      const payload: any = {
        name,
        capacity: parseInt(capacity),
        location,
        latitude: selectedMapLocation?.latitude ?? null,
        longitude: selectedMapLocation?.longitude ?? null,
        description,
        pph,
        category,
      };
      // Optional: preserve organization id if present on the record already
      // You could fetch from state/space if needed

      const { data: updated, error: updateErr } = await supabase
        .from('spaces')
        .update(payload)
        .eq('id', id as string)
        .select()
        .single();

      if (updateErr) {
        showToast({
          type: 'error',
          title: 'Error',
          description: updateErr.message,
        });
      } else {
        showToast({
          type: 'success',
          title: 'Updated',
          description: 'Space updated successfully',
        });
        navigate("/spaces");
      }
    } catch (e: any) {
      showToast({
        type: 'error',
        title: 'Error',
        description: e?.message || 'Failed to update space',
      });
    }
    setLoading(false);
  };

  const handleDelete = async () => {
    // Require signed-in user
    if (!user) {
      showToast({
        type: 'error',
        title: 'Not signed in',
        description: 'Please sign in before deleting a space.',
      });
      return;
    }

    Alert.alert(
      "Confirm Deletion",
      "Are you sure you want to delete this space? This action cannot be undone.",
      [
        {
          text: "Cancel",
          style: "cancel"
        },
        {
          text: "Delete",
          style: "destructive",
          onPress: async () => {
            setLoading(true);
            try {
              const { error } = await supabase
                .from('spaces')
                .delete()
                .eq('id', id as string);

              if (error) {
                showToast({
                  type: 'error',
                  title: 'Error',
                  description: error.message,
                });
              } else {
                showToast({
                  type: 'success',
                  title: 'Deleted',
                  description: 'Space deleted successfully', 
                })
              }
            }
            catch (e: any) {
              showToast({
                type: 'error',
                title: 'Error',
                description: e?.message || 'Failed to delete space',
              });
            }
          }
        }
      ]
    );
  };

  // yet to make the submission functional
  const handleAmenities = (id:number) =>{
    let amenitiesCopy = [...amenities];
    amenitiesCopy[id].selected = !amenitiesCopy[id].selected;
    setAmenities(amenitiesCopy) 
  }


  if (initialLoading) {
    return (
      <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
        <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
        <View className="flex-1 items-center justify-center">
          <Text style={{ color: colors.text }}>Loading space...</Text>
        </View>
      </SafeBoundingView>
    );
  }
  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
      <ScrollView style={{ backgroundColor: colors.backgroundSecondary }}>
        <View className="p-6 pb-12 rounded-b-2xl" style={{ backgroundColor: colors.primary }}>
          <Text className="text-4xl font-bold mt-6" style={{ color: colors.accent }}>Edit Space</Text>
          <Text className="mt-2 text-lg" style={{ color: colors.text }}>Update your space details and save changes</Text>
          <Image source={CSpace} className="absolute right-2 bottom-0" />
        </View>

        <Text className="text-2xl font-bold mx-5 mt-6" style={{ color: colors.text }}>Basic Details</Text>
        <View className="mb-6 p-6 gap-y-6">
          <View>
            <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>Name</Text>
            <TextInput
              placeholder="Convention Center"
              placeholderTextColor={colors.textSecondary}
              value={name}
              onChangeText={setName}
              className="p-4 rounded-xl border-2"
              style={{ borderColor: colors.border, backgroundColor: colors.card, color: colors.text }}
            />
          </View>
          <View>
            <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>Capacity</Text>
            <TextInput
              placeholder="200"
              placeholderTextColor={colors.textSecondary}
              keyboardType="numeric"
              value={capacity}
              onChangeText={setCapacity}
              className="p-4 rounded-xl border-2"
              style={{ borderColor: colors.border, backgroundColor: colors.card, color: colors.text }}
            />
          </View>
          <View>
            <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>Location</Text>
            <View className="flex-row gap-x-3">
              <TextInput
                placeholder="Panaji, Goa"
                placeholderTextColor={colors.textSecondary}
                value={location}
                onChangeText={setLocation}
                className="flex-1 p-4 rounded-xl border-2"
                style={{ borderColor: colors.border, backgroundColor: colors.card, color: colors.text }}
              />
              <TouchableOpacity
                onPress={() => setShowMapPicker(true)}
                className="p-4 rounded-xl border-2 items-center justify-center"
                style={{ borderColor: colors.border, backgroundColor: colors.card }}
              >
                <Ionicons name="map" size={24} color={colors.accent} />
              </TouchableOpacity>
            </View>
            {selectedMapLocation && (
              <View className="mt-2 p-3 rounded-md" style={{ backgroundColor: colors.backgroundSecondary }}>
                <Text className="text-xs font-medium" style={{ color: colors.text }}>
                  Selected coordinates: {selectedMapLocation.latitude.toFixed(6)}, {selectedMapLocation.longitude.toFixed(6)}
                </Text>
                {selectedMapLocation.address && (
                  <Text className="text-xs mt-0.5" style={{ color: colors.textSecondary }}>
                    {selectedMapLocation.address}
                  </Text>
                )}
              </View>
            )}
          </View>
          <View>
            <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>Description</Text>
            <TextInput
              placeholder="A very spacious and elegant hall with..."
              placeholderTextColor={colors.textSecondary}
              value={description}
              onChangeText={setDescription}
              multiline
              numberOfLines={50}
              className="p-4 rounded-xl border-2 h-40"
              style={{ borderColor: colors.border, backgroundColor: colors.card, color: colors.text }}
              textAlignVertical='top'
            />
          </View>
          <View>
            <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>Price per Day {"($)"}</Text>
            <TextInput
              placeholder="20000"
              placeholderTextColor={colors.textSecondary}
              value={pph}
              onChangeText={setPph}
              className="p-4 rounded-xl border-2"
              style={{ borderColor: colors.border, backgroundColor: colors.card, color: colors.text }}
            />
          </View>
          <View>
            <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>Category</Text>
            <View className="border-2 p-5 rounded-xl flex-row flex-wrap gap-3" style={{ borderColor: colors.border, backgroundColor: colors.card }}>
              {
                categories.map((cat)=>(
                  <TouchableOpacity 
                    onPress={()=>setCategory(cat)} 
                    key={cat} 
                    className="px-4 py-2 rounded-full"
                    style={{ backgroundColor: category === cat ? colors.accent : colors.backgroundSecondary }}
                  >
                    <Text className="font-medium" style={{ color: category === cat ? colors.backgroundTertiary : colors.textSecondary }}>{cat}</Text>
                  </TouchableOpacity>
                ))
              }
            </View>
          </View>
          <View>
            <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>Facilities and Amenities</Text>
            <View className="border-2 p-5 rounded-xl flex-row flex-wrap" style={{ borderColor: colors.border, backgroundColor: colors.card }}>
              {
                amenities.map((facility, i)=>(
                  <TouchableOpacity onPress={()=>handleAmenities(i)} key={facility.id} className="flex-row items-center gap-x-2 mb-3 mr-4">
                    <View className="p-2 rounded-lg" style={{ backgroundColor: facility.selected ? (isDark ? '#065f46' : '#dcfce7') : colors.backgroundSecondary }}>
                      <Ionicons name={facility.icon as any} size={15} color={facility.selected ? '#10B981' : colors.textSecondary}/>
                    </View>
                    <Text className="font-medium" style={{ color: facility.selected ? colors.text : colors.textSecondary }}>{facility.name}</Text>
                  </TouchableOpacity>
                ))
              }
            </View>
          </View>
          
          {/* <View className="flex-row items-center gap-x-4">
            {
              images.fileUri ?
              <View className="rounded-lg overflow-hidden border" style={{ borderColor: colors.border }}>
                  <Image 
                      className="h-20 w-20"
                      source={{uri:images.fileUri}}
                  />
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
                  className="border-2 border-dashed p-4 rounded-xl h-20 w-20 items-center justify-center"
                  style={{ borderColor: colors.border, backgroundColor: colors.card }}
                >
                  <Ionicons name="add" size={24} color={colors.text} />
            </TouchableOpacity>      
          </View> */}
          <TouchableOpacity
            onPress={handleDelete}
            disabled={loading}
            className="px-4 py-4 rounded-2xl mt-4 flex-row items-center justify-center gap-x-5 bg-red-500"
          >
            <Text className="text-lg font-semibold text-white">
              Delete Space
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            onPress={handleSubmit}
            disabled={loading}
            className="px-4 py-4 rounded-2xl  flex-row items-center justify-center gap-x-5"
            style={{ backgroundColor: colors.accent }}
          >
            <Text className="text-lg font-semibold" style={{ color: colors.primary }}>
              Save Changes
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
                  borderRightColor: 'white',
                  borderLeftColor: 'white',
                  borderTopColor: 'white',
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
      
      <MapLocationPicker
        visible={showMapPicker}
        onLocationSelect={(location) => {
          setSelectedMapLocation(location);
          if (location.address) {
            setLocation(location.address);
          }
          setShowMapPicker(false);
        }}
        onCancel={() => setShowMapPicker(false)}
        initialLocation={selectedMapLocation || undefined}
      />
    </SafeBoundingView>
  );
}
