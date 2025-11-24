import React, { useState } from "react";
import {
  View,
  TouchableOpacity,
  Text,
  StyleSheet,
  Animated,
  Easing,
  Modal,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import { MotiView, MotiText } from "moti";
import { useRouter } from "expo-router";
import AsyncStorage from "@react-native-async-storage/async-storage";
import Announcements from "./ac";
import Menu from "./m";
import Feedback from "./f";
import Attendance from "./at";
import InviteStudent from "./in";

type Section = "Announcements" | "Menu" | "Feedback" | "Attendance" | "Invite";

// ✅ Logout Confirmation Modal
function LogoutModal({ visible, onConfirm, onCancel }: any) {
  return (
    <Modal transparent visible={visible} animationType="fade">
      <View style={styles.modalOverlay}>
        <MotiView
          from={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ type: "timing", duration: 300 }}
          style={styles.logoutModalCard}
        >
          <Ionicons name="log-out-outline" size={56} color="#FF4500" style={{ marginBottom: 10 }} />
          <MotiText style={styles.logoutModalTitle}>Logout</MotiText>
          <Text style={styles.logoutModalMessage}>
            Are you sure you want to logout?
          </Text>
          <View style={styles.logoutModalButtons}>
            <TouchableOpacity onPress={onCancel} style={styles.cancelButton}>
              <Text style={styles.cancelButtonText}>Cancel</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={onConfirm} style={{ flex: 1 }}>
              <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.confirmButton}>
                <Text style={styles.confirmButtonText}>Logout</Text>
              </LinearGradient>
            </TouchableOpacity>
          </View>
        </MotiView>
      </View>
    </Modal>
  );
}

const AdminDashboard: React.FC = () => {
  const router = useRouter();
  const [activeSection, setActiveSection] = useState<Section>("Announcements");
  const [menuVisible, setMenuVisible] = useState(false);
  const [logoutModalVisible, setLogoutModalVisible] = useState(false);
  const slideAnim = useState(new Animated.Value(-280))[0];

  const toggleMenu = () => {
    Animated.timing(slideAnim, {
      toValue: menuVisible ? -280 : 0,
      duration: 300,
      easing: Easing.bezier(0.25, 0.1, 0.25, 1),
      useNativeDriver: false,
    }).start();
    setMenuVisible(!menuVisible);
  };

  // -------------------
  // Logout Handler
  // -------------------
  const handleLogout = async () => {
    try {
      // Clear all stored authentication data
      await AsyncStorage.removeItem("token");
      await AsyncStorage.removeItem("user");

      // Navigate to ChoiceScreen
      router.replace("/ChoiceScreen");
    } catch (error) {
      console.error("Error during logout:", error);
    }
  };

  const renderSection = () => {
    switch (activeSection) {
      case "Announcements":
        return <Announcements />;
      case "Menu":
        return <Menu />;
      case "Feedback":
        return <Feedback />;
      case "Attendance":
        return <Attendance />;
      case "Invite":
        return <InviteStudent />;
      default:
        return null;
    }
  };

  const handleSelect = (section: Section) => {
    setActiveSection(section);
    toggleMenu();
  };

  const menuItems: { section: Section; icon: any; label: string; color: string }[] = [
    { section: "Announcements", icon: "megaphone", label: "Announcements", color: "#FF7E5F" },
    { section: "Menu", icon: "restaurant", label: "Menu Management", color: "#FFB347" },
    { section: "Feedback", icon: "chatbubbles", label: "Feedback", color: "#6B5B95" },
    { section: "Attendance", icon: "people", label: "Attendance", color: "#34C759" },
    { section: "Invite", icon: "person-add", label: "Invite Student", color: "#FF4500" },
  ];

  return (
    <LinearGradient
      colors={["#FFF3E2", "#FFD1BA"]}
      style={styles.gradient}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
    >
      <SafeAreaView style={styles.safeArea}>
        {/* Top Bar */}
        <View style={styles.topBar}>
          <TouchableOpacity onPress={toggleMenu} style={styles.hamburger}>
            <Ionicons name={menuVisible ? "close" : "menu"} size={28} color="#FF4500" />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>{activeSection}</Text>
          <View style={styles.placeholder} />
        </View>

        {/* Content */}
        <View style={styles.content}>{renderSection()}</View>

        {/* Enhanced Side Menu */}
        <Animated.View style={[styles.sideMenu, { left: slideAnim }]}>
          {/* Header Section */}
          <LinearGradient colors={["#FF7E5F", "#FF4500"]} style={styles.menuHeader}>
            <Ionicons name="shield-checkmark" size={40} color="#fff" />
            <Text style={styles.menuHeaderTitle}>Admin Panel</Text>
            <Text style={styles.menuHeaderSubtitle}>MessMate Dashboard</Text>
          </LinearGradient>

          {/* Menu Items */}
          <View style={styles.menuItemsContainer}>
            {menuItems.map((item, index) => (
              <MotiView
                key={item.section}
                from={{ opacity: 0, translateX: -20 }}
                animate={{ opacity: 1, translateX: 0 }}
                transition={{ type: "timing", duration: 300, delay: menuVisible ? index * 50 : 0 }}
              >
                <TouchableOpacity
                  onPress={() => handleSelect(item.section)}
                  style={[
                    styles.menuItem,
                    activeSection === item.section && styles.activeMenuItem,
                  ]}
                >
                  <View
                    style={[
                      styles.iconCircle,
                      activeSection === item.section && { backgroundColor: item.color },
                    ]}
                  >
                    <Ionicons
                      name={item.icon}
                      size={22}
                      color={activeSection === item.section ? "#fff" : item.color}
                    />
                  </View>
                  <Text
                    style={[
                      styles.menuItemText,
                      activeSection === item.section && styles.activeMenuItemText,
                    ]}
                  >
                    {item.label}
                  </Text>
                  {activeSection === item.section && (
                    <Ionicons name="chevron-forward" size={18} color="#FF4500" />
                  )}
                </TouchableOpacity>
              </MotiView>
            ))}
          </View>

          {/* Footer */}
          <View style={styles.menuFooter}>
            <TouchableOpacity 
              style={styles.logoutButton}
              onPress={() => setLogoutModalVisible(true)}
            >
              <Ionicons name="log-out-outline" size={20} color="#FF4500" />
              <Text style={styles.logoutText}>Logout</Text>
            </TouchableOpacity>
            <Text style={styles.versionText}>Version 1.0.0</Text>
          </View>
        </Animated.View>

        {/* Backdrop */}
        {menuVisible && (
          <TouchableOpacity
            style={styles.backdrop}
            onPress={toggleMenu}
            activeOpacity={1}
          />
        )}

        {/* Logout Confirmation Modal */}
        <LogoutModal
          visible={logoutModalVisible}
          onConfirm={async () => {
            setLogoutModalVisible(false);
            await handleLogout();
          }}
          onCancel={() => setLogoutModalVisible(false)}
        />
      </SafeAreaView>
    </LinearGradient>
  );
};

export default AdminDashboard;

// -------------------
// Styles
// -------------------
const styles = StyleSheet.create({
  gradient: { flex: 1 },
  safeArea: { flex: 1 },
  topBar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 15,
    paddingVertical: 14,
    backgroundColor: "rgba(255,255,255,0.95)",
    elevation: 4,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  hamburger: { 
    width: 40, 
    height: 40, 
    justifyContent: "center", 
    alignItems: "center",
    borderRadius: 10,
    backgroundColor: "rgba(255,69,0,0.1)",
  },
  headerTitle: { 
    fontSize: 20, 
    fontWeight: "700", 
    color: "#FF4500",
    flex: 1,
    textAlign: "center",
  },
  placeholder: { width: 40 },
  content: { flex: 1, padding: 15 },
  
  sideMenu: {
    position: "absolute",
    top: 0,
    bottom: 0,
    width: 280,
    backgroundColor: "#fff",
    zIndex: 10,
    elevation: 20,
    shadowColor: "#000",
    shadowOpacity: 0.3,
    shadowOffset: { width: 5, height: 0 },
    shadowRadius: 15,
  },
  
  menuHeader: {
    paddingTop: 50,
    paddingBottom: 25,
    paddingHorizontal: 20,
    alignItems: "center",
  },
  menuHeaderTitle: {
    fontSize: 22,
    fontWeight: "700",
    color: "#fff",
    marginTop: 12,
  },
  menuHeaderSubtitle: {
    fontSize: 13,
    color: "rgba(255,255,255,0.85)",
    marginTop: 4,
  },
  
  menuItemsContainer: { flex: 1, paddingVertical: 10 },
  menuItem: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 14,
    paddingHorizontal: 20,
    marginHorizontal: 10,
    marginVertical: 4,
    borderRadius: 12,
    backgroundColor: "transparent",
  },
  activeMenuItem: {
    backgroundColor: "rgba(255,69,0,0.08)",
    borderLeftWidth: 3,
    borderLeftColor: "#FF4500",
  },
  iconCircle: {
    width: 38,
    height: 38,
    borderRadius: 19,
    backgroundColor: "rgba(255,126,95,0.12)",
    justifyContent: "center",
    alignItems: "center",
    marginRight: 14,
  },
  menuItemText: { fontSize: 15, color: "#555", fontWeight: "500", flex: 1 },
  activeMenuItemText: { color: "#FF4500", fontWeight: "700" },
  menuFooter: {
    borderTopWidth: 1,
    borderTopColor: "#eee",
    paddingVertical: 15,
    paddingHorizontal: 20,
    alignItems: "center",
  },
  logoutButton: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: "#FF4500",
    marginBottom: 10,
  },
  logoutText: { fontSize: 15, fontWeight: "600", color: "#FF4500" },
  versionText: { fontSize: 11, color: "#999", marginTop: 5 },
  backdrop: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: "rgba(0,0,0,0.4)",
    zIndex: 5,
  },
  modalOverlay: { flex: 1, justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.35)" },
  logoutModalCard: { width: "80%", backgroundColor: "#fff", borderRadius: 18, padding: 20, alignItems: "center", shadowColor: "#000", shadowOpacity: 0.25, shadowOffset: { width: 0, height: 2 }, shadowRadius: 8, elevation: 10 },
  logoutModalTitle: { fontSize: 18, fontWeight: "700", color: "#333", marginBottom: 6 },
  logoutModalMessage: { fontSize: 14, color: "#666", textAlign: "center", marginBottom: 20 },
  logoutModalButtons: { flexDirection: "row", width: "100%", gap: 10 },
  cancelButton: { flex: 1, padding: 12, borderRadius: 10, alignItems: "center", borderWidth: 1, borderColor: "#ddd" },
  cancelButtonText: { color: "#666", fontWeight: "600", fontSize: 16 },
  confirmButton: { padding: 12, borderRadius: 10, alignItems: "center" },
  confirmButtonText: { color: "#fff", fontWeight: "bold", fontSize: 16 },
});
