import * as SecureStore from "expo-secure-store";
import React, { useEffect, useState } from "react";
import {
    ActivityIndicator,
    Alert,
    Text,
    TextInput,
    TouchableOpacity,
    View,
} from "react-native";
import { styles } from "./adminStyles";

const API_BASE = "http://10.102.232.54:5000/add-admin";
const OTP_EXPIRY = 120;
const RESEND_COOLDOWN = 60;

const AddAdminSection = ({ theme }: { theme: any }) => {
  const [newAdmin, setNewAdmin] = useState({ email: "", password: "", otp: "" });
  const [otpSent, setOtpSent] = useState(false);
  const [loading, setLoading] = useState(false);
  const [otpTimer, setOtpTimer] = useState(OTP_EXPIRY);
  const [resendCooldown, setResendCooldown] = useState(0);

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
        Alert.alert("Success", "New admin added successfully.");
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
    <View style={styles(theme).content}>
      <Text style={styles(theme).subheading}>👤 Add New Admin</Text>

      {!otpSent ? (
        <>
          <TextInput
            placeholder="Admin Email"
            placeholderTextColor={theme.placeholder}
            style={styles(theme).input}
            value={newAdmin.email}
            onChangeText={(t) => setNewAdmin((p) => ({ ...p, email: t }))}
          />
          <TextInput
            placeholder="Password"
            placeholderTextColor={theme.placeholder}
            secureTextEntry
            style={styles(theme).input}
            value={newAdmin.password}
            onChangeText={(t) => setNewAdmin((p) => ({ ...p, password: t }))}
          />
          <TouchableOpacity
            style={styles(theme).submit}
            onPress={handleAddAdmin}
            disabled={loading}
          >
            {loading ? <ActivityIndicator color="#fff" /> : <Text style={styles(theme).submitText}>📨 Send OTP</Text>}
          </TouchableOpacity>
        </>
      ) : (
        <>
          <TextInput
            placeholder="Enter OTP"
            placeholderTextColor={theme.placeholder}
            style={styles(theme).input}
            keyboardType="number-pad"
            value={newAdmin.otp}
            onChangeText={(t) => setNewAdmin((p) => ({ ...p, otp: t }))}
          />
          <Text style={{ color: theme.text, marginBottom: 10 }}>
            ⏳ OTP expires in {otpTimer}s
          </Text>

          <View style={{ flexDirection: "row", justifyContent: "space-between" }}>
            <TouchableOpacity
              style={[styles(theme).submit, { flex: 1, marginRight: 5 }]}
              onPress={handleVerifyOTP}
              disabled={loading}
            >
              {loading ? <ActivityIndicator color="#fff" /> : <Text style={styles(theme).submitText}>✅ Verify OTP</Text>}
            </TouchableOpacity>

            <TouchableOpacity
              style={[
                styles(theme).submit,
                { flex: 1, marginLeft: 5, backgroundColor: resendCooldown ? "#888" : theme.primary },
              ]}
              onPress={handleResendOTP}
              disabled={resendCooldown > 0}
            >
              <Text style={styles(theme).submitText}>
                🔄 Resend {resendCooldown ? `(${resendCooldown}s)` : ""}
              </Text>
            </TouchableOpacity>
          </View>

          <TouchableOpacity
            style={[styles(theme).submit, { backgroundColor: "#aaa", marginTop: 10 }]}
            onPress={handleBack}
          >
            <Text style={styles(theme).submitText}>⬅ Back</Text>
          </TouchableOpacity>
        </>
      )}
    </View>
  );
};

export default AddAdminSection;
