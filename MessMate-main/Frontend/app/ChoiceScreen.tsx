import React from "react";
import {
  View,
  Text,
  TouchableOpacity,
  Image,
  StyleSheet,
  ImageSourcePropType,
} from "react-native";
import { useRouter } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import { MotiView } from "moti";
import { SafeAreaView } from "react-native-safe-area-context";

const ChoiceScreen: React.FC = () => {
  const router = useRouter();

  return (
    <LinearGradient
      colors={["#FFF3E2", "#FFD1BA"]}
      style={styles.gradientBackground}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
    >
      <SafeAreaView style={styles.safeArea}>
        <MotiView
          from={{ opacity: 0, translateY: 30 }}
          animate={{ opacity: 1, translateY: 0 }}
          transition={{ type: "timing", duration: 700 }}
          style={styles.card}
        >
          {/* 🧩 Logo */}
          <View style={styles.logoContainer}>
            <Image
              source={require("../assets/images/logo.png") as ImageSourcePropType}
              style={styles.logo}
              resizeMode="contain"
            />
          </View>

          {/* 🏷️ Titles */}
          <Text style={styles.title}>Welcome to MessMate</Text>
          <Text style={styles.subtitle}>
            Choose your login type to get started
          </Text>

          {/* 🔸 Student Login */}
          <TouchableOpacity
            onPress={() => router.push("/(auth)/login")}
            activeOpacity={0.8}
            style={{ width: "100%", marginTop: 10 }}
          >
            <LinearGradient
              colors={["#FF7E5F", "#FF4500"]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.button}
            >
              <Text style={styles.buttonText}>Student Login</Text>
            </LinearGradient>
          </TouchableOpacity>

          {/* ⚫ Admin Login */}
          <TouchableOpacity
            onPress={() => router.push("/A/al")}
            activeOpacity={0.8}
            style={{ width: "100%", marginTop: 15 }}
          >
            <LinearGradient
              colors={["#232526", "#414345"]}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.button}
            >
              <Text style={styles.buttonText}>Admin Login</Text>
            </LinearGradient>
          </TouchableOpacity>

          {/* Footer */}
          <LinearGradient
            colors={["#FF7E5F", "#FF4500"]}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={styles.footerGradient}
          >
            <Text style={styles.footerNote}>© 2025 MessMate</Text>
          </LinearGradient>
        </MotiView>
      </SafeAreaView>
    </LinearGradient>
  );
};

export default ChoiceScreen;

const styles = StyleSheet.create({
  gradientBackground: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  card: {
    width: "90%",
    backgroundColor: "rgba(255, 255, 255, 0.85)",
    borderRadius: 18,
    padding: 25,
    shadowColor: "#000",
    shadowOpacity: 0.2,
    shadowOffset: { width: 0, height: 10 },
    shadowRadius: 15,
    elevation: 10,
    alignItems: "center",
  },
  logoContainer: {
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 20,
  },
  logo: {
    width: 90,
    height: 90,
  },
  title: {
    fontSize: 24,
    fontWeight: "700",
    color: "#333",
    marginBottom: 5,
    textAlign: "center",
  },
  subtitle: {
    fontSize: 15,
    color: "#666",
    marginBottom: 25,
    textAlign: "center",
  },
  button: {
    width: "100%",
    paddingVertical: 15,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
    shadowColor: "#000",
    shadowOpacity: 0.15,
    shadowOffset: { width: 0, height: 3 },
    shadowRadius: 6,
  },
  buttonText: {
    color: "white",
    fontSize: 17,
    fontWeight: "600",
    letterSpacing: 0.5,
  },
  footerGradient: {
    marginTop: 25,
    paddingVertical: 6,
    paddingHorizontal: 20,
    borderRadius: 20,
  },
  footerNote: {
    color: "white",
    fontSize: 13,
    fontWeight: "600",
  },
});
