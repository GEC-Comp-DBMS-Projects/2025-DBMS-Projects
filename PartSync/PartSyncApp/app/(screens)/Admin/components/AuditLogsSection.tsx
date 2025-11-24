import { MaterialIcons } from "@expo/vector-icons";
import React, { useCallback, useEffect, useState } from "react";
import {
    ActivityIndicator,
    Alert,
    FlatList,
    RefreshControl,
    Text,
    TouchableOpacity,
    View,
} from "react-native";
import { styles } from "./adminStyles";

const API_BASE = "URL_Backend/admin";

export default function AuditLogsSection({ theme }: { theme: any }) {
  const [logs, setLogs] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  const fetchLogs = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE}/audit`);
      const json = await res.json();
      setLogs(Array.isArray(json) ? json : []);
    } catch (err: any) {
      Alert.alert("Error", "Failed to load audit logs.");
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await fetchLogs();
    setRefreshing(false);
  }, []);

  useEffect(() => {
    fetchLogs();
  }, []);

  return (
    <View style={styles(theme).content}>
      <View
        style={{
          flexDirection: "row",
          alignItems: "center",
          marginBottom: 5,
          justifyContent: "space-between",
        }}
      >
        <Text style={styles(theme).subheading}>📜 Audit Logs</Text>
        <TouchableOpacity onPress={fetchLogs}>
          <MaterialIcons name="refresh" size={24} color={theme.icon} />
        </TouchableOpacity>
      </View>

      {loading ? (
        <View style={{ alignItems: "center", marginTop: 40 }}>
          <ActivityIndicator size="large" color={theme.primary} />
          <Text
            style={{
              marginTop: 12,
              color: theme.textSecondary,
              fontSize: 15,
            }}
          >
            Loading audit logs...
          </Text>
        </View>
      ) : (
        <FlatList
          data={logs}
          keyExtractor={(item) =>
            String(item.id ?? item.timestamp ?? Math.random())
          }
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={onRefresh}
              tintColor={theme.primary}
            />
          }
          renderItem={({ item }) => (
            <View
              style={[
                styles(theme).card,
                {
                  borderLeftWidth: 4,
                  borderLeftColor: theme.accent,
                },
              ]}
            >
              <View
                style={{
                  flexDirection: "row",
                  alignItems: "center",
                  marginBottom: 6,
                }}
              >
                <MaterialIcons
                  name="admin-panel-settings"
                  size={20}
                  color={theme.icon}
                  style={{ marginRight: 6 }}
                />
                <Text
                  style={[
                    styles(theme).cardText,
                    { fontWeight: "700", color: theme.textPrimary },
                  ]}
                >
                  {item.admin_email ?? item.admin_id ?? "Unknown Admin"}
                </Text>
              </View>

              <Text style={styles(theme).cardText}>
                <Text style={{ fontWeight: "700" }}>Action:</Text> {item.action}
              </Text>
              <Text style={styles(theme).cardText}>
                <Text style={{ fontWeight: "700" }}>Target:</Text>{" "}
                {item.target_table ?? item.target ?? "—"}
              </Text>
              <Text style={styles(theme).cardText}>
                <Text style={{ fontWeight: "700" }}>Record:</Text>{" "}
                {item.target_id ?? item.record_id ?? "—"}
              </Text>

              <View
                style={{
                  flexDirection: "row",
                  alignItems: "center",
                  marginTop: 6,
                }}
              >
                <MaterialIcons
                  name="schedule"
                  size={16}
                  color={theme.icon}
                  style={{ marginRight: 4 }}
                />
                <Text
                  style={[styles(theme).cardText, { color: theme.textSecondary }]}
                >
                  {item.created_at ?? item.timestamp ?? "—"}
                </Text>
              </View>

              {item.details ? (
                <Text
                  style={[
                    styles(theme).cardText,
                    {
                      marginTop: 8,
                      fontStyle: "italic",
                      color: theme.textSecondary,
                    },
                  ]}
                >
                  “{String(item.details)}”
                </Text>
              ) : null}
            </View>
          )}
          ListEmptyComponent={
            <View style={{ alignItems: "center", marginTop: 40 }}>
              <MaterialIcons
                name="history"
                size={48}
                color={theme.border}
                style={{ marginBottom: 10 }}
              />
              <Text
                style={{
                  textAlign: "center",
                  color: theme.textSecondary,
                  fontSize: 15,
                }}
              >
                No audit logs found.
              </Text>
            </View>
          }
        />
      )}
    </View>
  );
}
