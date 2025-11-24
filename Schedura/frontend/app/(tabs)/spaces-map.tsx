import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, StatusBar, Alert, Dimensions, ActivityIndicator } from 'react-native';
import { useRouter } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { WebView } from 'react-native-webview';
import SafeBoundingView from '@/components/SafeBoundingView';
import { useTheme } from '@/contexts/ThemeContext';
import { getSpaces } from '@/supabase/controllers/spaces.controller';
import { useToast } from '@/components/Toast';
import { supabase } from '@/supabase/supabase';

const { width, height } = Dimensions.get('window');

interface Space {
  id: string;
  name: string;
  location: string;
  latitude: string | number;
  longitude: string | number;
  capacity: number;
  pph: number;
  description?: string;
}

export default function SpacesMapScreen() {
  const { colors, isDark } = useTheme();
  const { back } = useRouter();
  const [spaces, setSpaces] = useState<Space[]>([]);
  const [loading, setLoading] = useState(true);
  const { showToast } = useToast();

  useEffect(() => {
    fetchSpaces();
  }, []);

  const fetchSpaces = async () => {
    try {
      setLoading(true);
      const { data, error } = await getSpaces();
      if (error) {
        console.error("Error fetching spaces:", error);
        showToast({
          type: 'error',
          title: 'Error',
          description: 'Failed to load spaces',
        });
      } else {
        const spacesWithCoords = (data || []).filter((space: any) => 
          space.latitude && space.longitude && 
          !isNaN(parseFloat(space.latitude.toString())) && 
          !isNaN(parseFloat(space.longitude.toString()))
        );
        
        // Fetch reviews for each space to get ratings
        const spacesWithRatings = await Promise.all(
          spacesWithCoords.map(async (space: any) => {
            const { data: reviews } = await supabase
              .from('reviews')
              .select('stars')
              .eq('spaceid', space.id);
            
            const reviewCount = reviews?.length || 0;
            const avgRating = reviewCount > 0
              ? (reviews.reduce((sum, r) => sum + r.stars, 0) / reviewCount).toFixed(1)
              : '0.0';
            
            return { ...space, avgRating, reviewCount };
          })
        );
        
        setSpaces(spacesWithRatings);
      }
    } catch (error) {
      console.error("Error in fetchSpaces:", error);
      showToast({
          type: 'error',
          title: 'Error',
          description: 'Failed to load spaces',
      });
    } finally {
      setLoading(false);
    }
  };

  const generateMapHTML = () => {
    if (spaces.length === 0) {
      return '<html><body><h3 style="text-align:center;margin-top:50px;">No spaces to display</h3></body></html>';
    }

    // Calculate center point
    const centerLat = spaces.reduce((sum, space) => sum + parseFloat(space.latitude.toString()), 0) / spaces.length;
    const centerLng = spaces.reduce((sum, space) => sum + parseFloat(space.longitude.toString()), 0) / spaces.length;

    // Generate markers data
    const markersData = spaces.map(space => ({
      lat: parseFloat(space.latitude.toString()),
      lng: parseFloat(space.longitude.toString()),
      name: space.name,
      location: space.location,
      capacity: space.capacity,
      pph: space.pph,
      description: space.description || '',
      avgRating: space.avgRating || '0.0',
      reviewCount: space.reviewCount || 0
    }));

    const backgroundColor = isDark ? '#0b1220' : '#ffffff';
    const textColor = isDark ? '#e6eef8' : '#111827';
    const secondaryTextColor = isDark ? '#c9d6ea' : '#6b7280';
    // Popup button colors (make them visible in both modes)
    const buttonBg = isDark ? '#1f2937' : '#E9F0E9';
    const buttonText = isDark ? '#e6eef8' : '#000000';

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
          .leaflet-popup-content-wrapper {
            background-color: ${backgroundColor};
            color: ${textColor};
            border-radius: 8px;
            box-shadow: 0 3px 14px rgba(0,0,0,0.4);
          }
          .leaflet-popup-content {
            margin: 12px 12px;
            line-height: 1.4;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
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
          .popup-detail {
            margin: 0 0 6px 0;
            font-size: 14px;
            color: ${secondaryTextColor};
          }
          .popup-description {
            margin: 0 0 12px 0;
            font-size: 13px;
            color: ${secondaryTextColor};
            line-height: 1.4;
          }
          .popup-button {
            display: inline-block;
            background: ${buttonBg};
            color: ${buttonText};
            padding: 8px 14px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            margin-top: 8px;
          }
          .leaflet-container {
            background: ${backgroundColor};
          }
        </style>
      </head>
      <body>
        <div id="map"></div>
        <script>
          // Initialize map
          var map = L.map('map').setView([${centerLat}, ${centerLng}], 12);

          // Add OpenStreetMap tile layer
          L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors',
            maxZoom: 19
          }).addTo(map);

          // Schedura logo is a JPG.
          // Replace the URL below with your actual schedura JPG location or a base64 data URL.
          var scheduraIconUrl = 'https://zcpesqgzeeiewddphdwg.supabase.co/storage/v1/object/public/organisations/logo.jpg';

          var scheduraIcon = L.icon({
            iconUrl: scheduraIconUrl,
            iconSize: [33, 33],    // size of the icon
            iconAnchor: [16.5, 16.5],  // point of the icon which will correspond to marker's location
            popupAnchor: [0, -40]  // point from which the popup should open relative to the iconAnchor
          });

          // Markers data
          var markers = ${JSON.stringify(markersData)};

          // Add markers using custom schedura icon
          var markerGroup = [];
          markers.forEach(function(markerData) {
            var marker = L.marker([markerData.lat, markerData.lng], { icon: scheduraIcon }).addTo(map);
            
            var popupContent = 
              '<div>' +
                '<h3 class="popup-title">' + markerData.name + '</h3>' +
                '<p class="popup-detail"><strong>📍</strong> ' + markerData.location + '</p>' +
                '<p class="popup-detail"><strong>⭐</strong> ' + markerData.avgRating + ' (' + markerData.reviewCount + ' reviews)</p>' +
                '<p class="popup-detail"><strong>👥</strong> Capacity: ' + markerData.capacity + '</p>' +
                '<p class="popup-detail"><strong>💰</strong> ₹' + markerData.pph + '/hour</p>' +
                (markerData.description ? 
                  '<p class="popup-description">' + 
                  (markerData.description.length > 100 ? 
                    markerData.description.substring(0, 100) + '...' : 
                    markerData.description) + 
                  '</p>' : '') +
                '<a href="geo:' + markerData.lat + ',' + markerData.lng + '" ' +
                'class="popup-button">📍 Open in Maps</a>' +
              '</div>';
            
            marker.bindPopup(popupContent);
            markerGroup.push(marker);
          });

          // Fit bounds to show all markers
          if (markers.length > 1) {
            var group = new L.featureGroup(markerGroup);
            map.fitBounds(group.getBounds().pad(0.1));
          }
        </script>
      </body>
      </html>
    `;
  };

  if (loading) {
    return (
      <SafeBoundingView style={{ flex: 1, backgroundColor: colors.background }}>
        <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
          <ActivityIndicator size="large" color={colors.accent} />
          <Text style={{ color: colors.text, fontSize: 18, marginTop: 16 }}>Loading spaces...</Text>
        </View>
      </SafeBoundingView>
    );
  }

  return (
    <SafeBoundingView style={{ flex: 1, backgroundColor: colors.background }} className="relative">
      <StatusBar barStyle={isDark ? "light-content" : "dark-content"} backgroundColor={colors.card} />
      
      {/* Header */}
      <View style={{ 
        flexDirection: 'row', 
        alignItems: 'center', 
        justifyContent: 'space-between',
        backgroundColor: colors.card,
        borderBottomWidth: 1,
        borderBottomColor: colors.border,
        zIndex: 10,
      }}
        className='absolute top-5 left-5 rounded-full'
      >
        <TouchableOpacity onPress={back} style={{ padding: 8 }}>
          <Ionicons name="arrow-back" size={24} color={colors.text} />
        </TouchableOpacity>
        
      </View>

      {spaces.length === 0 ? (
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center', paddingHorizontal: 24 }}>
          <Ionicons name="location-outline" size={64} color={colors.textSecondary} />
          <Text style={{ fontSize: 20, fontWeight: '600', color: colors.text, marginTop: 16, textAlign: 'center' }}>
            No Spaces with Locations
          </Text>
          <Text style={{ color: colors.textSecondary, fontSize: 16, textAlign: 'center', marginTop: 8 }}>
            Spaces need to have location coordinates to appear on the map
          </Text>
        </View>
      ) : (
        <>
          {/* Map Container with WebView */}
          <View style={{ flex: 1, backgroundColor: colors.backgroundSecondary }}>
            <WebView
              style={{ flex: 1 }}
              originWhitelist={['*']}
              source={{ html: generateMapHTML() }}
              javaScriptEnabled={true}
              domStorageEnabled={true}
              startInLoadingState={true}
              scalesPageToFit={true}
              renderLoading={() => (
                <View style={{ 
                  position: 'absolute', 
                  top: 0, 
                  left: 0, 
                  right: 0, 
                  bottom: 0, 
                  justifyContent: 'center', 
                  alignItems: 'center',
                  backgroundColor: colors.backgroundSecondary
                }}>
                  <ActivityIndicator size="large" color={colors.accent} />
                </View>
              )}
            />
          </View>

          {/* Map Info Footer */}
          <View style={{ 
            backgroundColor: colors.card, 
            padding: 16, 
            borderTopWidth: 1, 
            borderTopColor: colors.border,
            zIndex: 10,
          }}>
            <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
              <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
                <Ionicons name="information-circle-outline" size={20} color={colors.accent} />
                <Text style={{ color: colors.textSecondary, fontSize: 14 }}>
                  Tap markers to view space details
                </Text>
              </View>
              <TouchableOpacity 
                onPress={fetchSpaces}
                style={{ 
                  backgroundColor: colors.accent, 
                  paddingHorizontal: 12, 
                  paddingVertical: 6, 
                  borderRadius: 8 
                }}
              >
                <Text style={{ color: colors.primary, fontSize: 12, fontWeight: '600' }}>
                  Refresh
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </>
      )}
    </SafeBoundingView>
  );
}
