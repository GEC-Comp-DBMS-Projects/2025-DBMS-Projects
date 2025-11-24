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

type CPU = { id: number; name: string; brand: string; cores: number; tdp: number };
type PSU = { id: number; wattage: number; connector_6_pin: boolean; connector_8_pin: boolean };
type Motherboard = { id: number; name: string; chipset: string; pcie_version: string };

export default function HardwareInputScreen() {
  const router = useRouter();
  const { theme } = useTheme();
  const progress = useSharedValue(theme ? 1 : 0);

  useEffect(() => {
    progress.value = withTiming(theme ? 1 : 0, { duration: 400 });
  }, [theme]);

  const bgAnim = useAnimatedStyle(() => ({
    backgroundColor: theme.background,
  }));

  const textColorAnim = (color: string) =>
    useAnimatedStyle(() => ({ color }));

  const [step, setStep] = useState(1);

  const [cpus, setCpus] = useState<CPU[]>([]);
  const [filteredCpus, setFilteredCpus] = useState<CPU[]>([]);
  const [searchCpu, setSearchCpu] = useState('');
  const [selectedCpu, setSelectedCpu] = useState<CPU | null>(null);
  const [loadingCpu, setLoadingCpu] = useState(true);

  const [psus, setPsus] = useState<PSU[]>([]);
  const [filteredPsus, setFilteredPsus] = useState<PSU[]>([]);
  const [searchPsu, setSearchPsu] = useState('');
  const [selectedPsu, setSelectedPsu] = useState<PSU | null>(null);
  const [loadingPsu, setLoadingPsu] = useState(true);

  const [mobos, setMobos] = useState<Motherboard[]>([]);
  const [filteredMobos, setFilteredMobos] = useState<Motherboard[]>([]);
  const [searchMobo, setSearchMobo] = useState('');
  const [selectedMobo, setSelectedMobo] = useState<Motherboard | null>(null);
  const [loadingMobo, setLoadingMobo] = useState(true);

  const [budget, setBudget] = useState('');
  const [strictBudget, setStrictBudget] = useState(false);

  useEffect(() => {
    fetch('http://10.102.232.54:5000/api/hardware/cpu')
      .then(res => res.json())
      .then(data => { setCpus(data); setFilteredCpus(data); })
      .finally(() => setLoadingCpu(false));

    fetch('http://10.102.232.54:5000/api/hardware/psu')
      .then(res => res.json())
      .then(data => { setPsus(data); setFilteredPsus(data); })
      .finally(() => setLoadingPsu(false));

    fetch('http://10.102.232.54:5000/api/hardware/motherboard')
      .then(res => res.json())
      .then(data => { setMobos(data); setFilteredMobos(data); })
      .finally(() => setLoadingMobo(false));
  }, []);

  useEffect(() => {
    const txt = searchCpu.toLowerCase().trim();
    setFilteredCpus(!txt ? cpus : cpus.filter(cpu => cpu.name.toLowerCase().includes(txt) || cpu.brand.toLowerCase().includes(txt)));
  }, [searchCpu, cpus]);

  useEffect(() => {
    const txt = searchPsu.trim();
    setFilteredPsus(!txt ? psus : psus.filter(psu => psu.wattage.toString().includes(txt)));
  }, [searchPsu, psus]);

  useEffect(() => {
    const txt = searchMobo.toLowerCase().trim();
    setFilteredMobos(!txt ? mobos : mobos.filter(mb => mb.name.toLowerCase().includes(txt) || mb.chipset.toLowerCase().includes(txt)));
  }, [searchMobo, mobos]);

  const handleSubmit = () => {
    if (!selectedCpu || !selectedPsu || !selectedMobo || !budget) {
      return alert('Please complete all selections');
    }
    router.push({
      pathname: '/(screens)/Gpu/LoadingScreen',
      params: {
        cpuId: selectedCpu.id,
        psuId: selectedPsu.id,
        moboId: selectedMobo.id,
        budget: Number(budget),
        strictBudget: strictBudget ? 'true' : 'false',
      },
    });
  };

  const handleNext = () => {
    if (step === 1 && !selectedCpu) return alert('Please select a CPU');
    if (step === 2 && !selectedPsu) return alert('Please select a PSU');
    if (step === 3 && !selectedMobo) return alert('Please select a Motherboard');
    setStep(step + 1);
  };
  const handleBack = () => setStep(step - 1);

  const renderCard = (item: any, selectedItem: any, setSelected: (val: any) => void, details: string) => (
    <Pressable
      style={[
        styles.card,
        { backgroundColor: theme.card },
        selectedItem?.id === item.id && { borderColor: theme.accent, backgroundColor: theme.accent + '22', shadowColor: theme.accent },
      ]}
      onPress={() => setSelected(item)}
    >
      <Text style={[styles.cardTitle, { color: theme.textPrimary }]}>{item.name || `${item.wattage}W PSU`}</Text>
      <Text style={[styles.cardSubtitle, { color: theme.textSecondary }]}>{details}</Text>
    </Pressable>
  );

  const renderStep = () => {
    switch(step) {
      case 1: return (
        <>
          {loadingCpu ? <ActivityIndicator size="large" /> :
            <>
              <View style={styles.searchWrapper}>
                <Ionicons name="search" size={20} color={theme.textSecondary} style={{ marginRight: 8 }} />
                <TextInput
                  style={[styles.searchInput, { backgroundColor: theme.card, color: theme.textPrimary }]}
                  placeholder="Search CPU..."
                  placeholderTextColor={theme.textSecondary}
                  value={searchCpu}
                  onChangeText={setSearchCpu}
                />
              </View>
              <FlatList
                data={filteredCpus}
                keyExtractor={item => item.id?.toString() || Math.random().toString()}
                renderItem={({ item }) => renderCard(item, selectedCpu, setSelectedCpu, `${item.brand} • ${item.cores} cores • ${item.tdp}W TDP`)}
              />
            </>
          }
        </>
      );
      case 2: return (
        <>
          {loadingPsu ? <ActivityIndicator size="large" /> :
            <>
              <View style={styles.searchWrapper}>
                <Ionicons name="search" size={20} color={theme.textSecondary} style={{ marginRight: 8 }} />
                <TextInput
                  style={[styles.searchInput, { backgroundColor: theme.card, color: theme.textPrimary }]}
                  placeholder="Search PSU..."
                  placeholderTextColor={theme.textSecondary}
                  value={searchPsu}
                  onChangeText={setSearchPsu}
                  keyboardType="numeric"
                />
              </View>
              <FlatList
                data={filteredPsus}
                keyExtractor={item => item.id?.toString() || Math.random().toString()}
                renderItem={({ item }) => renderCard(item, selectedPsu, setSelectedPsu,
                  `${item.connector_6_pin ? '6-pin' : ''} ${item.connector_8_pin ? '8-pin' : ''}`)}
              />
            </>
          }
        </>
      );
      case 3: return (
        <>
          {loadingMobo ? <ActivityIndicator size="large" /> :
            <>
              <View style={styles.searchWrapper}>
                <Ionicons name="search" size={20} color={theme.textSecondary} style={{ marginRight: 8 }} />
                <TextInput
                  style={[styles.searchInput, { backgroundColor: theme.card, color: theme.textPrimary }]}
                  placeholder="Search Motherboard..."
                  placeholderTextColor={theme.textSecondary}
                  value={searchMobo}
                  onChangeText={setSearchMobo}
                />
              </View>
              <FlatList
                data={filteredMobos}
                keyExtractor={item => item.id?.toString() || Math.random().toString()}
                renderItem={({ item }) => renderCard(item, selectedMobo, setSelectedMobo, `${item.chipset} • PCIe ${item.pcie_version}`)}
              />
            </>
          }
        </>
      );
      case 4: return (
        <View style={{ flex: 1 }}>
          <TextInput
            style={[styles.input, { backgroundColor: theme.card, color: theme.textPrimary, borderColor: theme.accent }]}
            placeholder="₹ (e.g. 30000)"
            placeholderTextColor={theme.textSecondary}
            value={budget}
            onChangeText={setBudget}
            keyboardType="numeric"
          />
          <Pressable
            style={[styles.checkboxItem, { borderColor: theme.accent }, strictBudget && { backgroundColor: theme.accent + '22' }]}
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
        <View style={[styles.progressBar, { width: `${(step/4)*100}%`, backgroundColor: theme.accent }]} />
      </View>
      <Animated.Text style={[styles.header, textColorAnim(theme.textSecondary)]}>
        Step {step} of 4
      </Animated.Text>
      <Text style={[styles.title, textColorAnim(theme.textPrimary)]}>
        {step === 1 ? "Select Your CPU" :
         step === 2 ? "Select Your PSU" :
         step === 3 ? "Select Motherboard" :
         "Enter Your Budget"}
      </Text>

      {renderStep()}

      <View style={styles.navRow}>
        {step > 1 && <Pressable style={[styles.navButton, { backgroundColor: theme.accent }]} onPress={handleBack}><Text style={{ color: theme.accentText }}>Back</Text></Pressable>}
        {step < 4 ?
          <Pressable style={[styles.navButton, { backgroundColor: theme.accent }]} onPress={handleNext}><Text style={{ color: theme.accentText }}>Next</Text></Pressable> :
          <Pressable style={[styles.navButton, { backgroundColor: theme.accent }]} onPress={handleSubmit}><Text style={{ color: theme.accentText }}>Analyze Compatibility</Text></Pressable>}
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
