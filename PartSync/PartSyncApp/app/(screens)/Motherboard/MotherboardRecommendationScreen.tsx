import { Ionicons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import React, { useEffect, useState } from 'react';
import {
    ActivityIndicator,
    Alert,
    Animated,
    Dimensions,
    Image,
    Modal,
    ScrollView,
    Share,
    StyleSheet,
    Text,
    TouchableOpacity,
    View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useTheme } from '../../context/themeContext';
import { darkTheme, lightTheme } from '../../theme';

const { width } = Dimensions.get('window');
const API_BASE = 'URL_Backend';

const MotherboardRecommendationScreen = () => {
  const { isDark } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;
  const router = useRouter();
  const { recommendations } = useLocalSearchParams();

  const [data, setData] = useState<any[]>([]);
  const [selectedMobo, setSelectedMobo] = useState<any>(null);
  const [anims, setAnims] = useState<{ opacity: Animated.Value; translateY: Animated.Value }[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (recommendations) {
      try {
        const decoded = decodeURIComponent(recommendations as string);
        const parsedData = JSON.parse(decoded);
        setData(parsedData);

        const animationValues = parsedData.map(() => ({
          opacity: new Animated.Value(0),
          translateY: new Animated.Value(20),
        }));
        setAnims(animationValues);
      } catch (err) {
        console.error('❌ Failed to parse recommendations:', err);
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
    if (label.includes('Best Match')) return '#4CAF50';
    if (label.includes('Future Proof')) return '#2196F3';
    if (label.includes('Budget')) return '#FFC107';
    return theme.icon;
  };

  const saveBuildAndGetUrl = async (buildPayload: any) => {
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE}/api/builds`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(buildPayload),
      });
      if (!res.ok) {
        const msg = (await res.json().catch(() => ({}))).error || 'Save failed';
        throw new Error(msg);
      }
      const data = await res.json();
      return data.url;
    } catch (err: any) {
      console.error('💥 saveBuildAndGetUrl error:', err);
      Alert.alert('Error', 'Unable to create a shareable link.');
      return null;
    } finally {
      setLoading(false);
    }
  };

  const shareMotherboard = async (mobo: any) => {
    const payload = {
      title: `Motherboard Recommendation: ${mobo.name}`,
      description: 'Shared from PartSync',
      components: { motherboard: mobo },
      meta: { sharedFrom: 'app', timestamp: Date.now() },
    };

    const url = await saveBuildAndGetUrl(payload);
    if (!url) return;

    try {
      await Share.share({
        message: `Check out this Motherboard I found on PartSync:\n${mobo.name}\n${url}`,
      });
    } catch (err) {
      console.error('❌ Error sharing Motherboard:', err);
    }
  };

  const shareAllRecommendations = async () => {
    if (!data.length) {
      Alert.alert('No data', 'No recommendations available to share.');
      return;
    }

    const components = data.reduce((acc, mobo, index) => {
      acc[`motherboard_${index + 1}`] = mobo;
      return acc;
    }, {} as any);

    const payload = {
      title: 'My Motherboard Recommendations',
      description: 'Shared from PartSync',
      components,
      meta: { sharedFrom: 'app', count: data.length, timestamp: Date.now() },
    };

    const url = await saveBuildAndGetUrl(payload);
    if (!url) return;

    try {
      await Share.share({
        message: `Here are my Motherboard recommendations from PartSync:\n${url}`,
      });
    } catch (err) {
      console.error('❌ Error sharing recommendations:', err);
    }
  };

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: theme.background }]}>
      <Text style={[styles.header, { color: theme.textPrimary }]}>Top Motherboard Recommendations</Text>

      {loading && (
        <View style={styles.loadingOverlay}>
          <ActivityIndicator size="large" color={theme.accent} />
          <Text style={[styles.loadingText, { color: theme.textSecondary }]}>Saving build...</Text>
        </View>
      )}

      <ScrollView contentContainerStyle={styles.scrollContainer}>
        {data.map((mobo, index) => (
          <Animated.View
            key={index}
            style={[
              styles.card,
              {
                backgroundColor: theme.cardBackground,
                opacity: anims[index]?.opacity || 0,
                transform: [{ translateY: anims[index]?.translateY || 20 }],
              },
            ]}
          >
            <Image
              source={{ uri: mobo.image || 'https://via.placeholder.com/400x200.png?text=No+Image' }}
              style={styles.cardImage}
              resizeMode="contain"
            />

            <View style={styles.cardInfo}>
              <Text style={[styles.cardName, { color: theme.textPrimary }]}>{mobo.name}</Text>
              <Text style={[styles.cardPrice, { color: theme.textPrimary }]}>₹{mobo.price}</Text>

              <View style={styles.tags}>
                {mobo.tags?.map((tag: string, i: number) => (
                  <View key={i} style={[styles.tag, { backgroundColor: getBadgeColor(tag) }]}>
                    <Text style={styles.tagText}>{tag}</Text>
                  </View>
                ))}
              </View>

              <TouchableOpacity
                style={[styles.detailsButton, { backgroundColor: theme.accent }]}
                onPress={() => setSelectedMobo(mobo)}
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
        visible={!!selectedMobo}
        animationType="slide"
        transparent
        onRequestClose={() => setSelectedMobo(null)}
      >
        <View style={styles.modalBackdrop}>
          <View style={[styles.modalContainer, { backgroundColor: theme.cardBackground }]}>
            <TouchableOpacity style={styles.closeIcon} onPress={() => setSelectedMobo(null)}>
              <Ionicons name="close-circle" size={30} color={theme.icon} />
            </TouchableOpacity>

            {selectedMobo && (
              <ScrollView contentContainerStyle={styles.modalContent}>
                <Image
                  source={{ uri: selectedMobo.image }}
                  style={styles.modalImage}
                  resizeMode="contain"
                />
                <Text style={[styles.modalName, { color: theme.textPrimary }]}>{selectedMobo.name}</Text>

                <View style={[styles.infoBox, { backgroundColor: theme.background }]}>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    🧬 Socket: {selectedMobo.cpu_socket}
                  </Text>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    🖥️ Chipset: {selectedMobo.chipset}
                  </Text>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    💾 RAM Type: {selectedMobo.ram_type}
                  </Text>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    📦 RAM Slots: {selectedMobo.ram_slots}
                  </Text>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    💿 M.2 Slots: {selectedMobo.m2_slots}
                  </Text>
                  <Text style={[styles.modalDetail, { color: theme.textSecondary }]}>
                    💰 Price: ₹{selectedMobo.price}
                  </Text>
                </View>

                <View style={styles.tags}>
                  {selectedMobo.tags?.map((tag: string, i: number) => (
                    <View key={i} style={[styles.tag, { backgroundColor: getBadgeColor(tag) }]}>
                      <Text style={styles.tagText}>{tag}</Text>
                    </View>
                  ))}
                </View>

                <TouchableOpacity
                  style={[styles.shareButton, { backgroundColor: theme.accent }]}
                  onPress={() => shareMotherboard(selectedMobo)}
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

export default MotherboardRecommendationScreen;

const styles = StyleSheet.create({
  container: { flex: 1, paddingTop: 20 },
  header: { fontSize: 24, fontWeight: '700', marginBottom: 16, textAlign: 'center' },
  scrollContainer: { paddingHorizontal: 16, paddingBottom: 40 },
  card: {
    borderRadius: 16,
    marginBottom: 20,
    padding: 12,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
    elevation: 5,
  },
  cardImage: { width: '100%', height: 180, borderRadius: 12 },
  cardInfo: { marginTop: 10 },
  cardName: { fontSize: 18, fontWeight: '700', marginBottom: 4 },
  cardPrice: { fontSize: 18, fontWeight: '700', marginBottom: 6 },
  tags: { flexDirection: 'row', flexWrap: 'wrap', marginBottom: 10 },
  tag: { paddingVertical: 4, paddingHorizontal: 10, borderRadius: 12, marginRight: 6, marginBottom: 6 },
  tagText: { fontSize: 12, color: '#fff', fontWeight: '600' },
  detailsButton: { paddingVertical: 8, borderRadius: 12, alignItems: 'center' },
  detailsButtonText: { color: '#fff', fontWeight: '600' },
  bottomButtons: { marginTop: 20, alignItems: 'center' },
  shareAllButton: { paddingVertical: 12, paddingHorizontal: 20, borderRadius: 16, marginBottom: 12 },
  shareAllText: { color: '#fff', fontWeight: '700', fontSize: 16 },
  startOverButton: { paddingVertical: 12, paddingHorizontal: 20, borderRadius: 16, borderWidth: 2 },
  startOverText: { fontWeight: '700', fontSize: 16 },
  modalBackdrop: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'center', paddingHorizontal: 16 },
  modalContainer: { borderRadius: 20, padding: 16, maxHeight: '85%', elevation: 10 },
  closeIcon: { position: 'absolute', top: 12, right: 12, zIndex: 10 },
  modalContent: { alignItems: 'center', paddingTop: 40, paddingBottom: 20 },
  modalImage: { width: '100%', height: 220, borderRadius: 16, marginBottom: 16 },
  modalName: { fontSize: 22, fontWeight: '700', marginBottom: 12, textAlign: 'center' },
  infoBox: { width: '100%', padding: 12, borderRadius: 16, marginBottom: 16, alignItems: 'flex-start' },
  modalDetail: { fontSize: 16, marginBottom: 6 },
  shareButton: { marginTop: 10, paddingVertical: 12, paddingHorizontal: 20, borderRadius: 16 },
  shareButtonText: { color: '#fff', fontWeight: '700', fontSize: 16 },
  loadingOverlay: {
    position: 'absolute',
    top: '40%',
    left: 0,
    right: 0,
    alignItems: 'center',
    zIndex: 100,
  },
  loadingText: { marginTop: 8, fontSize: 14 },
});
