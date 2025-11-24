import { useState } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Image,
  Modal,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import { MotiView, MotiText } from "moti";

// ✅ Animated Alert Modal
function AlertModal({ visible, type, title, message, onClose }) {
  const getIcon = () => {
    switch (type) {
      case "success":
        return "checkmark-circle";
      case "error":
        return "close-circle";
      default:
        return "alert-circle";
    }
  };

  return (
    <Modal transparent visible={visible} animationType="fade">
      <View style={styles.modalOverlay}>
        <MotiView
          from={{ opacity: 0, scale: 0.8 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ type: "timing", duration: 200 }}
          style={styles.modalCard}
        >
          <Ionicons
            name={getIcon()}
            size={56}
            color={
              type === "success"
                ? "#34C759"
                : type === "error"
                ? "#FF3B30"
                : "#FF9500"
            }
            style={{ marginBottom: 10 }}
          />
          <MotiText style={styles.modalTitle}>{title}</MotiText>
          <Text style={styles.modalMessage}>{message}</Text>

          <TouchableOpacity
            onPress={onClose}
            style={{ width: "100%", marginTop: 15 }}
          >
            <LinearGradient
              colors={["#FF7E5F", "#FF4500"]}
              style={styles.modalButton}
            >
              <Text style={styles.modalButtonText}>OK</Text>
            </LinearGradient>
          </TouchableOpacity>
        </MotiView>
      </View>
    </Modal>
  );
}

export default function AdminLogin() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const ADMIN_EMAIL = "admin@messmate.com";
  const ADMIN_PASSWORD = "admin123";

  const [alertVisible, setAlertVisible] = useState(false);
  const [alertType, setAlertType] = useState("error");
  const [alertTitle, setAlertTitle] = useState("");
  const [alertMessage, setAlertMessage] = useState("");

  const showAlert = (type, title, message) => {
    setAlertType(type);
    setAlertTitle(title);
    setAlertMessage(message);
    setAlertVisible(true);
  };

  const handleLogin = () => {
    if (!email || !password) {
      showAlert("error", "Missing Info", "Please enter email and password");
      return;
    }

    setLoading(true);
    setTimeout(() => {
      if (email === ADMIN_EMAIL && password === ADMIN_PASSWORD) {
        showAlert("success", "Login Successful", "Welcome, Admin!");
        setTimeout(() => {
          setAlertVisible(false);
          router.replace("/A/ad/i");
        }, 1500);
      } else {
        showAlert("error", "Login Failed", "Invalid email or password");
      }
      setLoading(false);
    }, 800);
  };

  return (
    <LinearGradient
      colors={["#FFF3E2", "#FFD1BA"]}
      style={styles.gradientBackground}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
    >
      <SafeAreaView style={styles.safeArea}>
        <KeyboardAvoidingView
          behavior={Platform.OS === "ios" ? "padding" : "height"}
          style={{ flex: 1, width: "100%" }}
        >
          <ScrollView
            contentContainerStyle={styles.scrollContainer}
            showsVerticalScrollIndicator={false}
          >
            <MotiView
              from={{ opacity: 0, translateY: 40 }}
              animate={{ opacity: 1, translateY: 0 }}
              transition={{ type: "timing", duration: 600 }}
              style={styles.card}
            >
              <Image
                source={require("@/assets/images/logo.png")}
                style={styles.logo}
                resizeMode="contain"
              />

              <Text style={styles.title}>Admin Portal 👨‍💼</Text>
              <Text style={styles.subtitle}>
                Manage your MessMate system efficiently
              </Text>

              {/* Email Input */}
              <View style={styles.inputWrapper}>
                <Ionicons name="mail-outline" size={18} color="#FF7E5F" />
                <TextInput
                  style={styles.input}
                  placeholder="Admin Email"
                  placeholderTextColor="#999"
                  value={email}
                  onChangeText={setEmail}
                  keyboardType="email-address"
                  autoCapitalize="none"
                />
              </View>

              {/* Password Input */}
              <View style={styles.inputWrapper}>
                <Ionicons name="lock-closed-outline" size={18} color="#FF7E5F" />
                <TextInput
                  style={styles.input}
                  placeholder="Password"
                  placeholderTextColor="#999"
                  secureTextEntry={!showPassword}
                  value={password}
                  onChangeText={setPassword}
                />
                <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
                  <Ionicons
                    name={showPassword ? "eye-off" : "eye"}
                    size={20}
                    color="#777"
                  />
                </TouchableOpacity>
              </View>

              {/* Login Button */}
              <TouchableOpacity
                onPress={handleLogin}
                style={{ marginTop: 15, width: "100%" }}
                disabled={loading}
              >
                <LinearGradient
                  colors={["#FF7E5F", "#FF4500"]}
                  style={styles.button}
                >
                  <Text style={styles.buttonText}>
                    {loading ? "Signing In..." : "Login"}
                  </Text>
                </LinearGradient>
              </TouchableOpacity>

              <TouchableOpacity
                style={{ marginTop: 20 }}
                onPress={() => router.back()}
              >
                <Text style={styles.link}>← Back</Text>
              </TouchableOpacity>
            </MotiView>

            <Text style={styles.footerNote}>© 2025 MessMate Admin</Text>
          </ScrollView>
        </KeyboardAvoidingView>

        {/* ✅ Alert Modal */}
        <AlertModal
          visible={alertVisible}
          type={alertType}
          title={alertTitle}
          message={alertMessage}
          onClose={() => setAlertVisible(false)}
        />
      </SafeAreaView>
    </LinearGradient>
  );
}

const styles = StyleSheet.create({
  gradientBackground: { flex: 1 },
  safeArea: { flex: 1 },
  scrollContainer: {
    flexGrow: 1,
    justifyContent: "center",
    alignItems: "center",
  },
  card: {
    width: "90%",
    backgroundColor: "rgba(255,255,255,0.95)",
    borderRadius: 18,
    padding: 25,
    shadowColor: "#000",
    shadowOpacity: 0.15,
    shadowOffset: { width: 0, height: 5 },
    shadowRadius: 12,
    elevation: 8,
    alignItems: "center",
  },
  logo: { width: 90, height: 90, marginBottom: 15 },
  title: { fontSize: 24, fontWeight: "700", color: "#333", marginBottom: 4 },
  subtitle: {
    fontSize: 14,
    color: "#666",
    textAlign: "center",
    marginBottom: 25,
  },
  inputWrapper: {
    flexDirection: "row",
    alignItems: "center",
    borderWidth: 1,
    borderColor: "#ddd",
    borderRadius: 10,
    paddingHorizontal: 12,
    marginBottom: 15,
    width: "100%",
    backgroundColor: "#fff",
  },
  input: {
    flex: 1,
    paddingVertical: 10,
    paddingHorizontal: 8,
    fontSize: 14,
    color: "#333",
  },
  button: {
    width: "100%",
    paddingVertical: 15,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
    shadowColor: "#FF4500",
    shadowOpacity: 0.4,
    shadowRadius: 10,
  },
  buttonText: { color: "#fff", fontSize: 16, fontWeight: "600" },
  link: { color: "#FF4500", fontWeight: "700", fontSize: 14 },
  footerNote: {
    marginTop: 25,
    color: "#666",
    fontSize: 13,
    fontWeight: "500",
  },
  modalOverlay: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "rgba(0,0,0,0.35)",
  },
  modalCard: {
    width: "80%",
    backgroundColor: "#fff",
    borderRadius: 18,
    padding: 20,
    alignItems: "center",
    shadowColor: "#000",
    shadowOpacity: 0.25,
    shadowOffset: { width: 0, height: 2 },
    shadowRadius: 8,
    elevation: 10,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: "#333",
    marginBottom: 6,
  },
  modalMessage: {
    fontSize: 14,
    color: "#666",
    textAlign: "center",
  },
  modalButton: {
    padding: 12,
    borderRadius: 10,
    alignItems: "center",
    width: "100%",
  },
  modalButtonText: { color: "#fff", fontWeight: "bold", fontSize: 16 },
});
