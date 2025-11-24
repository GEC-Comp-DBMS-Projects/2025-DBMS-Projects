import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import React, { useEffect, useState } from 'react';
import {
    ActivityIndicator,
    FlatList,
    Pressable,
    StyleSheet,
    Text,
    TextInput,
    View,
} from 'react-native';
import Animated, { useAnimatedStyle, useSharedValue, withTiming } from 'react-native-reanimated';
import { useTheme } from '../../context/themeContext';
import { darkTheme, lightTheme } from '../../theme';

type Motherboard = {
  id: number;
  name: string;
  chipset: string;
  ram_type: string;
  storage_slots: string;
};

export default function StorageInputScreen() {
  const router = useRouter();
  const { isDark } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;

  const progress = useSharedValue(isDark ? 1 : 0);
  useEffect(() => { progress.value = withTiming(isDark ? 1 : 0, { duration: 400 }); }, [isDark]);

  const bgAnim = useAnimatedStyle(() => ({ backgroundColor: progress.value ? darkTheme.background : lightTheme.background }));
  const textColorAnim = (dark: string, light: string) => useAnimatedStyle(() => ({ color: progress.value ? dark : light }));

  const [step, setStep] = useState(1);

  const [mobos, setMobos] = useState<Motherboard[]>([]);
  const [filteredMobos, setFilteredMobos] = useState<Motherboard[]>([]);
  const [searchMobo, setSearchMobo] = useState('');
  const [selectedMobo, setSelectedMobo] = useState<Motherboard | null>(null);
  const [loadingMobo, setLoadingMobo] = useState(true);

  const [storageType, setStorageType] = useState<'HDD' | 'SATA SSD' | 'NVMe SSD' | null>(null);
  const [capacity, setCapacity] = useState('');
  const [budget, setBudget] = useState('');

  useEffect(() => {
    fetch('URL_Backend/api/hardware/motherboard')
      .then(res => res.json())
      .then(data => { setMobos(data); setFilteredMobos(data); })
      .finally(() => setLoadingMobo(false));
  }, []);

  useEffect(() => {
    const txt = searchMobo.trim().toLowerCase();
    setFilteredMobos(!txt ? mobos : mobos.filter(mb =>
      mb.name.toLowerCase().includes(txt) || mb.chipset.toLowerCase().includes(txt)
    ));
  }, [searchMobo, mobos]);

  const handleNext = () => {
    if (step === 1 && !selectedMobo) return alert('Please select a Motherboard');
    if (step === 2 && !storageType) return alert('Please select a Storage Type');
    if (step === 3 && !capacity) return alert('Please enter minimum capacity');
    if (step === 4 && !budget) return alert('Please enter your budget');
    setStep(step + 1);
  };

  const handleBack = () => setStep(step - 1);

  const handleSubmit = () => {
    if (!selectedMobo || !storageType || !capacity || !budget) {
      return alert('Please complete all selections');
    }
    router.push({
      pathname: '/(screens)/Storage/StorageLoadingScreen',
      params: {
        moboId: selectedMobo.id,
        storageType,
        capacity: Number(capacity),
        budget: Number(budget),
      },
    });
  };

  const renderMoboCard = (item: Motherboard) => (
    <Pressable
      style={[
        styles.card,
        { backgroundColor: theme.cardBackground },
        selectedMobo?.id === item.id && { borderColor: theme.accent, backgroundColor: theme.accent + '22', shadowColor: theme.accent },
      ]}
      onPress={() => setSelectedMobo(item)}
    >
      <Text style={[styles.cardTitle, { color: theme.textPrimary }]}>{item.name}</Text>
      <Text style={[styles.cardSubtitle, { color: theme.textSecondary }]}>
        {item.chipset} • RAM {item.ram_type} • Slots {item.storage_slots}
      </Text>
    </Pressable>
  );

  return (
    <Animated.View style={[styles.container, bgAnim]}>
      <Animated.Text style={[styles.header, textColorAnim(darkTheme.textSecondary, lightTheme.textSecondary)]}>
        Step {step} of 4
      </Animated.Text>

      {step === 1 && (
        <View style={styles.stepContainer}>
          <Animated.Text style={[styles.title, textColorAnim(theme.textPrimary, theme.textPrimary)]}>
            Select Your Motherboard
          </Animated.Text>
          {loadingMobo ? <ActivityIndicator size="large" color={theme.accent} /> : (
            <>
              <View style={styles.searchWrapper}>
                <Ionicons name="search" size={20} color={theme.textSecondary} style={{ marginRight: 8 }} />
                <TextInput
                  style={[styles.searchInput, { backgroundColor: theme.cardBackground, color: theme.textPrimary }]}
                  placeholder="Search Motherboard..."
                  placeholderTextColor={theme.textSecondary}
                  value={searchMobo}
                  onChangeText={setSearchMobo}
                />
              </View>
              <FlatList
                data={filteredMobos}
                keyExtractor={item => item.id.toString()}
                renderItem={({ item }) => renderMoboCard(item)}
              />
            </>
          )}
        </View>
      )}

      {step === 2 && (
        <View style={styles.stepContainer}>
          <Animated.Text style={[styles.title, textColorAnim(theme.textPrimary, theme.textPrimary)]}>
            Select Storage Type
          </Animated.Text>
          {['HDD', 'SATA SSD', 'NVMe SSD'].map(type => (
            <Pressable
              key={type}
              style={[
                styles.card,
                { backgroundColor: theme.cardBackground },
                storageType === type && { borderColor: theme.accent, backgroundColor: theme.accent + '22', shadowColor: theme.accent },
              ]}
              onPress={() => setStorageType(type as any)}
            >
              <Text style={{ color: theme.textPrimary, fontSize: 18 }}>{type}</Text>
            </Pressable>
          ))}
        </View>
      )}

      {step === 3 && (
        <View style={styles.stepContainer}>
          <Animated.Text style={[styles.title, textColorAnim(theme.textPrimary, theme.textPrimary)]}>
            Enter Minimum Capacity (GB or TB)
          </Animated.Text>
          <TextInput
            style={[styles.input, { backgroundColor: theme.cardBackground, color: theme.textPrimary, borderColor: theme.icon }]}
            placeholder="e.g. 1000 (for 1TB)"
            placeholderTextColor={theme.textSecondary}
            value={capacity}
            onChangeText={setCapacity}
            keyboardType="numeric"
          />
        </View>
      )}

      {step === 4 && (
        <View style={styles.stepContainer}>
          <Animated.Text style={[styles.title, textColorAnim(theme.textPrimary, theme.textPrimary)]}>
            Enter Your Budget
          </Animated.Text>
          <TextInput
            style={[styles.input, { backgroundColor: theme.cardBackground, color: theme.textPrimary, borderColor: theme.icon }]}
            placeholder="₹ (e.g. 5000)"
            placeholderTextColor={theme.textSecondary}
            value={budget}
            onChangeText={setBudget}
            keyboardType="numeric"
          />
        </View>
      )}

      <View style={styles.navRow}>
        {step > 1 && (
          <Pressable style={[styles.navButton, { backgroundColor: theme.accent }]} onPress={handleBack}>
            <Text style={{ color: theme.accentText }}>Back</Text>
          </Pressable>
        )}
        {step < 4 ? (
          <Pressable style={[styles.navButton, { backgroundColor: theme.accent }]} onPress={handleNext}>
            <Text style={{ color: theme.accentText }}>Next</Text>
          </Pressable>
        ) : (
          <Pressable style={[styles.navButton, { backgroundColor: theme.accent }]} onPress={handleSubmit}>
            <Text style={{ color: theme.accentText }}>Find Storage</Text>
          </Pressable>
        )}
      </View>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, paddingTop: 50 },
  header: { fontSize: 20, fontWeight: '600', marginBottom: 15 },
  stepContainer: { flex: 1 },
  title: { fontSize: 22, marginBottom: 15 },
  searchWrapper: { flexDirection: 'row', alignItems: 'center', borderRadius: 8, marginBottom: 10, paddingHorizontal: 10 },
  searchInput: { flex: 1, padding: 10, borderRadius: 8 },
  input: { borderWidth: 1, padding: 12, borderRadius: 8, marginVertical: 10 },
  card: { padding: 16, marginVertical: 6, borderRadius: 12, borderWidth: 2, borderColor: 'transparent', shadowOpacity: 0.05, shadowRadius: 4, elevation: 2 },
  cardTitle: { fontSize: 16, fontWeight: '600' },
  cardSubtitle: { fontSize: 14, marginTop: 4 },
  navRow: { flexDirection: 'row', justifyContent: 'space-between', marginVertical: 20 },
  navButton: { paddingVertical: 14, paddingHorizontal: 20, borderRadius: 8, elevation: 2 },
});
