import { Ionicons } from "@expo/vector-icons";
import * as Haptics from "expo-haptics";
import { LinearGradient } from "expo-linear-gradient";
import { useRouter } from "expo-router";
import * as SecureStore from "expo-secure-store";
import React, { useEffect, useState } from "react";
import {
  Dimensions,
  Pressable,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from "react-native";
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from "react-native-reanimated";
import { SafeAreaView } from "react-native-safe-area-context";

import { useTheme } from "../../context/themeContext";
import { darkTheme, lightTheme } from "../../theme";

import AddAdminSection from "./components/AddAdminSection";
import AuditLogsSection from "./components/AuditLogsSection";
import DashboardSection from "./components/DashboardSection";
import HardwareSection from "./components/HardwareSection";

const SCREEN_WIDTH = Dimensions.get("window").width;

const AdministrationScreen = () => {
  const router = useRouter();
  const { isDark, toggleTheme } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;

  const [menuOpen, setMenuOpen] = useState(false);
  const [hardwareMenuOpen, setHardwareMenuOpen] = useState(false);
  const [selectedScreen, setSelectedScreen] = useState("dashboard");

  const sidebarX = useSharedValue(-SCREEN_WIDTH);

  useEffect(() => {
    sidebarX.value = withTiming(menuOpen ? 0 : -SCREEN_WIDTH, { duration: 300 });
  }, [menuOpen]);

  const sidebarStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: sidebarX.value }],
  }));

  const handleLogout = async () => {
    await SecureStore.deleteItemAsync("adminToken");
    router.replace("/(screens)/WelcomeScreen");
  };

  const selectScreen = (screen: string) => {
    setSelectedScreen(screen);
    setMenuOpen(false);
    if (screen !== "hardware") setHardwareMenuOpen(false);
  };

  const styles = createStyles(theme, isDark);

  return (
    <SafeAreaView style={styles.container}>
      <LinearGradient
        colors={
          isDark
            ? ["#1A1B25", "#10111A"]
            : ["#F5F8FF", "#E7EEFF"]
        }
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.topBar}
      >
        <TouchableOpacity onPress={() => setMenuOpen(!menuOpen)}>
          <Ionicons name="menu" size={28} color={theme.textPrimary} />
        </TouchableOpacity>

        <Text style={styles.title}>Admin Panel</Text>

        <TouchableOpacity
          onPress={() => {
            Haptics.selectionAsync();
            toggleTheme();
          }}
          style={styles.themeToggle}
        >
          <Ionicons
            name={isDark ? "moon" : "sunny"}
            size={24}
            color={isDark ? "#FFD369" : "#1C1C1E"}
          />
        </TouchableOpacity>
      </LinearGradient>

      <Animated.View style={[styles.sidebar, sidebarStyle]}>
        <Text style={styles.sidebarTitle}>Navigation</Text>

        <Pressable onPress={() => selectScreen("dashboard")}>
          <Text
            style={[
              styles.menuItem,
              selectedScreen === "dashboard" && styles.menuItemActive(theme),
            ]}
          >
            🏠 Dashboard
          </Text>
        </Pressable>

        <Pressable onPress={() => setHardwareMenuOpen(!hardwareMenuOpen)}>
          <Text style={styles.menuItem}>
            ⚙️ Hardware {hardwareMenuOpen ? "▾" : "▸"}
          </Text>
        </Pressable>

        {hardwareMenuOpen && (
          <Pressable onPress={() => selectScreen("hardware")}>
            <Text
              style={[
                styles.subMenuItem,
                selectedScreen === "hardware" && styles.menuItemActive(theme),
              ]}
            >
              • Manage Hardware
            </Text>
          </Pressable>
        )}

        <Pressable onPress={() => selectScreen("addAdmin")}>
          <Text
            style={[
              styles.menuItem,
              selectedScreen === "addAdmin" && styles.menuItemActive(theme),
            ]}
          >
            👤 Add Admin
          </Text>
        </Pressable>

        <Pressable onPress={() => selectScreen("auditLogs")}>
          <Text
            style={[
              styles.menuItem,
              selectedScreen === "auditLogs" && styles.menuItemActive(theme),
            ]}
          >
            📜 Audit Logs
          </Text>
        </Pressable>

        <View style={styles.divider} />

        <Pressable onPress={handleLogout}>
          <Text style={[styles.menuItem, { color: theme.error }]}>
            🚪 Logout
          </Text>
        </Pressable>
      </Animated.View>

      <View style={styles.content}>
        {selectedScreen === "dashboard" && <DashboardSection theme={theme} />}
        {selectedScreen === "hardware" && <HardwareSection theme={theme} />}
        {selectedScreen === "addAdmin" && <AddAdminSection theme={theme} />}
        {selectedScreen === "auditLogs" && <AuditLogsSection theme={theme} />}
      </View>
    </SafeAreaView>
  );
};

export default AdministrationScreen;

const createStyles = (theme: typeof lightTheme | typeof darkTheme, isDark: boolean) =>
  StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: theme.background,
    },
    topBar: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
      paddingVertical: 14,
      paddingHorizontal: 16,
      elevation: 4,
      shadowColor: isDark ? "#000" : "#999",
      shadowOpacity: 0.25,
      shadowRadius: 8,
    },
    title: {
      fontSize: 22,
      fontWeight: "800",
      color: theme.textPrimary,
    },
    themeToggle: {
      padding: 8,
      borderRadius: 50,
      backgroundColor: isDark ? "rgba(255,255,255,0.1)" : "rgba(0,0,0,0.05)",
    },
    sidebar: {
      position: "absolute",
      top: 0,
      left: 0,
      width: 240,
      height: "100%",
      backgroundColor: isDark ? "#161821" : "#FFFFFF",
      paddingVertical: 16,
      paddingHorizontal: 14,
      borderRightWidth: 1,
      borderRightColor: isDark ? "#2C2F3A" : "#E3E8F2",
      zIndex: 20,
      shadowColor: "#000",
      shadowOpacity: 0.25,
      shadowRadius: 10,
      shadowOffset: { width: 2, height: 3 },
      marginTop: 50.
    },
    sidebarTitle: {
      fontSize: 15,
      fontWeight: "700",
      color: isDark ? "#AEB7CC" : "#4A4A4A",
      marginBottom: 14,
      textTransform: "uppercase",
      letterSpacing: 0.7,
    },
    menuItem: {
      fontSize: 16,
      color: theme.textPrimary,
      paddingVertical: 8,
      fontWeight: "600",
      borderRadius: 8,
      paddingHorizontal: 8,
    },
    menuItemActive: (theme: typeof lightTheme | typeof darkTheme) => ({
      backgroundColor: theme.primary,
      color: "#fff",
    }),
    subMenuItem: {
      fontSize: 14,
      color: isDark ? "#C2C6D0" : "#5C6270",
      paddingVertical: 6,
      paddingLeft: 24,
    },
    divider: {
      height: 1,
      backgroundColor: isDark ? "#2A2D38" : "#E4E8F2",
      marginVertical: 10,
    },
    content: {
      flex: 1,
      padding: 12,
    },
  });
