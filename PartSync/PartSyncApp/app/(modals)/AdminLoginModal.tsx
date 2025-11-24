import axios from "axios";
import { useRouter } from "expo-router";
import * as SecureStore from "expo-secure-store";
import React, { useEffect, useState } from "react";
import {
    ActivityIndicator,
    Modal,
    Pressable,
    Text,
    TextInput,
    View,
} from "react-native";
import Animated, {
    useAnimatedStyle,
    useSharedValue,
    withTiming,
} from "react-native-reanimated";
import { useTheme } from "../context/themeContext";

const AnimatedTextInput = Animated.createAnimatedComponent(TextInput);
const AnimatedView = Animated.createAnimatedComponent(View);

type Props = {
  visible: boolean;
  onClose: () => void;
  onSuccess: (token: string) => void;
};

export default function AdminLoginModal({ visible, onClose, onSuccess }: Props) {
  const router = useRouter();
  const { theme } = useTheme();

  const [step, setStep] = useState<"login" | "otp">("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [otp, setOtp] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [attemptsLeft, setAttemptsLeft] = useState(3);
  const [isLocked, setIsLocked] = useState(false);

  const fade = useSharedValue(0);

  useEffect(() => {
    if (visible) {
      fade.value = withTiming(1, { duration: 300 });
    } else {
      fade.value = withTiming(0, { duration: 300 });
      resetState();
    }
  }, [visible]);

  useEffect(() => {
    const checkToken = async () => {
      const token = await SecureStore.getItemAsync("adminToken");
      if (token) router.replace("/(screens)/Admin/AdministrationScreen");
    };
    checkToken();
  }, []);

  const resetState = () => {
    setStep("login");
    setEmail("");
    setPassword("");
    setOtp("");
    setError("");
    setAttemptsLeft(3);
    setIsLocked(false);
    setLoading(false);
  };

  const handleLogin = async () => {
    setLoading(true);
    setError("");
    try {
      const res = await axios.post("URL_Backend/admin/login", { email, password });

      if (res?.data?.success) {
        setStep("otp");
      } else {
        setError(res?.data?.message || "Invalid login credentials.");
      }
    } catch {
      setError("Failed to connect to server.");
    } finally {
      setLoading(false);
    }
  };

  const handleOTPVerify = async () => {
    if (isLocked) return;

    setLoading(true);
    setError("");
    try {
      const res = await axios.post("URL_Backend/admin/verify-otp", { email, otp });

      if (res?.data?.success && res.data.token) {
        await SecureStore.setItemAsync("adminToken", res.data.token);
        await SecureStore.setItemAsync("adminEmail", email);
        onSuccess(res.data.token);
        router.replace("/(screens)/Admin/AdministrationScreen");
      } else {
        const attempts = res?.data?.attemptsLeft ?? attemptsLeft - 1;
        setAttemptsLeft(attempts);
        if (res?.data?.message?.includes("locked")) setIsLocked(true);
        setError(res?.data?.message || "OTP verification failed");
      }
    } catch {
      setError("Server error. Try again.");
    } finally {
      setLoading(false);
    }
  };

  const fadeStyle = useAnimatedStyle(() => ({ opacity: fade.value }));

  return (
    <Modal visible={visible} transparent animationType="none" onRequestClose={onClose}>
      <AnimatedView
        style={[
          {
            flex: 1,
            backgroundColor: theme.overlay,
            justifyContent: "center",
            alignItems: "center",
            paddingHorizontal: 24,
          },
          fadeStyle,
        ]}
      >
        <View
          style={{
            backgroundColor: theme.card,
            borderRadius: 20,
            padding: 24,
            width: "100%",
            maxWidth: 400,
            elevation: 10,
            shadowColor: "#000",
            shadowOpacity: 0.25,
            shadowRadius: 8,
            shadowOffset: { width: 0, height: 4 },
          }}
        >
          <Text
            style={{
              fontSize: 22,
              color: theme.accent,
              fontWeight: "bold",
              textAlign: "center",
              marginBottom: 20,
            }}
          >
            {step === "login" ? "Admin Login" : "Enter OTP"}
          </Text>

          {step === "login" ? (
            <>
              <AnimatedTextInput
                placeholder="Email"
                placeholderTextColor={theme.textSecondary}
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
                style={{
                  backgroundColor: theme.inputBackground,
                  color: theme.textPrimary,
                  padding: 12,
                  borderRadius: 10,
                  marginBottom: 12,
                }}
              />
              <AnimatedTextInput
                placeholder="Password"
                placeholderTextColor={theme.textSecondary}
                value={password}
                onChangeText={setPassword}
                secureTextEntry
                style={{
                  backgroundColor: theme.inputBackground,
                  color: theme.textPrimary,
                  padding: 12,
                  borderRadius: 10,
                  marginBottom: 12,
                }}
              />
              {error ? <Text style={{ color: theme.error, fontSize: 14, textAlign: "center" }}>{error}</Text> : null}
              <Pressable
                onPress={handleLogin}
                disabled={loading}
                style={{
                  backgroundColor: theme.accent,
                  padding: 14,
                  borderRadius: 10,
                  alignItems: "center",
                  marginTop: 8,
                }}
              >
                {loading ? (
                  <ActivityIndicator color={theme.background} />
                ) : (
                  <Text style={{ color: theme.background, fontWeight: "bold" }}>Send OTP</Text>
                )}
              </Pressable>
            </>
          ) : (
            <>
              <AnimatedTextInput
                placeholder="Enter OTP"
                placeholderTextColor={theme.textSecondary}
                value={otp}
                onChangeText={setOtp}
                keyboardType="number-pad"
                maxLength={6}
                style={{
                  backgroundColor: theme.inputBackground,
                  color: theme.textPrimary,
                  padding: 12,
                  borderRadius: 10,
                  marginBottom: 12,
                }}
              />
              {error ? <Text style={{ color: theme.error, fontSize: 14, textAlign: "center" }}>{error}</Text> : null}
              {!isLocked && attemptsLeft > 0 && (
                <Text style={{ color: theme.textSecondary, textAlign: "center", marginBottom: 6 }}>
                  Attempts left: {attemptsLeft}
                </Text>
              )}
              {isLocked && (
                <Text style={{ color: theme.error, textAlign: "center", marginBottom: 6 }}>
                  Account locked for 24 hours due to failed OTP attempts.
                </Text>
              )}
              <Pressable
                onPress={handleOTPVerify}
                disabled={loading || isLocked}
                style={{
                  backgroundColor: isLocked ? theme.textSecondary : theme.success,
                  padding: 14,
                  borderRadius: 10,
                  alignItems: "center",
                  marginTop: 8,
                }}
              >
                {loading ? (
                  <ActivityIndicator color={theme.background} />
                ) : (
                  <Text style={{ color: theme.background, fontWeight: "bold" }}>
                    {isLocked ? "Locked" : "Verify OTP"}
                  </Text>
                )}
              </Pressable>
            </>
          )}

          <Pressable onPress={onClose} style={{ alignItems: "center", marginTop: 16 }}>
            <Text style={{ color: theme.textSecondary, fontSize: 14 }}>Cancel</Text>
          </Pressable>
        </View>
      </AnimatedView>
    </Modal>
  );
}
