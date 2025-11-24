import React, { useState, useRef } from 'react';
import { View, Text, TouchableOpacity, Alert } from 'react-native';
import MapView, { Marker } from 'react-native-maps';
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
  const { showToast } = useToast();
  const [selectedLocation, setSelectedLocation] = useState<Location | null>(
    initialLocation || null
  );
  const mapRef = useRef<MapView>(null);

  const handleMapPress = async (event: any) => {
    const { latitude, longitude } = event.nativeEvent.coordinate;
    const location: Location = {
      latitude,
      longitude,
    };

    setSelectedLocation(location);
  };

  const handleConfirmLocation = () => {
    if (selectedLocation) {
      onLocationSelect(selectedLocation);
    } else {
      showToast({
        type: 'error',
        title: 'No Location Selected',
        description: 'Tap on the map to choose a location',
      });
    }
  };

  if (!visible) return null;

  const defaultRegion = {
    latitude: initialLocation?.latitude || 15.2993, // Goa coordinates
    longitude: initialLocation?.longitude || 74.124,
    latitudeDelta: 0.0922,
    longitudeDelta: 0.0421,
  };

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

      <MapView
        ref={mapRef}
        className="flex-1"
        initialRegion={defaultRegion}
        onPress={handleMapPress}
      >
        {selectedLocation && (
          <Marker
            coordinate={{
              latitude: selectedLocation.latitude,
              longitude: selectedLocation.longitude,
            }}
          />
        )}
      </MapView>

      {selectedLocation && (
        <View className="p-4 border-t" style={{ backgroundColor: colors.card, borderTopColor: colors.border }}>
          <Text className="text-base font-semibold mb-1" style={{ color: colors.text }}>
            Selected Location:
          </Text>
          <Text className="text-sm mb-1" style={{ color: colors.textSecondary }}>
            {selectedLocation.latitude.toFixed(6)}, {selectedLocation.longitude.toFixed(6)}
          </Text>
          {selectedLocation.address && (
            <Text className="text-sm" style={{ color: colors.textSecondary }}>
              {selectedLocation.address}
            </Text>
          )}
        </View>
      )}
    </View>
  );
};

export default MapLocationPicker;