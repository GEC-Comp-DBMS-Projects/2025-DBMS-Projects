import { Ionicons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import React, { useEffect, useState } from 'react';
import {
  Animated,
  Dimensions,
  Image,
  Modal,
  ScrollView,
  Share,
  StyleSheet,
  Text,
  TouchableOpacity,
  View
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '../../context/themeContext';
import { darkTheme, lightTheme } from '../../theme';

const { width } = Dimensions.get('window');

const RamRecommendationScreen = () => {
  const { isDark } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;

  const router = useRouter();
  const { recommendations } = useLocalSearchParams();

  const [data, setData] = useState<any[]>([]);
  const [selectedRam, setSelectedRam] = useState<any>(null);
  const [anims, setAnims] = useState<{ opacity: Animated.Value; translateY: Animated.Value }[]>([]);

  useEffect(() => {
    if (recommendations) {
      try {
        const decoded = decodeURIComponent(recommendations as string);
        const parsedData = JSON.parse(decoded);
        setData(parsedData);

        const animationValues = parsedData.map(() => ({
          opacity: new Animated.Value(0),
          translateY: new Animated.Value(30),
        }));
        setAnims(animationValues);
      } catch (err) {
        console.error("❌ Failed to parse recommendations:", err);
        setData([]);
        setAnims([]);
      }
    }
  }, [recommendations]);

  useEffect(() => {
    anims.forEach(({ opacity, translateY }, index) => {
      Animated.parallel([
        Animated.timing(opacity, {
          toValue: 1,
          duration: 400,
          delay: index * 150,
          useNativeDriver: true,
        }),
        Animated.timing(translateY, {
          toValue: 0,
          duration: 400,
          delay: index * 150,
          useNativeDriver: true,
        }),
      ]).start();
    });
  }, [anims]);

  const getBadgeColor = (label: string) => {
    if (label.includes("Best Match")) return "#4CAF50";
    if (label.includes("High Speed")) return "#2196F3";
    if (label.includes("Budget")) return "#FFC107";
    return theme.icon;
  };

  const shareRam = async (ram: any) => {
    const baseUrl = 'https://myapp.com/ram';
    const params = encodeURIComponent(JSON.stringify(ram));
    const shareUrl = `${baseUrl}?data=${params}`;
    try {
      await Share.share({
        message: `Check out this RAM: ${ram.name}\n${shareUrl}`,
      });
    } catch (err) {
      console.error('❌ Error sharing RAM:', err);
    }
  };

  const shareAllRecommendations = async () => {
    const baseUrl = 'https://myapp.com/ram';
    const params = encodeURIComponent(JSON.stringify(data));
    const shareUrl = `${baseUrl}?data=${params}`;
    try {
      await Share.share({
        message: `Check out my RAM recommendations:\n${shareUrl}`,
      });
    } catch (err) {
      console.error('❌ Error sharing recommendations:', err);
    }
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: theme.background }]}>
      <Text style={[styles.header, { color: theme.textPrimary }]}>
        Top RAM Recommendations
      </Text>

      <ScrollView contentContainerStyle={styles.scrollContainer}>
        {data.map((ram, index) => (
          <Animated.View
            key={index}
            style={[
              styles.card,
              {
                backgroundColor: theme.cardBackground,
                opacity: anims[index]?.opacity || 0,
                transform: [{ translateY: anims[index]?.translateY || 30 }],
              },
            ]}
          >
            <Image
              source={{ uri: ram.image || 'https://via.placeholder.com/400x200.png?text=No+Image' }}
              style={styles.cardImage}
              resizeMode="contain"
            />

            <View style={styles.cardInfo}>
              <Text style={[styles.cardName, { color: theme.textPrimary }]}>
                {ram.name}
              </Text>

              <Text style={[styles.cardPrice, { color: theme.textPrimary }]}>
                ₹{ram.price}
              </Text>

              <View style={styles.tags}>
                {ram.tags?.map((tag: string, i: number) => (
                  <View key={i} style={[styles.tag, { backgroundColor: getBadgeColor(tag) }]}>
                    <Text style={styles.tagText}>{tag}</Text>
                  </View>
                ))}
              </View>

              <TouchableOpacity
                style={[styles.detailsButton, { backgroundColor: theme.accent }]}
                onPress={() => setSelectedRam(ram)}
              >
                <Text style={styles.detailsButtonText}>View Details</Text>
              </TouchableOpacity>
            </View>
          </Animated.View>
        ))}

        <View style={styles.bottomButtons}>
          <TouchableOpacity
            style={[styles.shareAllButton, { backgroundColor: theme.accent }]}
            onPress={shareAllRecommendations}
          >
            <Text style={styles.shareAllText}>📤 Share All Recommendations</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.startOverButton, { borderColor: theme.accent }]}
            onPress={() => router.replace('/(screens)/WelcomeScreen')}
          >
            <Text style={[styles.startOverText, { color: theme.accent }]}>🔄 Start Over</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>

      <Modal
        visible={!!selectedRam}
        animationType="slide"
        transparent
        onRequestClose={() => setSelectedRam(null)}
      >
        <View style={styles.modalBackdrop}>
          <View style={[styles.modalContainer, { backgroundColor: theme.cardBackground }]}>
            <TouchableOpacity
              style={styles.closeIcon}
              onPress={() => setSelectedRam(null)}
            >
              <Ionicons name="close-circle" size={30} color={theme.icon} />
            </TouchableOpacity>

            {selectedRam && (
              <ScrollView contentContainerStyle={styles.modalContent}>
                <Image
                  source={{ uri: selectedRam.image || 'https://via.placeholder.com/400x200.png?text=No+Image' }}
                  style={styles.modalImage}
                  resizeMode="contain"
                />

                <Text style={[styles.modalName, { color: theme.textPrimary }]}>
                  {selectedRam.name}
                </Text>

                <View style={[styles.infoBox, { backgroundColor: theme.background }]}>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    🧬 Type: {selectedRam.type}
                  </Text>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    ⚡ Speed: {selectedRam.speed} MHz
                  </Text>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    📦 Capacity: {selectedRam.capacity} GB
                  </Text>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    📑 Modules: {selectedRam.modules}
                  </Text>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    💰 Price: ₹{selectedRam.price}
                  </Text>
                </View>

                <View style={styles.tags}>
                  {selectedRam.tags?.map((tag: string, i: number) => (
                    <View key={i} style={[styles.tag, { backgroundColor: getBadgeColor(tag) }]}>
                      <Text style={styles.tagText}>{tag}</Text>
                    </View>
                  ))}
                </View>

                <TouchableOpacity
                  style={[styles.shareButton, { backgroundColor: theme.accent }]}
                  onPress={() => shareRam(selectedRam)}
                >
                  <Text style={styles.shareButtonText}>Share Component</Text>
                </TouchableOpacity>
              </ScrollView>
            )}
          </View>
        </View>
      </Modal>
    </SafeAreaView>
  );
};

export default RamRecommendationScreen;

const styles = StyleSheet.create({
  container: { flex: 1, paddingTop: 20 },
  header: { fontSize: 24, fontWeight: '700', marginBottom: 16, textAlign: 'center' },
  scrollContainer: { paddingHorizontal: 16, paddingBottom: 40 },
  card: { borderRadius: 16, marginBottom: 20, padding: 12, elevation: 4 },
  cardImage: { width: '100%', height: 180, borderRadius: 12 },
  cardInfo: { marginTop: 10 },
  cardPrice: { fontSize: 18, fontWeight: '700', marginBottom: 6 },
  cardName: { fontSize: 18, fontWeight: '700', marginBottom: 4 },
  tags: { flexDirection: 'row', flexWrap: 'wrap', marginBottom: 10 },
  tag: { paddingVertical: 4, paddingHorizontal: 8, borderRadius: 12, marginRight: 6, marginBottom: 6 },
  tagText: { fontSize: 12, color: '#fff' },
  detailsButton: { paddingVertical: 8, borderRadius: 12, alignItems: 'center' },
  detailsButtonText: { color: '#fff', fontWeight: '600' },
  bottomButtons: { marginTop: 20, alignItems: 'center' },
  shareAllButton: { paddingVertical: 12, paddingHorizontal: 20, borderRadius: 16, marginBottom: 12 },
  shareAllText: { color: '#fff', fontWeight: '700', fontSize: 16 },
  startOverButton: { paddingVertical: 12, paddingHorizontal: 20, borderRadius: 16, borderWidth: 2 },
  startOverText: { fontWeight: '700', fontSize: 16 },

  modalBackdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'center', paddingHorizontal: 16 },
  modalContainer: { borderRadius: 20, padding: 16, maxHeight: '85%', shadowColor: '#000', shadowOpacity: 0.25, shadowRadius: 6, shadowOffset: { width: 0, height: 4 }, elevation: 8 },
  closeIcon: { position: 'absolute', top: 12, right: 12, zIndex: 10 },
  modalContent: { alignItems: 'center', paddingTop: 40, paddingBottom: 20 },
  modalImage: { width: '100%', height: 220, borderRadius: 16, marginBottom: 16 },
  modalName: { fontSize: 22, fontWeight: '700', marginBottom: 12, textAlign: 'center' },
  infoBox: { width: '100%', padding: 12, borderRadius: 16, marginBottom: 16, alignItems: 'flex-start' },
  modalDetail: { fontSize: 16, marginBottom: 6 },
  shareButton: { marginTop: 10, paddingVertical: 12, paddingHorizontal: 20, borderRadius: 16 },
  shareButtonText: { color: '#fff', fontWeight: '700', fontSize: 16 },
});
