import React, { useState } from "react";
import "../../../global.css"
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  Image,
} from "react-native";
import {
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
} from "firebase/auth";
import { doc, setDoc } from "firebase/firestore";
import { auth, db } from "@/firebase";
import { useRouter } from "expo-router";

export default function AuthScreen() {
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isSignUpMode, setIsSignUpMode] = useState(true);
  const [username, setUsername] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [agreeToTerms, setAgreeToTerms] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const router = useRouter();

  const handleSubmit = async () => {
    setLoading(true);
    setError(null);
    setSuccess(null);
    try {
      if (isSignUpMode) {
        if (password !== confirmPassword) {
          setError("Passwords do not match");
          setLoading(false);
          return;
        }
        if (!agreeToTerms) {
          setError("Please agree to the Terms and Conditions");
          setLoading(false);
          return;
        }
        const userCredential = await createUserWithEmailAndPassword(
          auth,
          email,
          password
        );
        const user = userCredential.user;
        await setDoc(doc(db, "users", user.uid), {
          username,
          email,
          createdAt: new Date(),
        });
        setSuccess("Account created successfully!");
      } else {
        await signInWithEmailAndPassword(auth, email, password);
        setSuccess("Logged in successfully!");
      }
      setUsername("");
      setEmail("");
      setPassword("");
      setConfirmPassword("");
      console.log("Navigating to home...");
      router.replace("/screens/customer/home");
    } catch (err: any) {
      console.error("Auth error:", err);
      setError(err.message || "Something went wrong.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <View className="flex-1 bg-[#F4B223]">
      {/* Header */}
      <View className="flex-row items-center px-4 pt-12 pb-4 bg-[#F4B223]">
        <TouchableOpacity onPress={() => router.back()} className="mr-3">
          <Text className="text-2xl">←</Text>
        </TouchableOpacity>
        <View className="flex-1 bg-white rounded-lg py-2 px-4">
          <Text className="text-black text-lg font-semibold text-center">
            Customer
          </Text>
        </View>
      </View>

      {/* Form Container */}
      <View className="flex-1 bg-white mx-4 rounded-t-3xl px-6 pt-6">
        <Text className="text-gray-500 text-sm mb-6">
          {isSignUpMode ? "Create an account to get started" : "Sign in to your account"}
        </Text>

        {isSignUpMode && (
          <View className="mb-4">
            <Text className="text-black font-semibold mb-2">Username</Text>
            <TextInput
              className="bg-[#FFFAE6] rounded-lg px-4 py-3 text-black"
              placeholder="Name"
              placeholderTextColor="#999"
              value={username}
              onChangeText={setUsername}
            />
          </View>
        )}

        <View className="mb-4">
          <Text className="text-black font-semibold mb-2">Email</Text>
          <TextInput
            className="bg-[#FFFAE6] rounded-lg px-4 py-3 text-black"
            placeholder="name@email.com"
            placeholderTextColor="#999"
            value={email}
            onChangeText={setEmail}
            keyboardType="email-address"
            autoCapitalize="none"
          />
        </View>

        <View className="mb-4">
          <Text className="text-black font-semibold mb-2">Password</Text>
          <View className="flex-row bg-[#FFFAE6] rounded-lg px-4 py-3 items-center">
            <TextInput
              className="flex-1 text-black"
              placeholder="Create password"
              placeholderTextColor="#999"
              value={password}
              onChangeText={setPassword}
              secureTextEntry={!showPassword}
            />
            <TouchableOpacity onPress={() => setShowPassword(!showPassword)}>
              <Text className="text-gray-600 text-lg">👁</Text>
            </TouchableOpacity>
          </View>
        </View>

        {isSignUpMode && (
          <>
            <View className="mb-4">
              <Text className="text-black font-semibold mb-2">Confirm password</Text>
              <View className="flex-row bg-[#FFFAE6] rounded-lg px-4 py-3 items-center">
                <TextInput
                  className="flex-1 text-black"
                  placeholder="Confirm password"
                  placeholderTextColor="#999"
                  value={confirmPassword}
                  onChangeText={setConfirmPassword}
                  secureTextEntry={!showConfirmPassword}
                />
                <TouchableOpacity onPress={() => setShowConfirmPassword(!showConfirmPassword)}>
                  <Text className="text-gray-600 text-lg">👁</Text>
                </TouchableOpacity>
              </View>
            </View>

            <View className="flex-row items-start mb-4">
              <TouchableOpacity 
                onPress={() => setAgreeToTerms(!agreeToTerms)}
                className="mr-2 mt-1"
              >
                <View className={`w-5 h-5 border-2 border-gray-400 rounded ${agreeToTerms ? 'bg-gray-400' : 'bg-white'}`} />
              </TouchableOpacity>
              <Text className="flex-1 text-gray-600 text-xs">
                I've read and agree with the{" "}
                <Text className="text-[#F4B223] underline">Terms and Conditions</Text>
                {" "}and the{" "}
                <Text className="text-[#F4B223] underline">Privacy Policy</Text>
              </Text>
            </View>
          </>
        )}

        {error && (
          <Text className="text-red-500 text-sm text-center mb-2">{error}</Text>
        )}
        {success && (
          <Text className="text-green-600 text-sm text-center mb-2">
            {success}
          </Text>
        )}

        <Text className="text-center text-sm text-black mb-4">
          {isSignUpMode ? "Already have an account? " : "Don't have an account? "}
          <Text
            className="text-[#F4B223] font-semibold"
            onPress={() => {
              setIsSignUpMode(!isSignUpMode);
              setError(null);
              setSuccess(null);
            }}
          >
            {isSignUpMode ? "Sign In" : "Sign Up"}
          </Text>
        </Text>

        <TouchableOpacity
          className={`w-full bg-white border-2 border-black py-3 rounded-full items-center ${
            loading ? "opacity-50" : "opacity-100"
          }`}
          onPress={handleSubmit}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#000" />
          ) : (
            <Text className="text-black font-bold text-base">
              {isSignUpMode ? "Sign up" : "Sign in"}
            </Text>
          )}
        </TouchableOpacity>
      </View>
    </View>
  );
}