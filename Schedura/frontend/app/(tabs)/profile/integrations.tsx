import React, { useState, useEffect } from "react";
import {
  View,
  Text,
  Switch,
  Linking,
  ActivityIndicator,
  TouchableOpacity,
  ScrollView,
} from "react-native";
import { useToast } from "@/components/Toast";
import { Ionicons } from "@expo/vector-icons";
import { useTheme } from "@/contexts/ThemeContext";
import { useUser } from "@clerk/clerk-expo";

const BACKEND_URL = "https://schedura.onrender.com";

export default function IntegrationsPage() {
  const [googleEnabled, setGoogleEnabled] = useState(false);
  const [loading, setLoading] = useState(false);
  const { showToast } = useToast();
  const [lastChecked, setLastChecked] = useState<Date | null>(null);
  const { colors } = useTheme();
  const { user } = useUser();
  const fetchStatus = async () => {
    try {
      const res = await fetch(`${BACKEND_URL}/integrations/status?userid=${user?.id}`);
      const data = await res.json();
      console.log(data)
      setGoogleEnabled(Boolean(data.google));
      setLastChecked(new Date());
    } catch (err) {
      console.error(err);
      showToast({
        type: "error",
        title: "Integrations",
        description: "Failed to fetch integration status.",
      });
    }
  };

  useEffect(() => {
    fetchStatus();
  }, []);

  const handleGoogleToggle = async (value: boolean) => {
    setLoading(true);
    try {
      if (value) {
        const res = await fetch(`${BACKEND_URL}/integrations/google/connect?userid=${user?.id}`);
        const data = await res.json();

        await Linking.openURL(data.url);
        showToast({
          type: "info",
          title: "Google Calendar",
          description: "Complete login in your browser, then return here.",
        });

        setTimeout(fetchStatus, 5000);
      } else {
        await fetch(
          `${BACKEND_URL}/integrations/google/disconnect`,
          { method: "POST" }
        );
        setGoogleEnabled(false);
        showToast({
          type: "success",
          title: "Disconnected",
          description: "Google Calendar integration removed.",
        });
        setLastChecked(new Date());
      }
    } catch (err: any) {
      showToast({
        type: "error",
        title: "Google Calendar",
        description: err?.message || "Failed to update integration status.",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <View className="flex-1 pb-5 " style={{ backgroundColor: colors.tertiary }}>
      {/* Header */}
      <View className="p-6 pb-12 rounded-b-[24px]" style={{ backgroundColor: colors.primary }}>
        <Text className="text-4xl font-bold mt-6" style={{ color: colors.accent }}>Integrations</Text>
        <Text className="mt-2 text-lg" style={{ color: colors.textSecondary }}>
          Connect your favorite tools to keep your workflows in sync.
        </Text>
      </View>
      <ScrollView className="px-6  pt-6" style={{ backgroundColor: colors.tertiary }}>
        {/* Google Calendar Card */}
        <View style={{ backgroundColor: colors.tertiary, borderColor: colors.border }} className="bg-white dark:bg-slate-900 rounded-2xl p-5 border border-gray-200 dark:border-slate-700">
          <View className="flex-row items-start justify-between">
            <View className="flex-row items-start">
              <View className="w-12 h-12 rounded-xl bg-green-100 dark:bg-green-900/30 items-center justify-center mr-3">
                <Ionicons name="logo-google" size={22} color="#16a34a" />
              </View>
              <View className="">
                <Text className="text-lg font-semibold " style={{color:colors.text}}>Google Calendar</Text>
                <Text className="text-gray-500 dark:text-gray-300 break-words whitespace-break-spaces text-xs mt-0.5">
                  Add bookings/events to your Google Calendar
                </Text>
                <Text className="text-gray-500 dark:text-gray-300 break-words whitespace-break-spaces text-xs mt-0.5">
                  automatically
                </Text>
                <View className="flex-row items-center mt-2">
                  <View
                    className={`px-2 py-1 rounded-full ${
                      googleEnabled ? "bg-green-100" : "bg-gray-200"
                    }`}
                  >
                    <Text
                      className={`text-xs font-semibold ${
                        googleEnabled ? "text-green-700" : "text-gray-700"
                      }`}
                    >
                      {googleEnabled ? "Connected" : "Not Connected"}
                    </Text>
                  </View>
                  {lastChecked && (
                    <Text className="text-[11px] text-gray-500 ml-2">
                      Checked {lastChecked.toLocaleTimeString()}
                    </Text>
                  )}
                </View>
                
              </View>
              <Switch
                value={googleEnabled}
                onValueChange={handleGoogleToggle}
                disabled={loading}
              />
            </View>

            
          </View>

          {/* Actions */}
          <View className="flex-row items-center justify-between mt-4">
            <TouchableOpacity
              activeOpacity={0.8}
              className="px-4 py-2 rounded-lg bg-gray-100 dark:bg-slate-800 border border-gray-200 dark:border-slate-700"
              onPress={fetchStatus}
              disabled={loading}
            >
              <View className="flex-row items-center">
                <Ionicons name="refresh" size={16} color="#6b7280" />
                <Text className="ml-2 text-sm text-gray-700 dark:text-gray-200">
                  Refresh
                </Text>
              </View>
            </TouchableOpacity>

            {googleEnabled ? (
              <TouchableOpacity
                activeOpacity={0.9}
                className="px-4 py-2 rounded-lg bg-green-600"
                onPress={() => Linking.openURL("https://calendar.google.com")}
              >
                <View className="flex-row items-center">
                  <Ionicons name="open-outline" size={16} color="#fff" />
                  <Text className="ml-2 text-sm text-white font-semibold">
                    Open Calendar
                  </Text>
                </View>
              </TouchableOpacity>
            ) : (
              <TouchableOpacity
                activeOpacity={0.9}
                className="px-4 py-2 rounded-lg bg-blue-600"
                onPress={() => handleGoogleToggle(true)}
                disabled={loading}
              >
                <View className="flex-row items-center">
                  <Ionicons name="link-outline" size={16} color="#fff" />
                  <Text className="ml-2 text-sm text-white font-semibold">
                    Connect
                  </Text>
                </View>
              </TouchableOpacity>
            )}
          </View>

          {/* Help text */}
          <View className="mt-3">
            <Text className="text-[12px] text-gray-500 dark:text-gray-400">
              We’ll store your authorization securely so events can be synced in
              the background.
            </Text>
          </View>
        </View>

        {/* Loading overlay */}
        {loading && (
          <View className="absolute inset-0 bg-black/10 items-center justify-center">
            <ActivityIndicator size="large" color="#16a34a" />
          </View>
        )}
      </ScrollView>
    </View>
  );
}
