import { Ionicons } from "@expo/vector-icons";
import { useRouter } from "expo-router";
import React, { useEffect, useState } from "react";
import {
    ActivityIndicator,
    Alert,
    FlatList,
    Pressable,
    StyleSheet,
    Text,
    TextInput,
    View,
} from "react-native";
import Animated, { useAnimatedStyle, useSharedValue, withTiming } from "react-native-reanimated";
import { useTheme } from "../../context/themeContext";

type Motherboard = {
  id: number;
  name: string;
  ram_type: string;
};

type Ram = {
  id: number;
  name: string;
  type: string;
  speed: number;
  capacity: number;
  modules: string;
  price: number;
};

export default function RamInputScreen() {
  const router = useRouter();
  const { theme } = useTheme();

  const progress = useSharedValue(theme ? 1 : 0);
  useEffect(() => {
    progress.value = withTiming(theme ? 1 : 0, { duration: 400 });
  }, [theme]);

  const bgAnim = useAnimatedStyle(() => ({ backgroundColor: theme.background }));
  const textColorAnim = (color: string) => useAnimatedStyle(() => ({ color }));

  const [mobos, setMobos] = useState<Motherboard[]>([]);
  const [filteredMobos, setFilteredMobos] = useState<Motherboard[]>([]);
  const [selectedMobo, setSelectedMobo] = useState<Motherboard | null>(null);
  const [searchMobo, setSearchMobo] = useState("");

  const [budget, setBudget] = useState("");
  const [loading, setLoading] = useState(true);
  const [fetchingRecommendations, setFetchingRecommendations] = useState(false);

  useEffect(() => {
    fetch("http://10.102.232.54:5000/api/hardware/motherboard")
      .then(res => res.json())
      .then(data => {
        setMobos(data);
        setFilteredMobos(data);
      })
      .catch(err => {
        console.error("❌ Error fetching motherboards:", err);
        Alert.alert("Error", "Unable to load motherboard data.");
      })
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    const txt = searchMobo.trim().toLowerCase();
    setFilteredMobos(!txt ? mobos : mobos.filter(mb => mb.name.toLowerCase().includes(txt)));
  }, [searchMobo, mobos]);

  const fetchRecommendations = async () => {
    if (!selectedMobo) return Alert.alert("Select Motherboard", "Please choose a motherboard first.");
    if (!budget || isNaN(Number(budget)) || Number(budget) <= 0) return Alert.alert("Invalid Budget", "Please enter a valid budget.");

    setFetchingRecommendations(true);
    try {
      const response = await fetch("http://10.102.232.54:5000/api/recommend/ram", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ moboId: selectedMobo.id, budget: Number(budget), strict: false }),
      });
      const data = await response.json();
      if (!response.ok) return Alert.alert("Error", data.error || "Failed to fetch recommendations");

      router.push({
        pathname: "/(screens)/Ram/RamRecommendationScreen",
        params: { recommendations: JSON.stringify(data.recommendations) },
      });
    } catch (err) {
      console.error("❌ Network error:", err);
      Alert.alert("Error", "Unable to connect to server");
    } finally {
      setFetchingRecommendations(false);
    }
  };

  const renderMoboCard = (item: Motherboard) => (
    <Pressable
      style={[
        styles.moboCard,
        { backgroundColor: theme.card },
        selectedMobo?.id === item.id && { borderColor: theme.accent, backgroundColor: theme.accent + "22", shadowColor: theme.accent },
      ]}
      onPress={() => setSelectedMobo(item)}
    >
      <Text style={[styles.moboTitle, { color: theme.textPrimary }]}>{item.name}</Text>
      <Text style={[styles.moboSubtitle, { color: theme.textSecondary }]}>RAM Type: {item.ram_type}</Text>
    </Pressable>
  );

  return (
    <Animated.View style={[styles.container, bgAnim]}>
      <Animated.Text style={[styles.header, textColorAnim(theme.textSecondary)]}>RAM Compatibility Check</Animated.Text>

      {loading ? (
        <ActivityIndicator size="large" color={theme.accent} />
      ) : (
        <>
          {/* Motherboard Section */}
          <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Select Motherboard</Text>
          <View style={styles.searchWrapper}>
            <Ionicons name="search" size={20} color={theme.textSecondary} style={{ marginRight: 8 }} />
            <TextInput
              style={[styles.searchInput, { backgroundColor: theme.card, color: theme.textPrimary }]}
              placeholder="Search motherboard..."
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

          <Text style={[styles.sectionTitle, { color: theme.textPrimary }]}>Enter Budget</Text>
          <TextInput
            style={[styles.input, { backgroundColor: theme.card, color: theme.textPrimary, borderColor: theme.accent }]}
            placeholder="₹ (e.g. 30000)"
            placeholderTextColor={theme.textSecondary}
            value={budget}
            onChangeText={setBudget}
            keyboardType="numeric"
          />

          <View style={styles.navRow}>
            <Pressable
              style={[styles.navButton, { backgroundColor: theme.accent }]}
              onPress={fetchRecommendations}
              disabled={fetchingRecommendations}
            >
              <Text style={{ color: theme.accentText, fontWeight: "600" }}>
                {fetchingRecommendations ? "Fetching Recommendations..." : "Find Compatible RAM"}
              </Text>
            </Pressable>
          </View>
        </>
      )}
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, paddingTop: 50 },
  header: { fontSize: 20, fontWeight: "600", marginBottom: 15 },
  sectionTitle: { fontSize: 18, fontWeight: "500", marginVertical: 10 },
  searchWrapper: { flexDirection: "row", alignItems: "center", borderRadius: 8, marginBottom: 10, paddingHorizontal: 10 },
  searchInput: { flex: 1, padding: 10, borderRadius: 8 },
  input: { borderWidth: 1, padding: 12, borderRadius: 8, marginVertical: 10 },
  moboCard: { padding: 16, marginVertical: 6, borderRadius: 12, borderWidth: 2, borderColor: "transparent", shadowOpacity: 0.05, shadowRadius: 4, elevation: 2 },
  moboTitle: { fontSize: 16, fontWeight: "600" },
  moboSubtitle: { fontSize: 14, marginTop: 4 },
  navRow: { flexDirection: "row", justifyContent: "center", marginVertical: 20 },
  navButton: { paddingVertical: 14, paddingHorizontal: 20, borderRadius: 8, elevation: 2 },
});
