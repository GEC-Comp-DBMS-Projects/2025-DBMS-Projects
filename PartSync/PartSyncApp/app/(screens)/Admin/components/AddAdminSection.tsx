import { LinearGradient } from "expo-linear-gradient";
import * as SecureStore from "expo-secure-store";
import React, { useEffect, useState } from "react";
import {
    ActivityIndicator,
    Alert,
    Animated,
    Text,
    TextInput,
    TouchableOpacity,
    View,
} from "react-native";
import { styles } from "./adminStyles";

const API_BASE = "URL_Backend/add-admin";
const OTP_EXPIRY = 120;
const RESEND_COOLDOWN = 60;

const AddAdminSection = ({ theme }: { theme: any }) => {
  const [newAdmin, setNewAdmin] = useState({ email: "", password: "", otp: "" });
  const [otpSent, setOtpSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [otpTimer, setOtpTimer] = useState(OTP_EXPIRY);
  const [resendCooldown, setResendCooldown] = useState(0);
  const fadeAnim = useState(new Animated.Value(0))[0];

  useEffect(() => {
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 500,
      useNativeDriver: true,
    }).start();
  }, [otpSent]);

  useEffect(() => {
    if (otpSent && otpTimer > 0) {
      const timer = setTimeout(() => setOtpTimer((t) => t - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [otpSent, otpTimer]);

  useEffect(() => {
    if (resendCooldown > 0) {
      const timer = setTimeout(() => setResendCooldown((t) => t - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [resendCooldown]);

  const handleAddAdmin = async () => {
    setLoading(true);
    try {
      const token = await SecureStore.getItemAsync("adminToken");
      if (!token) throw new Error("Admin not logged in");
      const currentAdminEmail = atob(token).split(":")[0];

      const res = await fetch(`${API_BASE}/send-otp`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: newAdmin.email,
          password: newAdmin.password,
          creatorEmail: currentAdminEmail,
        }),
      });

      const json = await res.json();
      if (res.ok) {
        Alert.alert("OTP Sent", "Check the new admin's email for the OTP.");
        setOtpSent(true);
        setOtpTimer(OTP_EXPIRY);
      } else Alert.alert("Failed", json.message);
    } catch (err: any) {
      Alert.alert("Error", err.message || "Could not send OTP.");
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOTP = async () => {
    setLoading(true);
    try {
      const token = await SecureStore.getItemAsync("adminToken");
      if (!token) throw new Error("Admin not logged in");
      const currentAdminEmail = atob(token).split(":")[0];

      const res = await fetch(`${API_BASE}/verify-otp`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: newAdmin.email,
          otp: newAdmin.otp,
          password: newAdmin.password,
          creatorEmail: currentAdminEmail,
        }),
      });

      const json = await res.json();
      if (res.ok) {
        Alert.alert("✅ Success", "New admin added successfully.");
        setOtpSent(false);
        setNewAdmin({ email: "", password: "", otp: "" });
      } else Alert.alert("Failed", json.message);
    } catch (err: any) {
      Alert.alert("Error", err.message || "Could not verify OTP.");
    } finally {
      setLoading(false);
    }
  };

  const handleResendOTP = () => {
    if (resendCooldown > 0) return;
    handleAddAdmin();
    setResendCooldown(RESEND_COOLDOWN);
  };

  const handleBack = () => {
    setOtpSent(false);
    setNewAdmin({ email: "", password: "", otp: "" });
  };

  return (
    <Animated.View style={[styles(theme).content, { opacity: fadeAnim }]}>
      <LinearGradient
        colors={[theme.cardBackground, theme.background]}
        style={{
          borderRadius: 20,
          padding: 20,
          shadowColor: theme.textPrimary,
          shadowOpacity: 0.15,
          shadowRadius: 10,
          shadowOffset: { width: 0, height: 3 },
        }}
      >
        <Text
          style={[
            styles(theme).subheading,
            { textAlign: "center", marginBottom: 20 },
          ]}
        >
          👤 Add New Admin
        </Text>

        {!otpSent ? (
          <>
            <TextInput
              placeholder="Admin Email"
              placeholderTextColor={theme.placeholder}
              style={[styles(theme).input, { marginBottom: 12 }]}
              value={newAdmin.email}
              onChangeText={(t) => setNewAdmin((p) => ({ ...p, email: t }))}
            />

            <TextInput
              placeholder="Password"
              placeholderTextColor={theme.placeholder}
              secureTextEntry
              style={[styles(theme).input, { marginBottom: 20 }]}
              value={newAdmin.password}
              onChangeText={(t) => setNewAdmin((p) => ({ ...p, password: t }))}
            />

            <TouchableOpacity
              onPress={handleAddAdmin}
              disabled={loading}
              activeOpacity={0.8}
            >
              <LinearGradient
                colors={
                  loading
                    ? ["#999", "#999"]
                    : [theme.primary, theme.activeButtonBackground]
                }
                style={[styles(theme).submit, { borderRadius: 12 }]}
              >
                {loading ? (
                  <ActivityIndicator color="#fff" />
                ) : (
                  <Text style={styles(theme).submitText}>📨 Send OTP</Text>
                )}
              </LinearGradient>
            </TouchableOpacity>
          </>
        ) : (
          <>
            <TextInput
              placeholder="Enter OTP"
              placeholderTextColor={theme.placeholder}
              style={[styles(theme).input, { marginBottom: 10 }]}
              keyboardType="number-pad"
              value={newAdmin.otp}
              onChangeText={(t) => setNewAdmin((p) => ({ ...p, otp: t }))}
            />

            <Text
              style={{
                color: theme.textSecondary,
                textAlign: "center",
                marginBottom: 16,
              }}
            >
              ⏳ OTP expires in {otpTimer}s
            </Text>

            <View style={{ flexDirection: "row", gap: 10 }}>
              <TouchableOpacity
                style={{ flex: 1 }}
                onPress={handleVerifyOTP}
                disabled={loading}
              >
                <LinearGradient
                  colors={[theme.primary, theme.activeButtonBackground]}
                  style={[styles(theme).submit, { borderRadius: 12 }]}
                >
                  {loading ? (
                    <ActivityIndicator color="#fff" />
                  ) : (
                    <Text style={styles(theme).submitText}>✅ Verify OTP</Text>
                  )}
                </LinearGradient>
              </TouchableOpacity>

              <TouchableOpacity
                style={{ flex: 1 }}
                onPress={handleResendOTP}
                disabled={resendCooldown > 0}
              >
                <LinearGradient
                  colors={
                    resendCooldown
                      ? ["#666", "#555"]
                      : [theme.accent, theme.activeButtonBackground]
                  }
                  style={[styles(theme).submit, { borderRadius: 12 }]}
                >
                  <Text style={styles(theme).submitText}>
                    🔄 Resend{" "}
                    {resendCooldown ? `(${resendCooldown}s)` : ""}
                  </Text>
                </LinearGradient>
              </TouchableOpacity>
            </View>

            <TouchableOpacity
              onPress={handleBack}
              activeOpacity={0.8}
              style={{ marginTop: 16 }}
            >
              <LinearGradient
                colors={["#999", "#777"]}
                style={[styles(theme).submit, { borderRadius: 12 }]}
              >
                <Text style={styles(theme).submitText}>⬅ Back</Text>
              </LinearGradient>
            </TouchableOpacity>
          </>
        )}
      </LinearGradient>
    </Animated.View>
  );
};

export default AddAdminSection;
