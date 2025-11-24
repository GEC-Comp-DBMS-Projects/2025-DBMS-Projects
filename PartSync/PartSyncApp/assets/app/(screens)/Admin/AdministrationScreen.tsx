import { Ionicons } from "@expo/vector-icons";
import { useRouter } from "expo-router";
import * as SecureStore from "expo-secure-store";
import React, { useEffect, useState } from "react";
import { Dimensions, StyleSheet, Text, TouchableOpacity, View } from "react-native";
import Animated, { useAnimatedStyle, useSharedValue, withTiming } from "react-native-reanimated";
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
  const { isDark } = useTheme();
  const theme = isDark ? darkTheme : lightTheme;

  const [menuOpen, setMenuOpen] = useState(false);
  const [hardwareMenuOpen, setHardwareMenuOpen] = useState(false);
  const [selectedScreen, setSelectedScreen] = useState("dashboard");

  const sidebarX = useSharedValue(-SCREEN_WIDTH);

  useEffect(() => {
    sidebarX.value = withTiming(menuOpen ? 0 : -SCREEN_WIDTH, { duration: 250 });
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

  const styles = createStyles(theme);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.topBar}>
        <TouchableOpacity onPress={() => setMenuOpen(!menuOpen)}>
          <Ionicons name="menu" size={28} color={theme.textPrimary} />
        </TouchableOpacity>
        <Text style={styles.title}>Admin Panel</Text>
      </View>

      <Animated.View style={[styles.sidebar, sidebarStyle]}>
        <TouchableOpacity onPress={() => selectScreen("dashboard")}>
          <Text
            style={[
              styles.menuItem,
              selectedScreen === "dashboard" && styles.menuItemActive(theme),
            ]}
          >
            🏠 Dashboard
          </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => setHardwareMenuOpen(!hardwareMenuOpen)}>
          <Text style={styles.menuItem}>
            ⚙️ Hardware {hardwareMenuOpen ? "▾" : "▸"}
          </Text>
        </TouchableOpacity>

        {hardwareMenuOpen && (
          <TouchableOpacity onPress={() => selectScreen("hardware")}>
            <Text
              style={[
                styles.subMenuItem,
                selectedScreen === "hardware" && styles.menuItemActive(theme),
              ]}
            >
              • Manage Hardware
            </Text>
          </TouchableOpacity>
        )}

        <TouchableOpacity onPress={() => selectScreen("addAdmin")}>
          <Text
            style={[
              styles.menuItem,
              selectedScreen === "addAdmin" && styles.menuItemActive(theme),
            ]}
          >
            👤 Add Admin
          </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => selectScreen("auditLogs")}>
          <Text
            style={[
              styles.menuItem,
              selectedScreen === "auditLogs" && styles.menuItemActive(theme),
            ]}
          >
            📜 Audit Logs
          </Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={handleLogout}>
          <Text style={[styles.menuItem, { color: theme.error }]}>🚪 Logout</Text>
        </TouchableOpacity>
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

const createStyles = (theme: typeof lightTheme | typeof darkTheme) =>
  StyleSheet.create({
    container: { flex: 1, backgroundColor: theme.background },
    topBar: {
      flexDirection: "row",
      alignItems: "center",
      padding: 12,
      borderBottomWidth: 1,
      borderBottomColor: theme.border,
    },
    title: {
      fontSize: 22,
      fontWeight: "bold",
      color: theme.primary,
      marginLeft: 10,
    },
    sidebar: {
      position: "absolute",
      top: 0,
      left: 0,
      width: 220,
      height: "100%",
      backgroundColor: theme.cardBackground,
      padding: 12,
      zIndex: 10,
      marginTop: 90,
      elevation: 10,
      shadowColor: "#000",
      shadowOpacity: 0.3,
      shadowRadius: 10,
      shadowOffset: { width: 0, height: 4 },
    },
    menuItem: {
      fontSize: 16,
      color: theme.textPrimary,
      paddingVertical: 8,
      fontWeight: "600",
    },
    menuItemActive: (theme: typeof lightTheme | typeof darkTheme) => ({
      backgroundColor: theme.primary,
      color: "#fff",
      borderRadius: 6,
      paddingHorizontal: 6,
    }),
    subMenuItem: {
      fontSize: 14,
      color: theme.textSecondary,
      paddingVertical: 6,
      paddingLeft: 20,
    },
    content: {
      flex: 1,
      marginTop: 0,
    },
  });
