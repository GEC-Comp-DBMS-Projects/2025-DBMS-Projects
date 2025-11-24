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
import { useRouter } from "expo-router";
import { Ionicons } from "@expo/vector-icons";
import Checkbox from "expo-checkbox";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { MotiView, MotiText } from "moti";
import { SafeAreaView } from "react-native-safe-area-context";


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
          from={{ opacity: 0 }} // removed scale & bounce
          animate={{ opacity: 1 }}
          transition={{ type: "timing", duration: 300 }} // simple fade-in
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
          <MotiText
            from={{ opacity: 0, translateY: 10 }}
            animate={{ opacity: 1, translateY: 0 }}
            transition={{ delay: 150 }}
            style={styles.modalTitle}
          >
            {title}
          </MotiText>
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


export default function Login() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [remember, setRemember] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const [alertVisible, setAlertVisible] = useState(false);
  const [alertType, setAlertType] = useState("success");
  const [alertTitle, setAlertTitle] = useState("");
  const [alertMessage, setAlertMessage] = useState("");

  const showAlert = (type, title, message) => {
    setAlertType(type);
    setAlertTitle(title);
    setAlertMessage(message);
    setAlertVisible(true);
  };

  const handleLogin = async () => {
    if (!email || !password) {
      showAlert("error", "Missing Info", "Please enter email and password");
      return;
    }
    setLoading(true);
    try {
      const response = await fetch("http://10.246.134.45:5000/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });
      const data = await response.json();
      if (response.ok) {
        showAlert("success", "Welcome!", "Login successful!");
        if (data.token) {
          await AsyncStorage.setItem("token", data.token);
          await AsyncStorage.setItem("user", JSON.stringify(data.user));
        }
        setTimeout(() => router.replace("/(dashboard)"), 1500);
      } else {
        showAlert("error", "Login Failed", data.error || "Invalid credentials");
      }
    } catch (error) {
      showAlert("error", "Network Error", "Please try again later.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <LinearGradient
      colors={["#FFF3E2", "#FFD1BA"]}
      style={styles.container}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
    >
    <SafeAreaView style={styles.safeArea}>
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : "height"}
        style={{ flex: 1, width: "100%" }}
      >
        <ScrollView
          contentContainerStyle={{ flexGrow: 1, justifyContent: "center", alignItems: "center" }}
          showsVerticalScrollIndicator={false}
        >
          {/* Card */}
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

            <Text style={styles.title}>Welcome Back 👋</Text>
            <Text style={styles.subtitle}>
              Sign in to continue your MessMate journey
            </Text>

            {/* Email */}
            <View style={styles.inputWrapper}>
              <Ionicons name="mail-outline" size={18} color="#FF7E5F" />
              <TextInput
                style={styles.input}
                placeholder="Email Address"
                placeholderTextColor="#999"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
              />
            </View>

            {/* Password */}
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

            {/* Remember + Forgot */}
            <View style={styles.row}>
              <View style={styles.checkboxRow}>
                <Checkbox
                  value={remember}
                  onValueChange={setRemember}
                  color={remember ? "#FF7E5F" : undefined}
                />
                <Text style={styles.checkboxText}>Remember me</Text>
              </View>

              <TouchableOpacity>
                <Text style={styles.forgotText}>Forgot password?</Text>
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
                  {loading ? "Signing In..." : "Sign In"}
                </Text>
              </LinearGradient>
            </TouchableOpacity>

            <Text style={styles.footerText}>
              Don’t have an account?{" "}
              <Text
                style={styles.link}
                onPress={() => router.push("/(auth)/signup")}
              >
                Sign up
              </Text>
            </Text>
          </MotiView>

          <Text style={styles.footerNote}>© 2025 MessMate</Text>
        </ScrollView>
      </KeyboardAvoidingView>

      {/* ✅ Custom Alert Modal */}
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
  safeArea: {
  flex: 1,
  backgroundColor: "transparent", // 👈 allows gradient to show through
  alignItems: "center",
  },
  container: { flex: 1 },
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
  logo: {
    width: 90,
    height: 90,
    marginBottom: 15,
  },
  title: {
    fontSize: 24,
    fontWeight: "700",
    color: "#333",
    marginBottom: 4,
  },
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
  row: {
    flexDirection: "row",
    justifyContent: "space-between",
    width: "100%",
    marginBottom: 10,
  },
  checkboxRow: { flexDirection: "row", alignItems: "center" },
  checkboxText: { marginLeft: 8, fontSize: 14, color: "#333" },
  forgotText: { color: "#FF4500", fontWeight: "600", fontSize: 13 },
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
  footerText: {
    marginTop: 18,
    fontSize: 14,
    color: "#555",
  },
  link: { color: "#FF4500", fontWeight: "700" },
  footerNote: {
    marginTop: 25,
    color: "#666",
    fontSize: 13,
    fontWeight: "500",
  },
  // Alert Modal Styles
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
