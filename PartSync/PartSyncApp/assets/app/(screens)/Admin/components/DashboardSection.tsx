import React from "react";
import { Text, TouchableOpacity, View } from "react-native";
import { styles } from "./adminStyles";

export default function DashboardSection({ theme }: { theme: any }) {
  return (
    <View style={styles(theme).content}>
      <Text style={styles(theme).subheading}>📊 Dashboard</Text>

      <View style={{ marginVertical: 8 }}>
        <Text style={styles(theme).cardText}>
          Welcome to the admin dashboard. Use the menu to manage hardware,
          create admins, or view audit logs.
        </Text>
      </View>

      <View style={{ marginTop: 16 }}>
        <TouchableOpacity
          style={[styles(theme).actionCard, { borderColor: theme.inputBorder }]}
        >
          <Text style={[styles(theme).cardText, { fontWeight: "700", fontSize: 16 }]}>
            🔎 Quick Search
          </Text>
          <Text style={styles(theme).cardText}>Search for components rapidly.</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles(theme).actionCard, { borderColor: theme.inputBorder, marginTop: 10 }]}
        >
          <Text style={[styles(theme).cardText, { fontWeight: "700", fontSize: 16 }]}>
            👤 Admins & Roles
          </Text>
          <Text style={styles(theme).cardText}>Create admins, review activity.</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}
