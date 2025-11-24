import { useLocalSearchParams, useRouter } from "expo-router";
import React, { useEffect, useState } from "react";
import {
    ActivityIndicator,
    Alert,
    Dimensions,
    Platform,
    StyleSheet,
    Text,
    View,
} from "react-native";
import Animated, { FadeIn, FadeOut, Layout } from "react-native-reanimated";
import { useTheme } from "../../context/themeContext";
import { darkTheme, lightTheme } from "../../theme";

let LottieComponent: any;
if (Platform.OS === "web") {
  LottieComponent = require("lottie-react").default;
} else {
  LottieComponent = require("lottie-react-native").default;
}

const { width } = Dimensions.get("window");

const tips = [
  "💡 NVMe SSDs are up to 6x faster than SATA SSDs.",
  "🔧 HDDs are great for bulk storage but slower than SSDs.",
  "⚡ Your motherboard must support M.2 NVMe slots for NVMe SSDs.",
  "🧠 More storage space means less time worrying about deleting games.",
];

export default function StorageLoadingScreen() {
  const { isDark } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;

  const router = useRouter();
  const { moboId, storageType, capacity, budget, useCase } =
    useLocalSearchParams();
  const [tipIndex, setTipIndex] = useState(0);

  useEffect(() => {
    const tipInterval = setInterval(() => {
      setTipIndex((prev) => (prev + 1) % tips.length);
    }, 3000);

    const fetchRecommendation = async () => {
      try {
        console.log("📤 Sending to backend (storage):", {
          moboId: Number(moboId),
          storageType,
          capacity: Number(capacity),
          budget: budget ? Number(budget) : null,
          useCase,
        });

        const response = await fetch(
          "URL_Backend/api/recommend/storage",
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              moboId: Number(moboId),
              storageType,
              capacity: Number(capacity),
              budget: budget ? Number(budget) : null,
              useCase,
            }),
          }
        );

        const data = await response.json();
        if (!response.ok) {
          Alert.alert(
            "Error",
            data.error || "Failed to fetch storage recommendations"
          );
          router.back();
          return;
        }

        await new Promise((resolve) => setTimeout(resolve, 2000));

        router.replace({
          pathname: "/(screens)/Storage/StorageRecommendationScreen",
          params: { recommendations: JSON.stringify(data.recommendations) },
        });
      } catch (err) {
        console.error("❌ Network error:", err);
        Alert.alert("Error", "Unable to connect to server");
        router.back();
      }
    };

    fetchRecommendation();

    return () => clearInterval(tipInterval);
  }, [moboId, storageType, capacity, budget, useCase, router]);

  return (
    <View style={[styles.container, { backgroundColor: theme.background }]}>
      <View
        style={[
          styles.card,
          { backgroundColor: theme.cardBackground, shadowColor: isDark ? "#000" : "#aaa" },
        ]}
      >
        <View style={styles.lottieContainer}>
          <LottieComponent
            source={require("../../../assets/animations/processing-chip.json")}
            autoPlay
            loop
            style={styles.lottie}
          />
        </View>

        <Text style={[styles.title, { color: theme.textPrimary }]}>
          Finding the best storage for your build...
        </Text>

        <Animated.Text
          key={tipIndex}
          layout={Layout.springify()}
          entering={FadeIn.duration(400)}
          exiting={FadeOut.duration(400)}
          style={[styles.tip, { color: theme.textSecondary }]}
        >
          {tips[tipIndex]}
        </Animated.Text>

        <ActivityIndicator
          size="large"
          color={theme.accent}
          style={{ marginTop: 24 }}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    paddingHorizontal: 20,
  },
  card: {
    width: width * 0.85,
    padding: 28,
    borderRadius: 24,
    alignItems: "center",
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.3,
    shadowRadius: 12,
    elevation: 8,
  },
  lottieContainer: {
    width: 160,
    height: 160,
    borderRadius: 100,
    overflow: "hidden",
    justifyContent: "center",
    alignItems: "center",
    marginBottom: 20,
    backgroundColor: "#f0f0f0",
  },
  lottie: {
    width: 140,
    height: 140,
  },
  title: {
    fontSize: 20,
    fontWeight: "bold",
    textAlign: "center",
  },
  tip: {
    fontSize: 14,
    marginTop: 12,
    textAlign: "center",
    width: "90%",
  },
});
