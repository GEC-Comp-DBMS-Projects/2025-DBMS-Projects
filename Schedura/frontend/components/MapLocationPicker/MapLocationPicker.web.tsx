import React, { useState } from 'react';
import { View, Text, TouchableOpacity, Alert, TextInput } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useTheme } from '@/contexts/ThemeContext';
import { useToast } from '../Toast';

interface Location {
  latitude: number;
  longitude: number;
  address?: string;
}

interface MapLocationPickerProps {
  visible: boolean;
  onLocationSelect: (location: Location) => void;
  onCancel: () => void;
  initialLocation?: Location;
}

const MapLocationPicker: React.FC<MapLocationPickerProps> = ({
  visible,
  onLocationSelect,
  onCancel,
  initialLocation
}) => {
  const { colors, isDark } = useTheme();
  const [latitude, setLatitude] = useState(initialLocation?.latitude?.toString() || '15.2993');
  const [longitude, setLongitude] = useState(initialLocation?.longitude?.toString() || '74.124');
  const [address, setAddress] = useState(initialLocation?.address || '');
  const { showToast } = useToast();
  const handleConfirmLocation = () => {
    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);
    
    if (isNaN(lat) || isNaN(lng)) {
      showToast({
        type: 'error',
        title: 'Invalid coordinates',
        description: 'Please enter valid latitude and longitude values',
      });
      return;
    }
    
    if (lat < -90 || lat > 90) {
      showToast({
        type: 'error',
        title: 'Invalid latitude',
        description: 'Latitude must be between -90 and 90',
      });
      return;
    }
    
    if (lng < -180 || lng > 180) {
      showToast({
        type: 'error',
        title: 'Invalid longitude',
        description: 'Longitude must be between -180 and 180',
      });
      return;
    }

    const location: Location = {
      latitude: lat,
      longitude: lng,
      address: address || undefined,
    };

    onLocationSelect(location);
  };

  if (!visible) return null;

  return (
    <View className="absolute top-0 left-0 right-0 bottom-0 z-50" style={{ backgroundColor: colors.background }}>
      <View className="flex-row items-center justify-between px-4 py-3 border-b pt-6" style={{ backgroundColor: colors.card, borderBottomColor: colors.border }}>
        <TouchableOpacity onPress={onCancel} className="p-2">
          <Ionicons name="close" size={24} color={colors.text} />
        </TouchableOpacity>
        <Text className="text-lg font-semibold" style={{ color: colors.text }}>Select Location</Text>
        <TouchableOpacity onPress={handleConfirmLocation} className="p-2">
          <Text className="text-base font-semibold" style={{ color: colors.accent }}>Confirm</Text>
        </TouchableOpacity>
      </View>

      <View className="flex-1 p-4">
        <View className="flex-1 justify-center items-center border rounded-xl mb-4 min-h-[200px]" style={{ backgroundColor: colors.backgroundSecondary, borderColor: colors.border }}>
          <Ionicons name="map" size={64} color={colors.textSecondary} />
          <Text className="text-lg font-semibold mt-4" style={{ color: colors.textSecondary }}>
            Web Map Preview
          </Text>
          <Text className="text-sm mt-2 text-center" style={{ color: colors.textSecondary }}>
            Enter coordinates below to set location
          </Text>
        </View>

        <View className="gap-4">
          <View className="gap-2">
            <Text className="text-base font-semibold" style={{ color: colors.text }}>Latitude</Text>
            <TextInput
              className="border rounded-lg p-3 text-base"
              style={{ backgroundColor: colors.card, borderColor: colors.border, color: colors.text }}
              value={latitude}
              onChangeText={setLatitude}
              placeholder="15.2993"
              placeholderTextColor={colors.textSecondary}
              keyboardType="numeric"
            />
          </View>

          <View className="gap-2">
            <Text className="text-base font-semibold" style={{ color: colors.text }}>Longitude</Text>
            <TextInput
              className="border rounded-lg p-3 text-base"
              style={{ backgroundColor: colors.card, borderColor: colors.border, color: colors.text }}
              value={longitude}
              onChangeText={setLongitude}
              placeholder="74.124"
              placeholderTextColor={colors.textSecondary}
              keyboardType="numeric"
            />
          </View>

          <View className="gap-2">
            <Text className="text-base font-semibold" style={{ color: colors.text }}>Address (Optional)</Text>
            <TextInput
              className="border rounded-lg p-3 text-base"
              style={{ backgroundColor: colors.card, borderColor: colors.border, color: colors.text }}
              value={address}
              onChangeText={setAddress}
              placeholder="Enter address or description"
              placeholderTextColor={colors.textSecondary}
              multiline
            />
          </View>
        </View>
      </View>
    </View>
  );
};

export default MapLocationPicker;