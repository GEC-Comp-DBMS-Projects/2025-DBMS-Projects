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

type CPU = { id: number; name: string; brand: string; cores: number; tdp: number };
type GPU = { id: number; name: string; vram: number; chipset: string };
type RAM = { id: number; name: string; speed: number; size: number };

export default function MotherboardInputScreen() {
  const router = useRouter();
  const { isDark } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;

  const progress = useSharedValue(isDark ? 1 : 0);
  useEffect(() => { progress.value = withTiming(isDark ? 1 : 0, { duration: 400 }); }, [isDark]);

  const bgAnim = useAnimatedStyle(() => ({ backgroundColor: progress.value ? darkTheme.background : lightTheme.background }));
  const textColorAnim = (dark: string, light: string) => useAnimatedStyle(() => ({ color: progress.value ? dark : light }));

  const [step, setStep] = useState(1);

  const [cpus, setCpus] = useState<CPU[]>([]);
  const [filteredCpus, setFilteredCpus] = useState<CPU[]>([]);
  const [searchCpu, setSearchCpu] = useState('');
  const [selectedCpu, setSelectedCpu] = useState<CPU | null>(null);
  const [loadingCpu, setLoadingCpu] = useState(true);

  const [gpus, setGpus] = useState<GPU[]>([]);
  const [filteredGpus, setFilteredGpus] = useState<GPU[]>([]);
  const [searchGpu, setSearchGpu] = useState('');
  const [selectedGpu, setSelectedGpu] = useState<GPU | null>(null);
  const [loadingGpu, setLoadingGpu] = useState(true);

  const [rams, setRams] = useState<RAM[]>([]);
  const [filteredRams, setFilteredRams] = useState<RAM[]>([]);
  const [searchRam, setSearchRam] = useState('');
  const [selectedRam, setSelectedRam] = useState<RAM | null>(null);
  const [loadingRam, setLoadingRam] = useState(true);

  const [budget, setBudget] = useState('');
  const [strictBudget, setStrictBudget] = useState(false);

  useEffect(() => {
    fetch('URL_Backend/api/hardware/cpu').then(res => res.json()).then(data => { setCpus(data); setFilteredCpus(data); }).finally(() => setLoadingCpu(false));
    fetch('URL_Backend/api/hardware/gpu').then(res => res.json()).then(data => { setGpus(data); setFilteredGpus(data); }).finally(() => setLoadingGpu(false));
    fetch('URL_Backend/api/hardware/ram').then(res => res.json()).then(data => { setRams(data); setFilteredRams(data); }).finally(() => setLoadingRam(false));
  }, []);

  useEffect(() => { const txt = searchCpu.trim().toLowerCase(); setFilteredCpus(!txt ? cpus : cpus.filter(c => c.name.toLowerCase().includes(txt))); }, [searchCpu, cpus]);
  useEffect(() => { const txt = searchGpu.trim().toLowerCase(); setFilteredGpus(!txt ? gpus : gpus.filter(g => g.name.toLowerCase().includes(txt))); }, [searchGpu, gpus]);
  useEffect(() => { const txt = searchRam.trim().toLowerCase(); setFilteredRams(!txt ? rams : rams.filter(r => r.name.toLowerCase().includes(txt))); }, [searchRam, rams]);

  const handleSubmit = () => {
    if (!selectedCpu || !selectedGpu || !selectedRam || !budget) return alert('Please complete all selections');
    router.push({
      pathname: './MotherboardLoadingScreen',
      params: {
        cpuId: selectedCpu.id,
        gpuId: selectedGpu.id,
        ramId: selectedRam.id,
        budget: Number(budget),
        strictBudget: strictBudget ? 'true' : 'false',
      },
    });
  };
  const handleNext = () => { if (step === 1 && !selectedCpu) return alert('Please select a CPU'); if (step === 2 && !selectedGpu) return alert('Please select a GPU'); if (step === 3 && !selectedRam) return alert('Please select RAM'); setStep(step + 1); };
  const handleBack = () => setStep(step - 1);

  const renderCard = (item: any, selected: any, setSelected: (val: any) => void, details: string) => (
    <Pressable
      style={[
        styles.card,
        { backgroundColor: theme.cardBackground },
        selected?.id === item.id && { borderColor: theme.accent, backgroundColor: theme.accent + '22', shadowColor: theme.accent },
      ]}
      onPress={() => setSelected(item)}
    >
      <Text style={[styles.cardTitle, { color: theme.textPrimary }]}>{item.name}</Text>
      <Text style={[styles.cardSubtitle, { color: theme.textSecondary }]}>{details}</Text>
    </Pressable>
  );

  const renderStep = () => {
    switch(step) {
      case 1: return loadingCpu ? <ActivityIndicator size="large" /> : (
        <>
          <View style={styles.searchWrapper}>
            <Ionicons name="search" size={20} color={theme.textSecondary} style={{ marginRight: 8 }} />
            <TextInput
              style={[styles.searchInput, { backgroundColor: theme.cardBackground, color: theme.textPrimary }]}
              placeholder="Search CPU..."
              placeholderTextColor={theme.textSecondary}
              value={searchCpu}
              onChangeText={setSearchCpu}
            />
          </View>
          <FlatList
            data={filteredCpus}
            keyExtractor={item => item.id.toString()}
            renderItem={({ item }) => renderCard(item, selectedCpu, setSelectedCpu, `${item.brand} • ${item.cores} cores • ${item.tdp}W`)}
          />
        </>
      );
      case 2: return loadingGpu ? <ActivityIndicator size="large" /> : (
        <>
          <View style={styles.searchWrapper}>
            <Ionicons name="search" size={20} color={theme.textSecondary} style={{ marginRight: 8 }} />
            <TextInput
              style={[styles.searchInput, { backgroundColor: theme.cardBackground, color: theme.textPrimary }]}
              placeholder="Search GPU..."
              placeholderTextColor={theme.textSecondary}
              value={searchGpu}
              onChangeText={setSearchGpu}
            />
          </View>
          <FlatList
            data={filteredGpus}
            keyExtractor={item => item.id.toString()}
            renderItem={({ item }) => renderCard(item, selectedGpu, setSelectedGpu, `${item.vram}GB • ${item.chipset}`)}
          />
        </>
      );
      case 3: return loadingRam ? <ActivityIndicator size="large" /> : (
        <>
          <View style={styles.searchWrapper}>
            <Ionicons name="search" size={20} color={theme.textSecondary} style={{ marginRight: 8 }} />
            <TextInput
              style={[styles.searchInput, { backgroundColor: theme.cardBackground, color: theme.textPrimary }]}
              placeholder="Search RAM..."
              placeholderTextColor={theme.textSecondary}
              value={searchRam}
              onChangeText={setSearchRam}
            />
          </View>
          <FlatList
            data={filteredRams}
            keyExtractor={item => item.id.toString()}
            renderItem={({ item }) => renderCard(item, selectedRam, setSelectedRam, `${item.size}GB • ${item.speed}MHz`)}
          />
        </>
      );
      case 4: return (
        <View style={{ flex: 1 }}>
          <TextInput
            style={[styles.input, { backgroundColor: theme.cardBackground, color: theme.textPrimary, borderColor: theme.icon }]}
            placeholder="₹ e.g. 40000"
            placeholderTextColor={theme.textSecondary}
            value={budget}
            onChangeText={setBudget}
            keyboardType="numeric"
          />
          <Pressable
            style={[styles.checkboxItem, { borderColor: theme.icon }, strictBudget && { backgroundColor: theme.accent + '22' }]}
            onPress={() => setStrictBudget(prev => !prev)}
          >
            <Text style={{ color: theme.textPrimary }}>Strict Budget Mode: {strictBudget ? 'On' : 'Off'}</Text>
          </Pressable>
        </View>
      );
      default: return null;
    }
  };

  return (
    <Animated.View style={[styles.container, bgAnim]}>
      <View style={styles.progressContainer}>
        <View style={[styles.progressBar, { width: `${(step / 4) * 100}%`, backgroundColor: theme.accent }]} />
      </View>
      <Animated.Text style={[styles.header, textColorAnim(darkTheme.textSecondary, lightTheme.textSecondary)]}>Step {step} of 4</Animated.Text>
      <Text style={[styles.title, textColorAnim(theme.textPrimary, theme.textPrimary)]}>
        {step === 1 ? "Select CPU" : step === 2 ? "Select GPU" : step === 3 ? "Select RAM" : "Enter Budget"}
      </Text>
      {renderStep()}

      <View style={styles.navRow}>
        {step > 1 && <Pressable style={[styles.navButton, { backgroundColor: theme.accent }]} onPress={handleBack}><Text style={{ color: theme.accentText }}>Back</Text></Pressable>}
        {step < 4 ? <Pressable style={[styles.navButton, { backgroundColor: theme.accent }]} onPress={handleNext}><Text style={{ color: theme.accentText }}>Next</Text></Pressable> :
          <Pressable style={[styles.navButton, { backgroundColor: theme.accent }]} onPress={handleSubmit}><Text style={{ color: theme.accentText }}>Find Compatible Motherboard</Text></Pressable>}
      </View>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, paddingTop: 50 },
  header: { fontSize: 18, marginBottom: 10 },
  title: { fontSize: 22, marginBottom: 15 },
  searchWrapper: { flexDirection: 'row', alignItems: 'center', marginBottom: 10, borderRadius: 8, paddingHorizontal: 10 },
  searchInput: { flex: 1, padding: 10, borderRadius: 8 },
  input: { borderWidth: 1, padding: 12, borderRadius: 8, marginVertical: 10 },
  card: { padding: 18, marginVertical: 6, borderRadius: 12, borderWidth: 2, borderColor: 'transparent', shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 4, elevation: 2 },
  cardTitle: { fontSize: 18, fontWeight: '600' },
  cardSubtitle: { fontSize: 14, marginTop: 4 },
  checkboxItem: { borderWidth: 1, borderRadius: 8, padding: 12, marginVertical: 10 },
  navRow: { flexDirection: 'row', justifyContent: 'space-between', marginVertical: 20 },
  navButton: { paddingVertical: 14, paddingHorizontal: 20, borderRadius: 8, elevation: 2 },
  progressContainer: { height: 4, backgroundColor: '#ccc', borderRadius: 2, marginBottom: 10 },
  progressBar: { height: 4, borderRadius: 2 },
});
