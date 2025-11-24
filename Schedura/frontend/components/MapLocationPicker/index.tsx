import React, { useState } from 'react';
import { View, Text, TouchableOpacity, Alert, Modal } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { WebView } from 'react-native-webview';
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
  const [selectedLocation, setSelectedLocation] = useState<Location>(
    initialLocation || { latitude: 15.2993, longitude: 74.124 }
  );
  const { showToast } = useToast();
  const generateMapHTML = () => {
    const backgroundColor = isDark ? '#1a1a1a' : '#ffffff';
    const textColor = isDark ? '#ffffff' : '#333333';

    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
        <style>
          body, html {
            margin: 0;
            padding: 0;
            height: 100%;
            width: 100%;
            background-color: ${backgroundColor};
          }
          #map {
            width: 100%;
            height: 100%;
          }
          .leaflet-container {
            background: ${backgroundColor};
          }
          .leaflet-popup-content-wrapper {
            background-color: ${backgroundColor};
            color: ${textColor};
          }
          .leaflet-popup-tip {
            background-color: ${backgroundColor};
          }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          var map = L.map('map').setView([${selectedLocation.latitude}, ${selectedLocation.longitude}], 13);

          L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors',
            maxZoom: 19
          }).addTo(map);

          var marker = L.marker([${selectedLocation.latitude}, ${selectedLocation.longitude}], {
            draggable: true
          }).addTo(map);

          // Handle marker drag
          marker.on('dragend', function(e) {
            var latlng = marker.getLatLng();
            window.ReactNativeWebView.postMessage(JSON.stringify({
              type: 'locationSelected',
              latitude: latlng.lat,
              longitude: latlng.lng
            }));
          });

          // Handle map clicks
          map.on('click', function(e) {
            marker.setLatLng(e.latlng);
            window.ReactNativeWebView.postMessage(JSON.stringify({
              type: 'locationSelected',
              latitude: e.latlng.lat,
              longitude: e.latlng.lng
            }));
          });

          // Initial location
          window.ReactNativeWebView.postMessage(JSON.stringify({
            type: 'locationSelected',
            latitude: ${selectedLocation.latitude},
            longitude: ${selectedLocation.longitude}
          }));
        </script>
      </body>
      </html>
    `;
  };

  const handleWebViewMessage = (event: any) => {
    try {
      const data = JSON.parse(event.nativeEvent.data);
      if (data.type === 'locationSelected') {
        setSelectedLocation({
          latitude: data.latitude,
          longitude: data.longitude,
        });
      }
    } catch (error) {
      console.error('Error parsing WebView message:', error);
    }
  };

  const handleConfirmLocation = () => {
    if (selectedLocation) {
      onLocationSelect(selectedLocation);
    } else {
      showToast({
        type: 'error',
        title: 'No Location Selected',
        description: 'Click on the map to choose a location',
      });
    }
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      onRequestClose={onCancel}
    >
      <View className="flex-1" style={{ backgroundColor: colors.background }}>
        {/* Header */}
        <View
          className="flex-row items-center justify-between px-4 pt-12 pb-3 border-b"
          style={{ backgroundColor: colors.card, borderBottomColor: colors.border }}
        >
          <TouchableOpacity onPress={onCancel} className="p-2 min-w-[60px]">
            <Ionicons name="close" size={24} color={colors.text} />
          </TouchableOpacity>

          <Text className="text-lg font-semibold" style={{ color: colors.text }}>
            Select Location
          </Text>

          <TouchableOpacity onPress={handleConfirmLocation} className="p-2 min-w-[60px] items-end">
            <Text className="text-base font-semibold" style={{ color: colors.accent }}>
              Confirm
            </Text>
          </TouchableOpacity>
        </View>

        {/* Map */}
        <View className="flex-1">
          <WebView
            className="flex-1"
            originWhitelist={['*']}
            source={{ html: generateMapHTML() }}
            javaScriptEnabled={true}
            domStorageEnabled={true}
            onMessage={handleWebViewMessage}
          />
        </View>

        {/* Location Info */}
        {selectedLocation && (
          <View
            className="p-4 border-t"
            style={{ backgroundColor: colors.card, borderTopColor: colors.border }}
          >
            <View className="flex-row items-center gap-x-2">
              <Ionicons name="location" size={20} color={colors.accent} />
              <Text className="text-base font-semibold" style={{ color: colors.text }}>
                Selected Location
              </Text>
            </View>

            <Text className="text-sm font-mono" style={{ color: colors.textSecondary }}>
              {selectedLocation.latitude.toFixed(6)}, {selectedLocation.longitude.toFixed(6)}
            </Text>

            <Text className="text-xs mt-1" style={{ color: colors.textSecondary }}>
              💡 Tap anywhere on the map or drag the marker to change location
            </Text>
          </View>
        )}
      </View>
    </Modal>
  );
};

export default MapLocationPicker;
