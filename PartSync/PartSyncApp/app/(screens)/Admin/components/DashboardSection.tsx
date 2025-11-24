import { Ionicons } from "@expo/vector-icons";
import { LinearGradient } from "expo-linear-gradient";
import React from "react";
import { Text, TouchableOpacity, View } from "react-native";
import Animated, { FadeInDown } from "react-native-reanimated";

export default function DashboardSection({ theme }: { theme: any }) {
  return (
    <LinearGradient
      colors={
        theme.isDark
          ? ["#0F111A", "#1B1E29"]
          : ["#F8FAFF", "#E9EEFF"]
      }
      style={{
        flex: 1,
        paddingHorizontal: 20,
        paddingVertical: 5,
      }}
    >
      <Animated.Text
        entering={FadeInDown.springify().delay(100)}
        style={{
          fontSize: 28,
          fontWeight: "800",
          color: theme.textPrimary,
          marginBottom: 12,
          letterSpacing: 0.4,
        }}
      >
        📊 Dashboard
      </Animated.Text>

      <Animated.Text
        entering={FadeInDown.springify().delay(200)}
        style={{
          color: theme.textSecondary,
          fontSize: 15,
          lineHeight: 22,
          marginBottom: 26,
        }}
      >
        Welcome to your admin dashboard. Use the side menu to manage hardware,
        create new admins, or view system audit logs.
      </Animated.Text>

      <View style={{ gap: 14 }}>
        <Animated.View entering={FadeInDown.springify().delay(300)}>
          <TouchableOpacity
            activeOpacity={0.9}
            style={{
              borderRadius: 18,
              overflow: "hidden",
              shadowColor: theme.shadowColor,
              shadowOpacity: 0.25,
              shadowRadius: 10,
              elevation: 5,
            }}
          >
            <LinearGradient
              colors={
                theme.isDark
                  ? ["#2A2D3E", "#1C1E2C"]
                  : ["#FFFFFF", "#EAF0FF"]
              }
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={{
                padding: 18,
                borderWidth: 1,
                borderColor: theme.border,
              }}
            >
              <View
                style={{
                  flexDirection: "row",
                  alignItems: "center",
                }}
              >
                <Ionicons
                  name="search-outline"
                  size={24}
                  color={theme.accent}
                  style={{ marginRight: 10 }}
                />
                <View>
                  <Text
                    style={{
                      fontWeight: "700",
                      fontSize: 16,
                      color: theme.textPrimary,
                    }}
                  >
                    Quick Search
                  </Text>
                  <Text
                    style={{
                      color: theme.textSecondary,
                      marginTop: 2,
                      fontSize: 14,
                    }}
                  >
                    Find and review components easily.
                  </Text>
                </View>
              </View>
            </LinearGradient>
          </TouchableOpacity>
        </Animated.View>

        <Animated.View entering={FadeInDown.springify().delay(400)}>
          <TouchableOpacity
            activeOpacity={0.9}
            style={{
              borderRadius: 18,
              overflow: "hidden",
              shadowColor: theme.shadowColor,
              shadowOpacity: 0.25,
              shadowRadius: 10,
              elevation: 5,
            }}
          >
            <LinearGradient
              colors={
                theme.isDark
                  ? ["#2A2D3E", "#1C1E2C"]
                  : ["#FFFFFF", "#EAF0FF"]
              }
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={{
                padding: 18,
                borderWidth: 1,
                borderColor: theme.border,
              }}
            >
              <View
                style={{
                  flexDirection: "row",
                  alignItems: "center",
                }}
              >
                <Ionicons
                  name="people-outline"
                  size={24}
                  color={theme.accent}
                  style={{ marginRight: 10 }}
                />
                <View>
                  <Text
                    style={{
                      fontWeight: "700",
                      fontSize: 16,
                      color: theme.textPrimary,
                    }}
                  >
                    Admins & Roles
                  </Text>
                  <Text
                    style={{
                      color: theme.textSecondary,
                      marginTop: 2,
                      fontSize: 14,
                    }}
                  >
                    Manage access, roles, and privileges.
                  </Text>
                </View>
              </View>
            </LinearGradient>
          </TouchableOpacity>
        </Animated.View>
      </View>
    </LinearGradient>
  );
}
