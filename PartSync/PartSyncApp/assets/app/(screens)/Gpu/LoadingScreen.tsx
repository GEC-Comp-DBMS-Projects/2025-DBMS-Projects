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
import Animated, {
    FadeIn,
    FadeOut,
    Layout,
} from "react-native-reanimated";
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
  "💡 Tip: A balanced PSU ensures long GPU life.",
  "🔧 Did you know? PCIe 4.0 GPUs can run on PCIe 3.0 slots.",
  "⚡ TDP ≠ power draw, but it’s close enough for compatibility.",
  "🧠 Bottlenecks happen when CPU can't keep up with GPU.",
];

export default function LoadingScreen() {
  const { isDark } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;

  const router = useRouter();
  const { cpuId, psuId, moboId, budget, strictBudget } = useLocalSearchParams();
  const [tipIndex, setTipIndex] = useState(0);

  useEffect(() => {
    const tipInterval = setInterval(() => {
      setTipIndex((prev) => (prev + 1) % tips.length);
    }, 3000);

    const fetchRecommendation = async () => {
      try {
        const response = await fetch(
          "http://10.102.232.54:5000/api/recommend/gpu",
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              cpuId: Number(cpuId),
              psuId: Number(psuId),
              moboId: Number(moboId),
              budget: Number(budget),
              strictBudget: strictBudget === "true",
            }),
          }
        );

        const data = await response.json();
        if (!response.ok) {
          Alert.alert("Error", data.error || "Failed to fetch recommendations");
          router.back();
          return;
        }

        await new Promise((resolve) => setTimeout(resolve, 3500));

        router.replace({
          pathname: "/(screens)/Gpu/RecommendationScreen",
          params: { recommendations: JSON.stringify(data.recommendations) },
        });
      } catch (err) {
        console.error("Network error:", err);
        Alert.alert("Error", "Unable to connect to server");
        router.back();
      }
    };

    fetchRecommendation();
    return () => clearInterval(tipInterval);
  }, []);

  return (
    <View style={[styles.container, { backgroundColor: theme.background }]}>
      <View style={[styles.card, { backgroundColor: theme.cardBackground, shadowColor: isDark ? "#000" : "#aaa" }]}>
        <View style={styles.lottieContainer}>
          <LottieComponent
            source={require("../../../assets/animations/processing-chip.json")}
            autoPlay
            loop
            style={styles.lottie}
          />
        </View>
        <Text style={[styles.title, { color: theme.textPrimary }]}>
          Analyzing your build...
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
    fontSize: 22,
    fontWeight: "bold",
    textAlign: "center",
  },
  tip: {
    fontSize: 15,
    marginTop: 12,
    textAlign: "center",
    width: "90%",
  },
});
