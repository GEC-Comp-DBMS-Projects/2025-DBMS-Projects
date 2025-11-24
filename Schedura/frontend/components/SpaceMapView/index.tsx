import React from 'react';
import { View, Text, TouchableOpacity, Modal, StyleSheet, Linking, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { WebView } from 'react-native-webview';
import { useTheme } from '@/contexts/ThemeContext';

interface SpaceMapViewProps {
  visible: boolean;
  onClose: () => void;
  latitude: number;
  longitude: number;
  spaceName: string;
  spaceAddress?: string;
}

const SpaceMapView: React.FC<SpaceMapViewProps> = ({
  visible,
  onClose,
  latitude,
  longitude,
  spaceName,
  spaceAddress
}) => {
  const { colors, isDark } = useTheme();

  const openInMaps = () => {
    const url = Platform.select({
      ios: `maps:0,0?q=${latitude},${longitude}`,
      android: `geo:0,0?q=${latitude},${longitude}`,
      default: `https://www.google.com/maps?q=${latitude},${longitude}`,
    });
    Linking.openURL(url).catch(err => 
      console.error('Error opening maps:', err)
    );
  };

  const generateMapHTML = () => {
    const backgroundColor = isDark ? '#1a1a1a' : '#ffffff';
    const textColor = isDark ? '#ffffff' : '#333333';
    const secondaryTextColor = isDark ? '#cccccc' : '#666666';

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
            border-radius: 8px;
            box-shadow: 0 3px 14px rgba(0,0,0,0.4);
          }
          .leaflet-popup-content {
            margin: 12px;
            text-align: center;
          }
          .leaflet-popup-tip {
            background-color: ${backgroundColor};
          }
          .popup-title {
            margin: 0 0 8px 0;
            font-size: 16px;
            font-weight: 600;
            color: ${textColor};
          }
          .popup-address {
            margin: 0 0 8px 0;
            font-size: 14px;
            color: ${secondaryTextColor};
          }
          .popup-coords {
            margin: 0;
            font-size: 12px;
            font-family: monospace;
            color: ${secondaryTextColor};
          }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          var map = L.map('map').setView([${latitude}, ${longitude}], 15);

          L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors',
            maxZoom: 19
          }).addTo(map);

          var marker = L.marker([${latitude}, ${longitude}]).addTo(map);
          
          var popupContent = 
            '<div>' +
              '<h3 class="popup-title">${spaceName.replace(/'/g, "\\'")}</h3>' +
              ${spaceAddress ? `'<p class="popup-address">${spaceAddress.replace(/'/g, "\\'")}</p>' +` : ''} 
              '<p class="popup-coords">${latitude.toFixed(6)}, ${longitude.toFixed(6)}</p>' +
            '</div>';
          
          marker.bindPopup(popupContent).openPopup();
        </script>
      </body>
      </html>
    `;
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      onRequestClose={onClose}
    >
      <View style={[styles.container, { backgroundColor: colors.background }]}>
        {/* Header */}
        <View style={[styles.header, { backgroundColor: colors.card, borderBottomColor: colors.border }]}>
          <TouchableOpacity onPress={onClose} style={styles.headerButton}>
            <Ionicons name="close" size={24} color={colors.text} />
          </TouchableOpacity>
          <Text style={[styles.headerTitle, { color: colors.text }]}>Space Location</Text>
          <TouchableOpacity onPress={openInMaps} style={styles.headerButton}>
            <Ionicons name="open-outline" size={20} color={colors.accent} />
          </TouchableOpacity>
        </View>

        {/* Map */}
        <View style={styles.mapContainer}>
          <WebView
            style={styles.webview}
            originWhitelist={['*']}
            source={{ html: generateMapHTML() }}
            javaScriptEnabled={true}
            domStorageEnabled={true}
          />
        </View>

        {/* Info Card */}
        <View style={[styles.infoCard, { backgroundColor: colors.card }]}>
          <View style={styles.infoRow}>
            <Ionicons name="location" size={20} color={colors.accent} />
            <View style={styles.infoTextContainer}>
              <Text style={[styles.spaceName, { color: colors.text }]}>
                {spaceName}
              </Text>
              {spaceAddress && (
                <Text style={[styles.address, { color: colors.textSecondary }]}>
                  {spaceAddress}
                </Text>
              )}
              <Text style={[styles.coordinates, { color: colors.textSecondary }]}>
                {latitude.toFixed(6)}, {longitude.toFixed(6)}
              </Text>
            </View>
          </View>
        </View>

        {/* Open in Maps Button */}
        <View style={[styles.footer, { backgroundColor: colors.card, borderTopColor: colors.border }]}>
          <TouchableOpacity 
            style={[styles.mapButton, { backgroundColor: colors.accent }]}
            onPress={openInMaps}
          >
            <Ionicons name="map" size={20} color="white" />
            <Text style={styles.mapButtonText}>Open in Maps</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingTop: 48,
    paddingBottom: 12,
    borderBottomWidth: 1,
  },
  headerButton: {
    padding: 8,
    minWidth: 40,
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
  },
  mapContainer: {
    flex: 1,
  },
  webview: {
    flex: 1,
  },
  infoCard: {
    padding: 16,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 12,
  },
  infoTextContainer: {
    flex: 1,
    gap: 4,
  },
  spaceName: {
    fontSize: 18,
    fontWeight: '600',
  },
  address: {
    fontSize: 14,
    lineHeight: 20,
  },
  coordinates: {
    fontSize: 12,
    fontFamily: Platform.select({ ios: 'Courier', android: 'monospace' }),
    marginTop: 4,
  },
  footer: {
    padding: 16,
    borderTopWidth: 1,
  },
  mapButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 12,
    borderRadius: 8,
    gap: 8,
  },
  mapButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default SpaceMapView;