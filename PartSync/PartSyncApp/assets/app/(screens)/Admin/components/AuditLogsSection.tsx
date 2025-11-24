import React, { useCallback, useEffect, useState } from "react";
import { ActivityIndicator, Alert, FlatList, RefreshControl, Text, View } from "react-native";
import { styles } from "./adminStyles";

const API_BASE = "http://10.102.232.54:5000/admin";

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

  if (loading) return <ActivityIndicator style={{ margin: 16 }} />;

  return (
    <View style={styles(theme).content}>
      <Text style={styles(theme).subheading}>📜 Audit Logs</Text>

      <FlatList
        data={logs}
        keyExtractor={(item) => String(item.id ?? item.timestamp ?? Math.random())}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={theme.primary} />}
        renderItem={({ item }) => (
          <View style={styles(theme).card}>
            <Text style={styles(theme).cardText}>
              <Text style={{ fontWeight: "700" }}>Admin:</Text> {item.admin_email ?? item.admin_id ?? "—"}
            </Text>
            <Text style={styles(theme).cardText}>
              <Text style={{ fontWeight: "700" }}>Action:</Text> {item.action}
            </Text>
            <Text style={styles(theme).cardText}>
              <Text style={{ fontWeight: "700" }}>Target:</Text> {item.target_table ?? item.target ?? "—"}
            </Text>
            <Text style={styles(theme).cardText}>
              <Text style={{ fontWeight: "700" }}>Record:</Text> {item.target_id ?? item.record_id ?? "—"}
            </Text>
            <Text style={styles(theme).cardText}>
              <Text style={{ fontWeight: "700" }}>Time:</Text> {item.created_at ?? item.timestamp ?? "—"}
            </Text>
            {item.details ? (
              <Text style={styles(theme).cardText}>
                <Text style={{ fontWeight: "700" }}>Details:</Text> {String(item.details)}
              </Text>
            ) : null}
          </View>
        )}
        ListEmptyComponent={<Text style={{ textAlign: "center", marginTop: 20, color: theme.textSecondary }}>No audit logs found.</Text>}
      />
    </View>
  );
}
