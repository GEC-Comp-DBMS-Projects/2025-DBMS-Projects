import { ScrollView, Text, TouchableOpacity, View, TextInput, Alert, StatusBar, Animated, Easing, Modal } from 'react-native';
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
import { useRouter } from 'expo-router';

interface Location {
  latitude: number;
  longitude: number;
  address?: string;
}


export default function AddSpacesScreen() {
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
  const [images, setImages] = useState<any[]>([]);
  const { user } = useUser();
  const [loading, setLoading] = useState(false)
  const [userOrganisations, setUserOrganisations] = useState<any[]>([]);
  const [selectedOrgId, setSelectedOrgId] = useState<number | null>(null);
  const [showOrgPicker, setShowOrgPicker] = useState(false);
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
  const categories: Array<'Wedding' | 'Corporate' | 'Birthday' | 'Conference' | 'Social'> = ['Wedding', 'Corporate', 'Birthday', 'Conference', 'Social'];
  const rotateValue = new Animated.Value(0); 

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

  // Fetch user's organizations where they are owner
  useEffect(() => {
    const fetchUserOrgs = async () => {
      if (!user?.id) return;
      try {
        const { data: orgs } = await supabase
          .from('organisations')
          .select('id, name, type')
          .eq('ownerid', user.id);
        
        if (orgs && orgs.length > 0) {
          setUserOrganisations(orgs);
        }
      } catch (err) {
        console.error('Error fetching organizations:', err);
      }
    };
    fetchUserOrgs();
  }, [user?.id]);

  async function pickAndUploadFiles() {
    try {
      const result = await DocumentPicker.getDocumentAsync({
        type: ["image/*"],
        copyToCacheDirectory: true,
        multiple: true
      });
  
      if (result.canceled) {
        console.log("User cancelled file picker");
        return null;
      }
      
      const newImages = await Promise.all(
        result.assets.map(async (file) => {
          const fileExt = file.name.split(".").pop();
          const fileName = `space-${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`;
          const filePath = `${fileName}`;
          const base64 = await FileSystem.readAsStringAsync(file.uri, {
            encoding: FileSystem.EncodingType.Base64,
          });
          const fileData = decode(base64);
          
          return {
            filePath,
            fileData,
            fileType: file.mimeType,
            fileUri: file.uri,
          };
        })
      );
      
      setImages((prev) => [...prev, ...newImages]);
      showToast({
        type: 'success',
        title: 'Images Added',
        description: `${newImages.length} image(s) added successfully`,
      });
    } catch (err) {
      console.error("Error picking/uploading file:", err);
      showToast({
        type: 'error',
        title: 'Error',
        description: 'Failed to pick images',
      });
      return null;
    }
  }
  
  const removeImage = (index: number) => {
    setImages((prev) => prev.filter((_, i) => i !== index));
    showToast({
      type: 'info',
      title: 'Image Removed',
      description: 'Image removed from upload list',
    });
  };

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
    if (!name || !capacity || !location || !description || !pph || images.length === 0) {
      showToast({
        type: 'error',
        title: 'Error',
        description: 'Please fill all fields and upload at least one image',
      });
      setLoading(false);
      return;
    }
    const { data, error } = await createSpace({
      name,
      capacity: parseInt(capacity),
      location,
      latitude: selectedMapLocation?.latitude,
      longitude: selectedMapLocation?.longitude,
      description,
      pph,
      ownerid: user?.id!,
      id: undefined,
      category,
      amenities: amenities.filter(facility=>facility.selected).map(facility=>facility.name),
      organizationid: selectedOrgId || undefined,
    }, images);
    console.log(error)
    if (error) {
      showToast({
        type: 'error',
        title: 'Error',
        description: error.message,
      });
    } else {
      showToast({
        type: 'success',
        title: 'Success',
        description: 'Space added successfully',
      });
      setName('');
      setCapacity('');
      setLocation('');
      setSelectedMapLocation(null);
      setDescription('');
      setPph('');
      setOwnerId('');
      setOrganizationId('');
      setImages([]);
      navigate("/spaces");
    }
    setLoading(false);
  };

  // yet to make the submission functional
  const handleAmenities = (id:number) =>{
    let amenitiesCopy = [...amenities];
    amenitiesCopy[id].selected = !amenitiesCopy[id].selected;
    setAmenities(amenitiesCopy) 
  }
  return (
    <SafeBoundingView className="flex-1" style={{ backgroundColor: colors.background }}>
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
      <ScrollView style={{ backgroundColor: colors.backgroundSecondary }}>
        <View className="p-6 pb-12 rounded-b-2xl" style={{ backgroundColor: colors.primary }}>
          <Text className="text-4xl font-bold mt-6" style={{ color: colors.accent }}>Create new Space</Text>
          <Text className="mt-2 text-lg" style={{ color: colors.text }}>Set up your space and let people {'\n'}reserve it with ease</Text>
          <Image source={CSpace} className="absolute right-2 bottom-0" />
        </View>

        <Text className="text-2xl font-bold mx-5 mt-6" style={{ color: colors.text }}>Basic Details</Text>
        <View className="mb-6 p-6 gap-y-6">
          {/* Organization Selection - Only show if user owns organizations */}
          {userOrganisations.length > 0 && (
            <View>
              <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>
                Space Owner
              </Text>
              <TouchableOpacity
                onPress={() => setShowOrgPicker(true)}
                className="p-4 rounded-xl border-2 flex-row items-center justify-between"
                style={{ borderColor: colors.border, backgroundColor: colors.card }}
              >
                <Text style={{ color: selectedOrgId ? colors.text : colors.textSecondary }}>
                  {selectedOrgId 
                    ? userOrganisations.find(o => o.id === selectedOrgId)?.name || 'Select Organization'
                    : 'Personal Space (Not under organization)'}
                </Text>
                <Ionicons name="chevron-down" size={20} color={colors.textSecondary} />
              </TouchableOpacity>
              <Text className="mt-1 text-xs" style={{ color: colors.textSecondary }}>
                Choose whether this space belongs to you personally or to an organization you own
              </Text>
            </View>
          )}
          
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
            <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>Price per Day {"(Rs)"}</Text>
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
          <View>
            <Text className="mb-1.5 font-semibold text-lg" style={{ color: colors.text }}>
              Images ({images.length})
            </Text>
            <ScrollView horizontal showsHorizontalScrollIndicator={false} className="flex-row overflow-visible">
              {images.map((img, index) => (
                <View key={index} className="relative mr-2 overflow-visible">
                  <View className="rounded-lg overflow-hidden border" style={{ borderColor: colors.border }}>
                    <Image 
                      className="h-24 w-24"
                      source={{uri: img.fileUri}}
                    />
                  </View>
                  <TouchableOpacity
                    onPress={() => removeImage(index)}
                    className="absolute -top-2 -right-2 rounded-full p-1 z-10"
                    style={{ backgroundColor: colors.error }}
                  >
                    <Ionicons name="close" size={16} color="white" />
                  </TouchableOpacity>
                </View>
              ))}
              <TouchableOpacity
                onPress={pickAndUploadFiles}
                className="border-2 border-dashed rounded-xl h-24 w-24 items-center justify-center"
                style={{ borderColor: colors.border, backgroundColor: colors.card }}
              >
                <Ionicons name="add" size={28} color={colors.text} />
                <Text className="text-xs mt-1" style={{ color: colors.textSecondary }}>Add Images</Text>
              </TouchableOpacity>
            </ScrollView>
          </View>

          <TouchableOpacity
            onPress={handleSubmit}
            disabled={loading}
            className="px-4 py-4 rounded-2xl mt-4 flex-row items-center justify-center gap-x-5"
            style={{ backgroundColor: colors.accent }}
          >
            <Text className="text-lg font-semibold" style={{ color: colors.primary }}>
              Add Space
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
      
      {/* Organization Picker Modal */}
      <Modal
        visible={showOrgPicker}
        transparent
        animationType="slide"
        onRequestClose={() => setShowOrgPicker(false)}
      >
        <TouchableOpacity
          activeOpacity={1}
          onPress={() => setShowOrgPicker(false)}
          className="flex-1 justify-end"
          style={{ backgroundColor: 'rgba(0,0,0,0.5)' }}
        >
          <TouchableOpacity
            activeOpacity={1}
            onPress={(e) => e.stopPropagation()}
            className="rounded-t-3xl px-6 py-6"
            style={{ backgroundColor: colors.card, maxHeight: '60%' }}
          >
            <View className="flex-row items-center justify-between mb-4">
              <Text className="text-xl font-bold" style={{ color: colors.text }}>
                Select Owner
              </Text>
              <TouchableOpacity onPress={() => setShowOrgPicker(false)}>
                <Ionicons name="close" size={24} color={colors.textSecondary} />
              </TouchableOpacity>
            </View>

            <ScrollView>
              {/* Personal Option */}
              <TouchableOpacity
                onPress={() => {
                  setSelectedOrgId(null);
                  setShowOrgPicker(false);
                }}
                className="py-3 px-4 rounded-lg mb-2 border"
                style={{
                  borderColor: colors.border,
                  backgroundColor: selectedOrgId === null ? colors.accent : colors.backgroundSecondary,
                }}
              >
                <View className="flex-row items-center">
                  <Ionicons 
                    name="person" 
                    size={20} 
                    color={selectedOrgId === null ? colors.primary : colors.textSecondary} 
                  />
                  <Text 
                    className="font-semibold ml-3" 
                    style={{ color: selectedOrgId === null ? colors.primary : colors.text }}
                  >
                    Personal Space
                  </Text>
                </View>
                <Text 
                  className="text-xs ml-8 mt-1" 
                  style={{ color: selectedOrgId === null ? colors.primary : colors.textSecondary }}
                >
                  This space will be owned by you only
                </Text>
              </TouchableOpacity>

              {/* Organization Options */}
              {userOrganisations.map((org) => (
                <TouchableOpacity
                  key={org.id}
                  onPress={() => {
                    setSelectedOrgId(org.id);
                    setShowOrgPicker(false);
                  }}
                  className="py-3 px-4 rounded-lg mb-2 border"
                  style={{
                    borderColor: colors.border,
                    backgroundColor: selectedOrgId === org.id ? colors.accent : colors.backgroundSecondary,
                  }}
                >
                  <View className="flex-row items-center">
                    <Ionicons 
                      name="business" 
                      size={20} 
                      color={selectedOrgId === org.id ? colors.primary : colors.textSecondary} 
                    />
                    <Text 
                      className="font-semibold ml-3" 
                      style={{ color: selectedOrgId === org.id ? colors.primary : colors.text }}
                    >
                      {org.name}
                    </Text>
                  </View>
                  <Text 
                    className="text-xs ml-8 mt-1" 
                    style={{ color: selectedOrgId === org.id ? colors.primary : colors.textSecondary }}
                  >
                    {org.type} organization
                  </Text>
                </TouchableOpacity>
              ))}
            </ScrollView>
          </TouchableOpacity>
        </TouchableOpacity>
      </Modal>
      
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
