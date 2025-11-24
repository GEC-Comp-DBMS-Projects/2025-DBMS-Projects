import React, { useState, useRef, useEffect } from "react";
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Image,
  Modal,
  KeyboardAvoidingView,
  ScrollView,
  Platform,
  ActivityIndicator,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import { useRouter } from "expo-router";
import Checkbox from "expo-checkbox";
import axios from "axios";
import { MotiView, MotiText } from "moti";
import { SafeAreaView } from "react-native-safe-area-context";

// ✅ Alert Modal without bouncing
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
          from={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 200 }}
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

export default function SignupScreen() {
  const router = useRouter();

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState(["", "", "", ""]);
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [agreeTerms, setAgreeTerms] = useState(false);

  const [isEmailVerified, setIsEmailVerified] = useState(false);
  const [isOtpVerified, setIsOtpVerified] = useState(false);

  const [alertVisible, setAlertVisible] = useState(false);
  const [alertType, setAlertType] = useState("success");
  const [alertTitle, setAlertTitle] = useState("");
  const [alertMessage, setAlertMessage] = useState("");

  const [timer, setTimer] = useState(0);
  const [verifyingEmail, setVerifyingEmail] = useState(false);
  const [verifyingOtp, setVerifyingOtp] = useState(false);

  const timerRef = useRef(null);
  const otpInputs = useRef([]);
  const API_URL = "http://10.246.134.45:5000";

  const showAlert = (type, title, message) => {
    setAlertType(type);
    setAlertTitle(title);
    setAlertMessage(message);
    setAlertVisible(true);
  };

  const startTimer = () => {
    if (timerRef.current) clearInterval(timerRef.current);
    setTimer(60);
    timerRef.current = setInterval(() => {
      setTimer((prev) => {
        if (prev <= 1) {
          clearInterval(timerRef.current);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  };

  const handleVerifyEmail = async () => {
    if (!email) return showAlert("error", "Error", "Enter your email first.");
    setVerifyingEmail(true);
    try {
      const res = await axios.post(`${API_URL}/verifyEmail`, { email });
      setIsEmailVerified(true);
      startTimer();
      showAlert("success", "OTP Sent", res.data.message);
    } catch (err) {
      showAlert(
        "error",
        "Error",
        err.response?.data?.error || "Something went wrong"
      );
    } finally {
      setVerifyingEmail(false);
    }
  };

  const handleVerifyOtp = async () => {
    const otpCode = otp.join("");
    if (otpCode.length !== 4)
      return showAlert("error", "Error", "Enter all 4 digits");
    setVerifyingOtp(true);
    try {
      const res = await axios.post(`${API_URL}/verifyOtp`, { email, otp: otpCode });
      setIsOtpVerified(true);
      clearInterval(timerRef.current);
      showAlert("success", "Verified", res.data.message);
    } catch (err) {
      showAlert("error", "Error", err.response?.data?.error || "Invalid OTP");
    } finally {
      setVerifyingOtp(false);
    }
  };

  const handleOtpChange = (text, index) => {
    const newOtp = [...otp];
    newOtp[index] = text.slice(-1);
    setOtp(newOtp);
    if (text && index < 3) otpInputs.current[index + 1].focus();
  };

  const handleSignup = async () => {
    if (!agreeTerms)
      return showAlert("error", "Error", "You must agree to the Terms.");
    if (password !== confirmPassword)
      return showAlert("error", "Error", "Passwords do not match!");
    try {
      const res = await axios.post(`${API_URL}/signup`, {
        full_name: fullName,
        email,
        password,
      });
      showAlert("success", "Success", res.data.message);
      setTimeout(() => router.push("/(auth)/login"), 1500);
    } catch (err) {
      showAlert("error", "Error", err.response?.data?.error || "Signup failed");
    }
  };

  useEffect(() => () => timerRef.current && clearInterval(timerRef.current), []);

  return (
    <LinearGradient
      colors={["#FFF3E2", "#FFD1BA"]}
      style={styles.container}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
    >
      <SafeAreaView style={{ flex: 1, backgroundColor: "transparent" }}>

      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : "height"}
        style={{ flex: 1, width: "100%" }}
      >
        <ScrollView
          contentContainerStyle={{
            flexGrow: 1,
            justifyContent: "center",
            alignItems: "center",
          }}
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
            />
            <Text style={styles.title}>Create Account</Text>
            <Text style={styles.subtitle}>
              Join our hostel mess management system
            </Text>

            {/* Full Name */}
            <View style={styles.inputWrapper}>
              <Ionicons name="person-outline" size={18} color="#FF7E5F" />
              <TextInput
                style={styles.input}
                placeholder="Full Name"
                value={fullName}
                onChangeText={setFullName}
              />
            </View>

            {/* Email */}
            <View style={styles.inputWrapper}>
              <Ionicons name="mail-outline" size={18} color="#FF7E5F" />
              <TextInput
                style={[styles.input, isEmailVerified && { color: "#999" }]}
                placeholder="Email Address"
                value={email}
                onChangeText={setEmail}
                editable={!isEmailVerified}
                keyboardType="email-address"
              />
              {!isEmailVerified && (
                <TouchableOpacity
                  onPress={handleVerifyEmail}
                  style={{
                    marginLeft: 8,
                    paddingVertical: 6,
                    paddingHorizontal: 12,
                    backgroundColor: "#FF4500",
                    borderRadius: 6,
                    flexDirection: "row",
                    alignItems: "center",
                  }}
                  disabled={verifyingEmail}
                >
                  {verifyingEmail ? (
                    <ActivityIndicator size="small" color="#fff" />
                  ) : (
                    <Text
                      style={{
                        color: "#fff",
                        fontWeight: "600",
                        fontSize: 13,
                      }}
                    >
                      Verify
                    </Text>
                  )}
                </TouchableOpacity>
              )}
            </View>

            {/* OTP Section */}
            {isEmailVerified && !isOtpVerified && (
              <>
                <View style={styles.otpRow}>
                  {otp.map((d, i) => (
                    <TextInput
                      key={i}
                      ref={(ref) => (otpInputs.current[i] = ref)}
                      style={styles.otpInput}
                      keyboardType="number-pad"
                      maxLength={1}
                      value={d}
                      onChangeText={(text) => handleOtpChange(text, i)}
                    />
                  ))}
                  <TouchableOpacity
                    onPress={handleVerifyOtp}
                    style={{
                      marginLeft: 8,
                      paddingVertical: 6,
                      paddingHorizontal: 12,
                      backgroundColor: "#FF4500",
                      borderRadius: 6,
                      flexDirection: "row",
                      alignItems: "center",
                    }}
                    disabled={verifyingOtp}
                  >
                    {verifyingOtp ? (
                      <ActivityIndicator size="small" color="#fff" />
                    ) : (
                      <Text style={{ color: "#fff", fontWeight: "600", fontSize: 13 }}>
                        Submit
                      </Text>
                    )}
                  </TouchableOpacity>
                </View>
                <View style={{ alignItems: "center", marginBottom: 10 }}>
                  {timer > 0 ? (
                    <Text style={styles.timerText}>Resend in {timer}s</Text>
                  ) : (
                    <TouchableOpacity onPress={handleVerifyEmail}>
                      <Text style={styles.resendText}>Resend OTP</Text>
                    </TouchableOpacity>
                  )}
                </View>
              </>
            )}

            {/* Passwords */}
            {isOtpVerified && (
              <>
                <View style={styles.inputWrapper}>
                  <Ionicons
                    name="lock-closed-outline"
                    size={18}
                    color="#FF7E5F"
                  />
                  <TextInput
                    style={styles.input}
                    placeholder="Create Password"
                    secureTextEntry={!showPassword}
                    value={password}
                    onChangeText={setPassword}
                  />
                  <TouchableOpacity
                    onPress={() => setShowPassword(!showPassword)}
                  >
                    <Ionicons
                      name={showPassword ? "eye-off" : "eye"}
                      size={20}
                      color="#777"
                    />
                  </TouchableOpacity>
                </View>

                <View style={styles.inputWrapper}>
                  <Ionicons
                    name="checkmark-done-outline"
                    size={18}
                    color="#FF7E5F"
                  />
                  <TextInput
                    style={styles.input}
                    placeholder="Confirm Password"
                    secureTextEntry
                    value={confirmPassword}
                    onChangeText={setConfirmPassword}
                  />
                </View>

                <View style={styles.checkboxRow}>
                  <Checkbox
                    value={agreeTerms}
                    onValueChange={setAgreeTerms}
                    color={agreeTerms ? "#FF7E5F" : undefined}
                  />
                  <Text style={styles.checkboxText}>
                    I agree to the{" "}
                    <Text style={styles.link}>Terms and Conditions</Text>
                  </Text>
                </View>

                <TouchableOpacity
                  onPress={handleSignup}
                  disabled={!agreeTerms}
                  style={{ width: "100%", marginTop: 10 }}
                >
                  <LinearGradient
                    colors={["#FF7E5F", "#FF4500"]}
                    style={[styles.button, !agreeTerms && { opacity: 0.6 }]}
                  >
                    <Text style={styles.buttonText}>Create Account</Text>
                  </LinearGradient>
                </TouchableOpacity>
              </>
            )}

            <Text style={styles.footerText}>
              Already have an account?{" "}
              <Text
                style={styles.link}
                onPress={() => router.push("/(auth)/login")}
              >
                Sign in
              </Text>
            </Text>
          </MotiView>

          <Text style={styles.footerNote}>© 2025 MessMate</Text>
        </ScrollView>
      </KeyboardAvoidingView>

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

// Styles remain same as before
const styles = StyleSheet.create({
  container: { flex: 1 },
  card: {
    width: "90%",
    backgroundColor: "rgba(255,255,255,0.95)",
    borderRadius: 18,
    padding: 25,
    alignItems: "center",
    shadowColor: "#000",
    shadowOpacity: 0.15,
    shadowRadius: 10,
    elevation: 8,
  },
  logo: { width: 90, height: 90, marginBottom: 12 },
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
    backgroundColor: "#fff",
    width: "100%",
  },
  input: {
    flex: 1,
    paddingVertical: 10,
    paddingHorizontal: 8,
    fontSize: 14,
    color: "#333",
  },
  verifyText: { color: "#FF4500", fontWeight: "600", fontSize: 13, marginLeft: 8 },
  otpRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 10,
  },
  otpInput: {
    borderWidth: 1,
    borderColor: "#ddd",
    borderRadius: 8,
    width: 45,
    height: 45,
    textAlign: "center",
    fontSize: 18,
    marginHorizontal: 4,
    backgroundColor: "#fff",
  },
  resendText: { color: "#FF4500", fontWeight: "600", fontSize: 13 },
  timerText: { color: "#666", fontSize: 13 },
  checkboxRow: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 15,
    alignSelf: "flex-start",
  },
  checkboxText: { marginLeft: 8, fontSize: 13, color: "#555" },
  link: { color: "#FF4500", fontWeight: "700" },
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
  footerText: { marginTop: 18, fontSize: 14, color: "#555" },
  footerNote: { marginTop: 25, color: "#666", fontSize: 13, fontWeight: "500" },
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
  modalTitle: { fontSize: 18, fontWeight: "700", color: "#333", marginBottom: 6 },
  modalMessage: { fontSize: 14, color: "#666", textAlign: "center" },
  modalButton: { padding: 12, borderRadius: 10, alignItems: "center", width: "100%" },
  modalButtonText: { color: "#fff", fontWeight: "bold", fontSize: 16 },
});
